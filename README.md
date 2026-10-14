# Wisevolve Potential Engine

This repository contains the public integration layer for Wisevolve Potential Engine (WPE).
The numerical engine is distributed separately as `libwisevolve_potential.so`.

## Contents

- `include/wisevolve_potential_api.h` — stable C ABI shared with host applications;
- `integration/gpumd/` — GPUMD-facing adapter and stage integration;
- `LICENSE`, `NOTICE`, and `LICENSES/` — licensing and attribution.

The repository does not contain the proprietary WPE engine/runtime or CUDA kernels.

## Runtime information

`wpe_get_info()` exposes the engine name, version, and optional release metadata.
The WPE-enabled GPUMD adapter prints the following metadata once, followed by a blank line:

```text
Potential engine: Wisevolve Potential Engine 1.0.0
Citation: Hekai Bu and Zheyong Fan, arXiv:2610.17366 (2026)
Citation DOI: https://doi.org/10.48550/arXiv.2610.17366
```

## Citation

Hekai Bu and Zheyong Fan, *Wisevolve Potential Engine: Machine-Learning Molecular Dynamics
at 100 Million Atom-Steps per Second on a Single GPU*, arXiv:2610.17366 (2026).
https://doi.org/10.48550/arXiv.2610.17366

## Build GPUMD with WPE

Clone GPUMD and the WPE repository:

```bash
git clone https://github.com/brucefan1983/GPUMD.git

git clone https://github.com/Wisevolve/Wisevolve-Potential-Engine.git
```

Select a WPE binary package compatible with your GPU architecture, CUDA runtime, and
system C library, and extract it alongside the cloned repositories. The archive name
depends on the selected build:

```bash
WPE_ARCHIVE="/path/to/your-WPE-1.0.0-binary-package.tar.gz"
tar -xzf "$WPE_ARCHIVE"
```

The build instructions below assume the extracted shared library is under `wpe.so/lib/`.
If your selected package uses another directory name, use that directory as `WPE_SO_ROOT`.
The expected directory layout for this example is:

```text
.
├── GPUMD/
├── Wisevolve-Potential-Engine/
└── wpe.so/
    └── lib/
        ├── libwisevolve_potential.so
        ├── libwisevolve_potential.so.1
        └── libwisevolve_potential.so.1.0.0
```

Check the required files:

```bash
ls Wisevolve-Potential-Engine/include/wisevolve_potential_api.h
ls Wisevolve-Potential-Engine/integration/gpumd/wpe_adapter.cu
ls wpe.so/lib/libwisevolve_potential.so
```

Then enter the GPUMD source directory and compile:

```bash
cd GPUMD/src

make -f makefile_wpe -j4 \
  WPE_ROOT="$(realpath ../../Wisevolve-Potential-Engine)" \
  WPE_SO_ROOT="$(realpath ../../wpe.so)" \
  CUDA_ARCH="-arch=sm_86"
```

Replace `sm_86` with the CUDA architecture appropriate for your GPU (for example,
`sm_120` for an RTX 5090, with a CUDA toolkit that supports it). The GPUMD and WPE copies
of `wisevolve_potential_api.h` must match exactly for the `makefile_wpe` build check.

After compilation, the WPE-enabled executable is:

```text
GPUMD/src/gpumd-wpe
```

You can verify that the WPE shared library is correctly linked with:

```bash
ldd ./gpumd-wpe | grep wisevolve
```

## Compatibility and limitations

WPE is an optional GPUMD potential-evaluation backend with the following
WPE-specific limitations:

- **GPU:** Only one visible GPU is supported; multi-GPU execution is not supported.
- **Potentials:** WPE supports NEP4/NEP4-ZBL, qNEP (PPPM or Ewald), LJ, EAM
  (Zhou 2004 and Dai 2006), and Tersoff 1989, with D3 corrections for eligible
  NEP-family workflows. Other GPUMD potential families and multiple simultaneous
  potentials are not supported by WPE.
- **NEP model shapes:** `l_max_3body` must equal `4`, and ANN hidden width must
  not exceed `256`.
- **PIMD:** Selected NEP4, NEP4-ZBL, and qNEP models are supported. PIMD with
  LJ, EAM, or Tersoff potentials is not supported.
- **Commands and ensembles:** `active`, `dump_observer`, `ensemble ti_liquid`,
  `ensemble ti_spring`, `ensemble ti_rs`, and `ensemble ti_as` are not supported.

To keep the shared-library size manageable, WPE selectively supports model
shapes rather than every configuration accepted by GPUMD. Unsupported WPE
workflows do not automatically fall back to native GPUMD; use its standard
executable instead.

For qNEP simulations using PPPM, per-atom potential energies reported by WPE
may differ from those reported by native GPUMD.

## Licensing

- `include/wisevolve_potential_api.h`: BSD-2-Clause;
- `integration/gpumd/`: GPL-3.0-or-later;
- the separately distributed WPE engine: proprietary WPE license.
