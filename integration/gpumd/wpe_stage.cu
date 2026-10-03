/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Portions copyright 2017-2026 Zheyong Fan and GPUMD contributors.
 * Modifications and additional integration code copyright (c) 2026 Wisevolve.
 */

#include "wpe_stage.cuh"
#include "wpe_gpumd_error.cuh"
#include <string>
#include <vector>

namespace {
bool is_direct_stage(const std::string& key)
{
  return key == "run" || key == "minimize" || key == "compute_phonon" ||
    key == "compute_cohesive" || key == "compute_elastic";
}

uint32_t stage_kind_for(const std::string& key)
{
  if (key == "run") return WPE_STAGE_RUN;
  if (key == "minimize") return WPE_STAGE_MINIMIZE;
  if (key == "compute_phonon") return WPE_STAGE_PHONON;
  if (key == "compute_cohesive") return WPE_STAGE_COHESIVE;
  if (key == "compute_elastic") return WPE_STAGE_ELASTIC;
  gpumd_wpe_fatal("unknown stage trigger");
}

bool has_token(const std::vector<std::string>& tokens, const char* needle)
{
  for (const auto& token : tokens) {
    if (token == needle) return true;
  }
  return false;
}

void update_pending_run_facts(const std::vector<std::string>& tokens, uint64_t& facts)
{
  if (tokens.empty()) return;
  const std::string& key = tokens[0];

  if (has_token(tokens, "virial") || has_token(tokens, "jp"))
    facts |= WPE_STAGE_HAS_ATOM_VIRIAL_CONSUMER;

  if (key == "dump_thermo" || key == "dump_xyz" || key == "dump_cg")
    facts |= WPE_STAGE_HAS_SYSTEM_VIRIAL_CONSUMER;

  if (key == "compute_hac" || key == "compute_hnemd" || key == "compute_hnemdec" ||
      key == "compute_shc" || key == "compute_gkma" || key == "compute_hnema" ||
      key == "compute_viscosity" || key == "compute_es" ||
      key == "dump_shock_nemd" || key == "plumed" || key == "active" ||
      key == "dump_observer") {
    facts |= WPE_STAGE_HAS_ATOM_VIRIAL_CONSUMER;
  }

  if (key == "compute_hnemd" || key == "compute_hnema")
    facts |= WPE_STAGE_HAS_HNEMD;
  if (key == "compute_hnemdec") facts |= WPE_STAGE_HAS_HNEMDEC;
  if (key == "mc") facts |= WPE_STAGE_HAS_MC;

  if (key == "dump_xyz" || key == "dump_netcdf") {
    for (size_t i = 1; i < tokens.size(); ++i) {
      if (tokens[i] == "charge") facts |= WPE_STAGE_NEED_CHARGE_OUTPUT;
      if (tokens[i] == "bec") facts |= WPE_STAGE_NEED_BEC_OUTPUT;
    }
  } else if (key == "compute_dpdt") {
    facts |= WPE_STAGE_NEED_BEC_OUTPUT;
  } else if (key == "add_efield") {
    std::string mode = "bec";
    if (tokens.size() == 5 || tokens.size() == 7) mode = tokens.back();
    if (mode == "charge") facts |= WPE_STAGE_NEED_CHARGE_OUTPUT;
    else facts |= WPE_STAGE_NEED_BEC_OUTPUT;
  }
}

bool parse_minimize_box_change(const std::vector<std::string>& tokens)
{
  if (tokens.size() < 5 || tokens[1] != "fire") return false;
  char* end = nullptr;
  const long value = std::strtol(tokens[4].c_str(), &end, 10);
  return end != nullptr && *end == '\0' && value == 1;
}

uint32_t parse_pimd_beads(const std::vector<std::string>& tokens)
{
  if (tokens.size() < 3 || tokens[1] != "pimd") return 0u;
  char* end = nullptr;
  const long value = std::strtol(tokens[2].c_str(), &end, 10);
  if (end == nullptr || *end != '\0' || value < 0 || value > 0xffffffffL)
    gpumd_wpe_fatal("invalid PIMD bead count");
  return static_cast<uint32_t>(value);
}
}

bool WpeGpumdStageState::process_command(
  const std::vector<std::string>& tokens,
  const int current_number_of_atoms,
  WpeStageInfo& stage)
{
  if (tokens.empty()) return false;
  const std::string& key = tokens[0];

  if (key == "ensemble") {
    if (tokens.size() >= 2u) {
      ensemble_name_ = tokens[1];
      pimd_beads_ = parse_pimd_beads(tokens);
      pimd_eco_configuration_ =
        ensemble_name_ == "pimd" && tokens.size() >= 8u &&
        tokens[tokens.size() - 2u] == "eco";
    }
    return false;
  }

  if (key == "kspace") {
    if (tokens.size() == 2u && tokens[1] == "ewald")
      qnep_kspace_method_ = WPE_QNEP_KSPACE_EWALD;
    else if (tokens.size() == 2u && tokens[1] == "pppm")
      qnep_kspace_method_ = WPE_QNEP_KSPACE_PPPM;
    return false;
  }

  if (key == "dftd3") {
    if (tokens.size() == 4u) {
      dftd3_enabled_ = true;
      dftd3_functional_ = tokens[1];
      dftd3_rc_potential_ = static_cast<float>(std::strtod(tokens[2].c_str(), nullptr));
      dftd3_rc_coordination_number_ =
        static_cast<float>(std::strtod(tokens[3].c_str(), nullptr));
    }
    return false;
  }

  if (!is_direct_stage(key)) {
    update_pending_run_facts(tokens, pending_run_facts_);
    return false;
  }

  stage = WpeStageInfo{};
  stage.struct_size = sizeof(stage);
  stage.stage_kind = stage_kind_for(key);
  stage.number_of_atoms = current_number_of_atoms;
  stage.qnep_kspace_method = qnep_kspace_method_;
  stage.dftd3_enabled = dftd3_enabled_ ? 1u : 0u;
  stage.dftd3_functional = dftd3_functional_.empty() ? nullptr : dftd3_functional_.c_str();
  stage.dftd3_rc_potential = dftd3_rc_potential_;
  stage.dftd3_rc_coordination_number = dftd3_rc_coordination_number_;

  if (key == "run") {
    stage.ensemble_name = ensemble_name_.empty() ? nullptr : ensemble_name_.c_str();
    stage.pimd_beads = pimd_beads_;
    stage.facts = pending_run_facts_;
    if (pimd_eco_configuration_)
      stage.facts |= WPE_STAGE_PIMD_ECO_CONFIGURATION;
    pending_run_facts_ = 0u;
  } else if (key == "minimize" && parse_minimize_box_change(tokens)) {
    stage.facts |= WPE_STAGE_MINIMIZE_BOX_CHANGE;
  }

  return true;
}
