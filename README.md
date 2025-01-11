# Disclaimer

- At the point of writing this (11/01/2025), I'm using uv version **0.5.17**, which may not be considered to be a stable release until 1.0 is reached. The installation and the command may change in the future. I will try to keep this as up to date as possible.

# Preparation

- You must know what the python version you need to use to be compatible with all of your dependencies
- After you know the python version, you must know that version of CUDA that you are using. and pick the appropriate one for torch.
- After you know that version of python and cuda to use. go to [pytorch](https://pytorch.org/get-started/previous-versions/) to find which version of torch, torchvision and torchaudio to use.
- If you are not sure, you can also go to [torch](https://download.pytorch.org/whl/torch), [torchvision](https://download.pytorch.org/whl/torchvision) and [torchaudio](https://download.pytorch.org/whl/torchaudio) to find the appropriate version for your python and CUDA version. Search for `cp[your python version]-cp[your python version]`. 
    - Example: `cp38-cp38` for all torch that is compatible with python 3.8
    - Add `+cu[your cuda version]-` for torch that is compatible with CUDA.
        - Example: `+cu124-cp38-cp38` for torch version that is compatible with python 3.8 and CUDA 12.4

- For this setup, I'm using python 3.8, CUDA 12.4 and torch 2.4.1+cu124 on Ubuntu. Change your version accordingly.

# Setup

- `uv init -p [your python version]`. Eg: `uv init -p 3.8`
- `uv python pin [your python version]`. Eg: `uv python pin 3.8`

- Setup torch source, extra flag, index,... using the [official uv website](https://docs.astral.sh/uv/guides/integration/pytorch/#configuring-accelerators-with-optional-dependencies). You can also check the Wayback Machine if you want to see how the installation has changed over time.

- If your code also doesn't need to run on multiple systems, you can also edit the `environment` in `[tool.uv]` to match what you want like in my file. Import `os`, `platform` and `sys` to get the information you need.
    - `platform_system`: `platform.system()`
    - `sys_platform`: `sys.platform`
    - `os_name`: `os.name`
    - Update
        - [20/12/2024](https://github.com/astral-sh/uv/pull/9949):  `platform_system` and `sys_platform` are combined so you only need to declare `sys_platform`. If you want to be sure, you can still put both in your `pyproject.toml` file. The `uv.lock` file will resolve the condition and only have `sys_platform` in the final result. 
- `uv venv`

- activate your environment

## Install torch

- Remove torch from your `requirements.txt` file, you only put torch in `pyproject.toml`

- `uv sync --extra cu124`
    - This only installs torch, torchvision, torchaudio with CUDA
- `uv add -r requirements.txt`
    - This will install the requirements and it will also take the currents version of torch, torchvision, torchaudio into consideration

- If you still have some problem about torch, CUDA or the version of the package, try [clearing the cache](https://docs.astral.sh/uv/concepts/cache/#clearing-the-cache) by `uv cache clean` or `uv cache prune` or `uv cache clean torch` then run the command again from "Install torch". If there are still more problems, just delete the `uv.lock` file and `.venv` folder and run the command again from `uv venv`

## Run your script

- Now hopefully your environment are set and there is no problem. Run `uv run main.py` to check if you can import all package, there is no mismatch version of torch and all torch package use the CUDA version and your GPU is available. The output should be something like this, the device will be different based on your GPU.

    ```txt
    torch.__version__: 2.4.1+cu124
    torchvision.__version__: 0.19.1+cu124
    torchaudio.__version__: 2.4.1+cu124
    torch.cuda.is_available: True

    Device 0 : _CudaDeviceProperties(name='NVIDIA GeForce RTX 3060', major=8, minor=6, total_memory=11931MB, multi_processor_count=28)

    Test calculation
    tensor([[1, 2, 3],
            [2, 4, 6]], device='cuda:0')
    ```

- If there are still some problems, run `uv pip uninstall torch torchvision torchaudio` then run `uv sync --extra cu124` again to reinstall torch and its package. The final result of `uv pip list` should only have torch, torchvision, torchaudio using cuda and other nvidia packages

    ```txt
    Package                  Version
    ------------------------ ------------
    contourpy                1.1.1
    cycler                   0.12.1
    filelock                 3.16.1
    fonttools                4.55.3
    fsspec                   2024.12.0
    importlib-resources      6.4.5
    jinja2                   3.1.5
    joblib                   1.4.2
    kiwisolver               1.4.7
    markupsafe               2.1.5
    matplotlib               3.7.5
    mpmath                   1.3.0
    networkx                 3.1
    numpy                    1.24.4
    nvidia-cublas-cu12       12.4.2.65
    nvidia-cuda-cupti-cu12   12.4.99
    nvidia-cuda-nvrtc-cu12   12.4.99
    nvidia-cuda-runtime-cu12 12.4.99
    nvidia-cudnn-cu12        9.1.0.70
    nvidia-cufft-cu12        11.2.0.44
    nvidia-curand-cu12       10.3.5.119
    nvidia-cusolver-cu12     11.6.0.99
    nvidia-cusparse-cu12     12.3.0.142
    nvidia-nccl-cu12         2.20.5
    nvidia-nvjitlink-cu12    12.4.99
    nvidia-nvtx-cu12         12.4.99
    opencv-python            4.10.0.84
    packaging                24.2
    pandas                   2.0.3
    pillow                   10.4.0
    pyparsing                3.1.4
    python-dateutil          2.9.0.post0
    pytz                     2024.2
    scikit-learn             1.3.2
    scipy                    1.10.1
    seaborn                  0.13.2
    six                      1.17.0
    sympy                    1.13.3
    threadpoolctl            3.5.0
    torch                    2.4.1+cu124
    torchaudio               2.4.1+cu124
    torchvision              0.19.1+cu124
    tqdm                     4.67.1
    triton                   3.0.0
    typing-extensions        4.12.2
    tzdata                   2024.2
    zipp                     3.20.2
    ```
