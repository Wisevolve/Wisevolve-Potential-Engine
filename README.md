# Wisevolve Potential Engine

This repository contains the public integration layer for Wisevolve Potential Engine (WPE).
The numerical engine is distributed separately as `libwisevolve_potential.so`.

## Contents

- `include/wisevolve_potential_api.h` — stable C ABI shared with host applications;
- `integration/gpumd/` — GPUMD-facing adapter and stage integration;
- `LICENSE`, `NOTICE`, and `LICENSES/` — licensing and attribution.

The repository does not contain the proprietary WPE engine/runtime or CUDA kernels.

## Runtime information

`wpe_get_info()` exposes stable engine metadata. The shared library reports its engine name and
version once when a WPE context is created. The GPUMD adapter prints the provider and, when
available, the project website, citation, and citation DOI. Empty optional metadata fields are
not printed.

For the current release the visible startup metadata is:

```text
Potential engine: Wisevolve Potential Engine 1.0.0
Provider: Wisevolve
```

`project_url`, `citation`, and `citation_doi` are reserved in the ABI and are currently unset.

## GPUMD integration

The standard GPUMD build remains unchanged. WPE support is built with the dedicated
`makefile_wpe` provided by GPUMD.

From the GPUMD `src/` directory:

```bash
make -f makefile_wpe \
  WPE_ROOT=/path/to/Wisevolve-Potential-Engine \
  WPE_SO_ROOT=/path/to/wpe.so \
  CUDA_ARCH="-arch=sm_89"
```

`WPE_ROOT` points to this public repository. `WPE_SO_ROOT` points to the separately
distributed WPE binary package containing `lib/libwisevolve_potential.so`.

The WPE build produces a separate `gpumd-wpe` executable and uses isolated build objects,
leaving the standard GPUMD build unchanged.

## Licensing

- `include/wisevolve_potential_api.h`: BSD-2-Clause;
- `integration/gpumd/`: GPL-3.0-or-later;
- the separately distributed WPE engine: proprietary WPE license.
