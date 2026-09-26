/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Portions copyright 2017-2026 Zheyong Fan and GPUMD contributors.
 * Modifications and additional integration code copyright (c) 2026 Wisevolve.
 */

#pragma once
#ifndef GPUMD_WPE_ENABLED
#error "wpe_adapter.cuh is only for GPUMD_WPE_ENABLED builds"
#endif

#include "wisevolve_potential_api.h"
#include "potential.cuh"
#include <cstdint>
#include <memory>
#include <vector>

void gpumd_wpe_activate_stage(
  const std::vector<std::unique_ptr<Potential>>& potentials,
  const WpeStageInfo& stage);

class WpeForceAdapter
{
public:
  WpeForceAdapter(
    const char* potential_path,
    int number_of_atoms);
  ~WpeForceAdapter();

  WpeForceAdapter(const WpeForceAdapter&) = delete;
  WpeForceAdapter& operator=(const WpeForceAdapter&) = delete;

  void activate_stage(const WpeStageInfo& stage);
  GPU_Vector<float>& charge() { return charge_; }
  GPU_Vector<float>& bec() { return bec_; }
  double cutoff() const { return create_result_.cutoff; }

  void compute(
    Box& box,
    const GPU_Vector<int>& type,
    const GPU_Vector<double>& position,
    GPU_Vector<double>& potential,
    GPU_Vector<double>& force,
    GPU_Vector<double>& virial);

private:
  static void require_ok(WpeStatus status);

  WpeContext* context_ = nullptr;
  WpeCreateResult create_result_{};
  bool need_charge_output_ = false;
  bool need_bec_ = false;
  uint32_t pimd_beads_ = 0u;

  GPU_Vector<float> charge_;
  GPU_Vector<float> bec_;

};

class WpePotential final : public Potential
{
public:
  WpePotential(
    const char* potential_path,
    int number_of_atoms);
  ~WpePotential() override;

  void activate_wpe_stage(const WpeStageInfo& stage)
  {
    adapter_.activate_stage(stage);
    N1 = 0;
    N2 = stage.number_of_atoms;
  }

  using Potential::compute;
  void compute(
    Box& box,
    const GPU_Vector<int>& type,
    const GPU_Vector<double>& position,
    GPU_Vector<double>& potential,
    GPU_Vector<double>& force,
    GPU_Vector<double>& virial) override;

  GPU_Vector<float>& get_charge_reference() override { return adapter_.charge(); }
  GPU_Vector<float>& get_bec_reference() override { return adapter_.bec(); }

private:
  WpeForceAdapter adapter_;
};
