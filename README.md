# Disclaimer

- At the point of writing this (18/03/2025), I'm using uv version **0.6.7**, which may not be considered to be a stable release until 1.0 is reached. The installation and the command may change in the future. I will try to keep this as up to date as possible.

# Preparation

- You must know what the python version you need to use to be compatible with all of your dependencies
- After you know the python version, you must know that version of CUDA that you want to use, this is not the CUDA version of your machine, I have CUDA 11.5 and I can still use torch with higher version of CUDA. When you install torch in python, it also download another version of cuDNN that fit the CUDA version you want to not interfere with the CUDA in your machine, so when you download torch using CUDA 12.4 it will also download cuDNN version 9.1.0.70, therefore you don't need to worry about CUDA or cuDNN in your machine. You can go to [Compatibility matrix](https://github.com/pytorch/pytorch/blob/main/RELEASE.md#release-compatibility-matrix) to see which pytorch version go with what python version using what CUDA version. I would suggest you use the highest stable CUDA version possible and go down from there if you have some problem.
- After you know that version of python and CUDA to use, you need to know the version of torch to use. The compatibility matrix above also shows the information about which torch version that is compatible with which CUDA version.
- If you are not sure or you want to verify that the combination of python, torch, CUDA version actually work you can also go to [torch](https://download.pytorch.org/whl/torch) to find the appropriate version for your python and CUDA version. Search for `cp[your python version]-cp[your python version]`. If the combination does exist then it is compatible. 
    - Example: `cp310-cp310` for all torch that is compatible with python 3.10
    - Add `+cu[your CUDA version]-` for torch that is compatible with CUDA.
        - Example: `+cu124-cp310-cp310` for torch version that is compatible with python 3.10 and CUDA 12.4
- After you find your torch version, if you need torchvision or torchaudio, go to [torchvision and torchaudio compatibility](https://github.com/pytorch/pytorch/wiki/PyTorch-Versions) to find the compatible version of torchvision and torchaudio with your torch version. Although this doesn't show all minor version so if you want to select the minor version check the next step.
- Go to [Previous verison](https://pytorch.org/get-started/previous-versions/) to find which minor version of torch, torchvision, torchaudio that you want to use. The minor version is the last number in the version. For example, if you want to use torch version 2.4.1, the minor version is 1. The minor version is not that important, but it is better to use the latest minor version to get the latest bug fix and improvement. This has all combination of torch, torchvision, torchaudio with CUDA version that compatible with each other and it's always the most up to date information. Just scroll down until you find your torch version and select one that fit the CUDA version and the minor version that you want to use.
- After you know all of the version that you want to use, you can start setting up your environment. 
- For this setup, I'm using python **3.10**, CUDA **12.4**, torch **2.4.1+cu124**, torchvision **0.19.1+cu124**, torchaudio **2.4.1+cu124** on Ubuntu. Change your version accordingly.

# Setup

- `uv init -p [your python version]`. Eg: `uv init -p 3.10`
- `uv python pin [your python version]`. Eg: `uv python pin 3.10`

- Setup torch source, extra flag, index,... in the `pyproject.toml` file using the [official uv website](https://docs.astral.sh/uv/guides/integration/pytorch/#configuring-accelerators-with-optional-dependencies) or you can just copy [my config](pyproject.toml). Remove all package in the `dependencies` section to only install torch first.

- Beside the config for torch in `pyproject.toml`, you also need to add torch to your `requirements.txt` file. You don't need to specify version or anything else for torch there since uv will follow the `pyproject.toml` file to install torch. 

- If your code also doesn't need to run on multiple systems, you can also edit the `environment` in `[tool.uv]` of the `pyproject.toml` file to match what you want like in my file. Import `os`, `platform` and `sys` to get the information you need.
    - `platform_system`: `platform.system()`
    - `sys_platform`: `sys.platform`
    - `os_name`: `os.name`
    - Update
        - [20/12/2024](https://github.com/astral-sh/uv/pull/9949):  `platform_system` and `sys_platform` are combined so you only need to declare `sys_platform`. If you want to be sure, you can still put both in your `pyproject.toml` file. The `uv.lock` file will resolve the condition and only have `sys_platform` in the final result. 
- `uv venv`

- activate your environment

## Install torch

- `uv sync --extra cu124`
    - This only installs torch, torchvision, torchaudio with CUDA
- `uv add -r requirements.txt`
    - This will install the requirements and it will also take the currents version of torch, torchvision, torchaudio into consideration.

- If you still have some problem about torch, CUDA or the version of the package, try [clearing the cache](https://docs.astral.sh/uv/concepts/cache/#clearing-the-cache) by 
    - `uv cache prune` (removes all unused cache)
    - `uv cache clean torch` (removes all cache entries for the `torch` package)
    - `uv cache clean` (removes all cache)

    Starting from `uv cache prune`, if it fix your problem then you don't need to do the other 2, if not then move on to the next one.
- Run the command again from "Install torch". 
- If there are still more problems, just delete the `uv.lock` file and `.venv` folder and run the command again from `uv venv`

## Run your script

- Now hopefully your environment are set and there is no problem. Run `uv run main.py` to check if you can import all package, there is no mismatch version of torch, all torch package use the CUDA version and your GPU is available. The output should be something like this, the device, torch and CUDA version will be different based on your GPU and installation.

    ```txt
    numpy.__version__: 2.2.4
    matplotlib.__version__: 3.10.1
    pandas.__version__: 2.2.3
    sklearn.__version__: 1.6.1
    cv2.__version__: 4.11.0
    PIL.__version__: 11.1.0
    tqdm.__version__: 4.67.1
    seaborn.__version__: 0.13.2
    scipy.__version__: 1.15.2
    torch.__version__: 2.4.1+cu124
    torchvision.__version__: 0.19.1+cu124
    torchaudio.__version__: 2.4.1+cu124
    torch.cuda.is_available: True

    Device 0 : _CudaDeviceProperties(name='NVIDIA GeForce RTX 3060', major=8, minor=6, total_memory=11931MB, multi_processor_count=28)

    Test calculation
    tensor([[1, 2, 3],
            [2, 4, 6]], device='cuda:0')
    ```

- If there are still some problems, run `uv pip uninstall torch torchvision torchaudio` then run `uv sync --extra cu124` again to reinstall torch and its package. The final result of `uv pip list` should only have torch, torchvision, torchaudio using CUDA, other nvidia packages and the packages from `requirements.txt`. The output should be something like this, the version of the package will be different based on your installation.

    ```txt
    Package                  Version
    ------------------------ ------------
    contourpy                1.3.1
    cycler                   0.12.1
    filelock                 3.18.0
    fonttools                4.56.0
    fsspec                   2025.3.0
    jinja2                   3.1.6
    joblib                   1.4.2
    kiwisolver               1.4.8
    markupsafe               3.0.2
    matplotlib               3.10.1
    mpmath                   1.3.0
    networkx                 3.4.2
    numpy                    2.2.4
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
    opencv-python            4.11.0.86
    packaging                24.2
    pandas                   2.2.3
    pillow                   11.1.0
    pyparsing                3.2.1
    python-dateutil          2.9.0.post0
    pytz                     2025.1
    scikit-learn             1.6.1
    scipy                    1.15.2
    seaborn                  0.13.2
    six                      1.17.0
    sympy                    1.13.3
    threadpoolctl            3.6.0
    torch                    2.4.1+cu124
    torchaudio               2.4.1+cu124
    torchvision              0.19.1+cu124
    tqdm                     4.67.1
    triton                   3.0.0
    typing-extensions        4.12.2
    tzdata                   2025.1
    ```
