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

The standard GPUMD build remains unchanged. A WPE-enabled build uses this repository for the
public adapter and a separate WPE binary package for the shared library. See the GPUMD
`WPE_INTEGRATION.md` file for Make and CMake examples.

## Licensing

- `include/wisevolve_potential_api.h`: BSD-2-Clause;
- `integration/gpumd/`: GPL-3.0-or-later;
- the separately distributed WPE engine: proprietary WPE license.
