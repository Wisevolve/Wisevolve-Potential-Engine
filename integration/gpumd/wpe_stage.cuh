/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Portions copyright 2017-2026 Zheyong Fan and GPUMD contributors.
 * Modifications and additional integration code copyright (c) 2026 Wisevolve.
 */

#pragma once
#ifndef GPUMD_WPE_ENABLED
#error "wpe_stage.cuh is only for GPUMD_WPE_ENABLED builds"
#endif

#include "wisevolve_potential_api.h"
#include <cstdint>
#include <string>
#include <vector>

/*
 * Incremental GPUMD -> WPE stage state.
 *
 * GPUMD already parses run.in sequentially.  The WPE integration therefore
 * observes the same token stream instead of pre-scanning an input container and trying
 * to replay a parallel stage plan.  Persistent commands (ensemble/kspace/
 * dftd3) update state; run-scoped consumers accumulate facts until a direct
 * stage command is reached.  The resulting WpeStageInfo is consumed
 * immediately by wpe_activate_stage().
 */
class WpeGpumdStageState
{
public:
  WpeGpumdStageState() = default;

  // Returns true when this command starts a WPE stage and fills `stage`.
  bool process_command(
    const std::vector<std::string>& tokens,
    int current_number_of_atoms,
    WpeStageInfo& stage);

private:
  std::string ensemble_name_;
  uint32_t pimd_beads_ = 0u;
  bool pimd_eco_configuration_ = false;
  uint32_t qnep_kspace_method_ = WPE_QNEP_KSPACE_PPPM;

  bool dftd3_enabled_ = false;
  std::string dftd3_functional_;
  float dftd3_rc_potential_ = 0.0f;
  float dftd3_rc_coordination_number_ = 0.0f;

  uint64_t pending_run_facts_ = 0u;
};
