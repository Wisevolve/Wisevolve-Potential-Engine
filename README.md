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

## Build GPUMD with WPE

Clone GPUMD and the WPE repository:

```bash
git clone https://github.com/brucefan1983/GPUMD.git

git clone -b dev \
  https://github.com/Wisevolve/Wisevolve-Potential-Engine.git
```

Copy the downloaded WPE binary package to the same directory and extract it:

```bash
cp /path/to/Wisevolve-Potential-Engine-1.0.0-linux-cu128-x86_64.tar.gz .

tar -xzf \
  Wisevolve-Potential-Engine-1.0.0-linux-cu128-x86_64.tar.gz
```

The directory should now look like:

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

Replace `sm_86` with the CUDA architecture appropriate for your GPU.

After compilation, the WPE-enabled executable is:

```text
GPUMD/src/gpumd-wpe
```

You can verify that the WPE shared library is correctly linked with:

```bash
ldd ./gpumd-wpe | grep wisevolve
```

## Licensing

- `include/wisevolve_potential_api.h`: BSD-2-Clause;
- `integration/gpumd/`: GPL-3.0-or-later;
- the separately distributed WPE engine: proprietary WPE license.
