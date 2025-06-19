# Docker Environment for NicheCompass

This Docker container provides a complete environment for spatial transcriptomics analysis with NicheCompass, including:

- Ubuntu latest base image
- Miniconda3 with Python 3.9
- PyTorch with CUDA support
- JAX with CUDA support
- Squidpy for spatial omics analysis
- JupyterLab for interactive development
- All dependencies from `environment.yaml`

## Prerequisites

- Docker installed on your system
- NVIDIA Docker runtime (for GPU support)
- The `environment.yaml` file in the same directory as the Dockerfile

## (re)-Building the Image

Build the Docker image from the directory containing both `Dockerfile` and `environment.yaml`:

```bash
docker build -t spatial-env .
```

This will:
1. Create an Ubuntu-based container with Miniconda
2. Install the conda environment from `environment.yaml`
3. Install JAX with CUDA support, Squidpy, and JupyterLab
4. Configure JupyterLab to start automatically

## Pull the Image directly
```bash
docker pull stanfish06/spatial-env:v0.1.0
```

## Running the Container

### Option 1: Run with JupyterLab (Recommended)

Start the container with JupyterLab server and mount your current directory:

```bash
docker run -p 8888:8888 -v $(pwd):/home/conda/workspace spatial-env:v0.1.0
```

Then open your browser and go to: `http://localhost:8888`

### Option 2: Run in Background

Run the container in detached mode:

```bash
docker run -d -p 8888:8888 -v $(pwd):/home/conda/workspace spatial-env:v0.1.0
```

### Option 3: Interactive Shell

If you want to access the container with a bash shell instead of starting JupyterLab:

```bash
docker run -it -v $(pwd):/home/conda/workspace spatial-env:v0.1.0 /bin/bash
```

Then manually start JupyterLab if needed:
```bash
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
```

## GPU Support

If you have NVIDIA GPUs and want to use them inside the container:

```bash
docker run --gpus all -p 8888:8888 -v $(pwd):/home/conda/workspace spatial-env:v0.1.0
```

## Volume Mounting

The container is configured to use `/home/conda/workspace` as the working directory. When you mount your local directory:

```bash
-v $(pwd):/home/conda/workspace
```

- Your local files will be accessible inside the container
- Any changes made in JupyterLab will be saved to your local filesystem
- Notebooks and data will persist after the container stops

## Environment Details

The container includes:

- **Base**: Ubuntu latest
- **Python**: 3.9 (via Miniconda)
- **Conda Environment**: `nichecompass` (automatically activated)
- **PyTorch**: 2.0.0 with CUDA 11.7 support
- **JAX**: 0.4.7 with CUDA 11 and cuDNN 8.6 support
- **Additional Tools**: Squidpy, JupyterLab, bedtools
- **Port**: 8888 (for JupyterLab)

## Stopping the Container

To stop a running container:

```bash
# Find the container ID
docker ps

# Stop the container
docker stop <container_id>
```

Or if running in detached mode, you can stop all containers:

```bash
docker stop $(docker ps -q)
```

## Use jupyter server in Vscode
In a jupyter notebook:
- select existing jupyter server
- input url (e.g. http://127.0.0.1:8888/lab) and token (e.g. 012ee585c5982ea95f8a0941df84986ab723e0622732b129)

## Troubleshooting

### JupyterLab not accessible
- Make sure port 8888 is not being used by another application
- Check that the container is running: `docker ps`
- Verify port mapping: `-p 8888:8888`

### Files not persisting
- Ensure you're using volume mounting: `-v $(pwd):/home/conda/workspace`
- Check that you have write permissions in the mounted directory

### GPU not detected
- Install NVIDIA Docker runtime
- Use the `--gpus all` flag when running the container
- Verify GPU availability: `nvidia-smi` (on host system)

## Customization

To modify the environment:
1. Edit the `environment.yaml` file to add/remove conda packages
2. Modify the Dockerfile to add additional pip packages or system dependencies
3. Rebuild the image: `docker build -t spatial-env .`
