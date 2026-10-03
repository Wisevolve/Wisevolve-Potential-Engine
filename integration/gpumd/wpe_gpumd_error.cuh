/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Copyright (c) 2026 Wisevolve.
 */

#pragma once
#include <cstdio>
#include <cstdlib>

[[noreturn]] inline void gpumd_wpe_fatal(const char* message)
{
  std::fprintf(
    stderr,
    "GPUMD/WPE integration error: %s\n",
    message != nullptr ? message : "unknown failure");
  std::fflush(stderr);
  std::exit(EXIT_FAILURE);
}

[[noreturn]] inline void gpumd_wpe_api_failure(const int status)
{
  std::fprintf(
    stderr,
    "GPUMD/WPE integration error: WPE API returned failure status %d.\n",
    status);
  std::fflush(stderr);
  std::exit(EXIT_FAILURE);
}
