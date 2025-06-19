# Use the latest Ubuntu image as base
FROM ubuntu:latest

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install essential packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    bzip2 \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up a non-root user
RUN useradd -m -s /bin/bash conda && \
    echo 'conda ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the conda user
USER conda
WORKDIR /home/conda

# Download and install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    /bin/bash miniconda.sh -b -p /home/conda/miniconda3 && \
    rm miniconda.sh

# Add conda to PATH
ENV PATH="/home/conda/miniconda3/bin:${PATH}"

# Initialize conda
RUN conda init bash

# Update conda
RUN conda update -n base -c defaults conda

# Copy the environment.yaml file
COPY environment.yaml /home/conda/environment.yaml

# Create conda environment from the yaml file
RUN conda env create -f /home/conda/environment.yaml

# Install jaxlib with CUDA support, squidpy, and jupyterlab in the nichecompass environment
RUN /bin/bash -c "source /home/conda/miniconda3/bin/activate nichecompass && \
    pip install jaxlib==0.4.7+cuda11.cudnn86 -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html && \
    pip install nichecompass[all] && \
    pip install squidpy jupyterlab omnipath"

# Activate the environment by default
RUN echo "conda activate nichecompass" >> /home/conda/.bashrc

# Set environment variables to make the conda environment active
ENV CONDA_DEFAULT_ENV=nichecompass
ENV PATH="/home/conda/miniconda3/envs/nichecompass/bin:${PATH}"

# Expose port 8888 for Jupyter
EXPOSE 8888

# Set the default command to start Jupyter Lab
CMD ["/bin/bash", "-c", "source /home/conda/miniconda3/bin/activate nichecompass && jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root"]
