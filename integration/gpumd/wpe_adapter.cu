/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Portions copyright 2017-2026 Zheyong Fan and GPUMD contributors.
 * Modifications and additional integration code copyright (c) 2026 Wisevolve.
 */

#include "wpe_adapter.cuh"
#include "wpe_gpumd_error.cuh"
#include <cstddef>
#include <cstdio>
#include <type_traits>

void gpumd_wpe_activate_stage(
  const std::vector<std::unique_ptr<Potential>>& potentials,
  const WpeStageInfo& stage)
{
  if (potentials.size() != 1u) {
    gpumd_wpe_fatal(
      "Wisevolve Potential Engine integration supports exactly one potential");
  }
  auto* fast = static_cast<WpePotential*>(potentials.front().get());
  fast->activate_wpe_stage(stage);
}

void WpeForceAdapter::require_ok(const WpeStatus status)
{
  if (status == WPE_OK) return;
  gpumd_wpe_api_failure(static_cast<int>(status));
}

WpeForceAdapter::WpeForceAdapter(
  const char* potential_path,
  const int number_of_atoms)
{
  static_assert(std::is_same<int, int32_t>::value, "GPUMD int must match WPE int32_t");

  WpeCreateInfo info{};
  info.struct_size = sizeof(info);
  info.potential_path = potential_path;
  info.number_of_atoms = number_of_atoms;
  create_result_ = WpeCreateResult{};
  create_result_.struct_size = sizeof(create_result_);
  const WpeStatus create_status =
    wpe_create(&info, &create_result_, &context_);
  require_ok(create_status);
  if (context_ == nullptr ||
      create_result_.struct_size < WPE_CREATE_RESULT_V1_MIN_SIZE) {
    gpumd_wpe_fatal("Wisevolve Potential Engine initialization returned an invalid result");
  }

  static bool metadata_reported = false;
  if (!metadata_reported) {
    WpeInfo engine_info{};
    engine_info.struct_size = sizeof(engine_info);
    require_ok(wpe_get_info(&engine_info));
    if (engine_info.struct_size < WPE_INFO_V1_MIN_SIZE) {
      gpumd_wpe_fatal("Wisevolve Potential Engine returned incompatible metadata");
    }

    if (engine_info.provider != nullptr && engine_info.provider[0] != '\0') {
      std::printf("Provider: %s\n", engine_info.provider);
    }
    if (engine_info.struct_size >=
          offsetof(WpeInfo, project_url) + sizeof(engine_info.project_url) &&
        engine_info.project_url != nullptr && engine_info.project_url[0] != '\0') {
      std::printf("Website: %s\n", engine_info.project_url);
    }
    if (engine_info.struct_size >=
          offsetof(WpeInfo, citation) + sizeof(engine_info.citation) &&
        engine_info.citation != nullptr && engine_info.citation[0] != '\0') {
      std::printf("Citation: %s\n", engine_info.citation);
    }
    if (engine_info.struct_size >=
          offsetof(WpeInfo, citation_doi) + sizeof(engine_info.citation_doi) &&
        engine_info.citation_doi != nullptr && engine_info.citation_doi[0] != '\0') {
      std::printf("DOI: %s\n", engine_info.citation_doi);
    }
    metadata_reported = true;
  }
}

WpeForceAdapter::~WpeForceAdapter()
{
  wpe_destroy(context_);
  context_ = nullptr;
}

void WpeForceAdapter::activate_stage(const WpeStageInfo& stage)
{
  require_ok(wpe_activate_stage(context_, &stage));
  need_charge_output_ =
    (stage.facts & WPE_STAGE_NEED_CHARGE_OUTPUT) != 0u;
  need_bec_ = (stage.facts & WPE_STAGE_NEED_BEC_OUTPUT) != 0u;

  if (need_charge_output_) {
    if (charge_.size() != static_cast<size_t>(stage.number_of_atoms))
      charge_.resize(static_cast<size_t>(stage.number_of_atoms));
  }
  if (need_bec_) {
    const size_t n = static_cast<size_t>(9) * stage.number_of_atoms;
    if (bec_.size() != n) bec_.resize(n);
  }

  pimd_beads_ = stage.pimd_beads;
}

void WpeForceAdapter::compute(
  Box& box,
  const GPU_Vector<int>& type,
  const GPU_Vector<double>& position,
  GPU_Vector<double>& potential,
  GPU_Vector<double>& force,
  GPU_Vector<double>& virial)
{
  if (type.size() == 0u) gpumd_wpe_fatal("empty atom binding");
  if (pimd_beads_ > 0u &&
      virial.size() < static_cast<size_t>(type.size()) * 9u) {
    gpumd_wpe_fatal("PIMD virial surface is smaller than the active atom binding");
  }

  WpeBinding binding{};
  binding.struct_size = sizeof(binding);
  binding.number_of_atoms = static_cast<int32_t>(type.size());
  binding.position_device = position.data();
  binding.type_device = type.data();
  binding.force_device = force.data();
  binding.potential_device = potential.data();
  binding.atomic_virial_device = virial.data();

  // Compact total-virial scratch is owned by WPE.  A host may provide an
  // external double[6] surface through this API field, but GPUMD does not need
  // one and therefore requests the engine-owned path with nullptr.
  binding.total_virial_device = nullptr;

  binding.box_h18_host = box.cpu_h;
  binding.pbc_x_host = reinterpret_cast<const int32_t*>(&box.pbc_x);
  binding.pbc_y_host = reinterpret_cast<const int32_t*>(&box.pbc_y);
  binding.pbc_z_host = reinterpret_cast<const int32_t*>(&box.pbc_z);
  binding.charge_device = need_charge_output_ ? charge_.data() : nullptr;
  binding.bec_device = need_bec_ ? bec_.data() : nullptr;

  // Binding identity caching and all internal scratch ownership live in WPE.
  require_ok(wpe_bind(context_, &binding));
  require_ok(wpe_compute(context_));
}

WpePotential::WpePotential(
  const char* potential_path,
  const int number_of_atoms)
  : adapter_(potential_path, number_of_atoms)
{
  N1 = 0;
  N2 = number_of_atoms;
  rc = adapter_.cutoff();
}

WpePotential::~WpePotential() = default;

void WpePotential::compute(
  Box& box,
  const GPU_Vector<int>& type,
  const GPU_Vector<double>& position,
  GPU_Vector<double>& potential,
  GPU_Vector<double>& force,
  GPU_Vector<double>& virial)
{
  adapter_.compute(box, type, position, potential, force, virial);
}
