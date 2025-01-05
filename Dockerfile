# Read the doc: https://huggingface.co/docs/hub/spaces-sdks-docker
# you will also find guides on how best to write your Dockerfile

# Build with the command:
# docker build --platform linux/amd64 -t ebook2audiobookgpu .
# docker build --network=host --platform linux/amd64 -t ebook2audiobookgpu .
# docker build --network=host -t image_name .

# docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
# docker run --rm --gpus all ebook2audiobookgpu nvidia-smi -l 30 

# docker compose -f compose.yml up -d

# ARG BASE=nvidia/cuda:11.8.0-base-ubuntu22.04
ARG BASE=nvidia/cuda:12.6.3-cudnn-runtime-ubuntu24.04
FROM ${BASE}

ARG USER=user

ENV TZ=Americas/New_York \
    DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install tzdata

# Create and switch to a non-root user
RUN useradd -m -u 1001 user
ARG USER
USER ${user}
ENV PATH="/home/user/.local/bin:$PATH"

# Set a working directory for temporary operations
WORKDIR /app

# Install system packages
USER root
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y wget git calibre ffmpeg python3.12 python3-full pipx pip libmecab-dev mecab mecab-ipadic && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# RUN pip3 install torch torchaudio --extra-index-url https://download.pytorch.org/whl/cu118
# RUN rm -rf /root/.cache/pip


# Clone the GitHub repository and set it as the working directory
USER root
RUN apt-get update && apt-get install -y git && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN rm -rf /root/.cache/pip
# RUN pip cache purge
ARG USER
USER ${user}
RUN git clone https://github.com/DrewThomasson/ebook2audiobook.git /home/user/app

# Set the cloned repository as the base working directory
WORKDIR /home/user/app

# RUN pip cache purge
# RUN pip install torch>=2.1
# RUN pip cache purge
# RUN pip install nvidia-cublas-cu11==11.11.3.6 --extra-index-url https://download.pytorch.org/whl/nightly/nvidia-cublas-cu11/
# RUN pip cache purge
# RUN pip install torch torchaudio --extra-index-url https://download.pytorch.org/whl/cu118
# RUN pip cache purge
#Install Python dependences from the ebook2audiobook repo
# RUN pip install pip==20.0.2 --break-system-packages
# RUN wget https://files.pythonhosted.org/packages/97/3f/c4c51c55ff8487f2e6d0e618dba917e3c3ee2caae6cf0fbb59c9b1876f2e/tzlocal-5.2-py3-none-any.whl
# RUN pip install tzlocal-5.2-py3-none-any.whl --break-system-packages
# RUN wget https://files.pythonhosted.org/packages/9e/4c/2ba0b385e5f64ca4ddb0c10ec52ddf881bc4521f135948786fc339d1d6c8/marisa_trie-1.2.1-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
# RUN pip install marisa_trie-1.2.1-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl --break-system-packages
# RUN pipx install --no-cache-dir --upgrade -r requirements.txt
# RUN pipx ensurepath
# RUN pipx inject -r requirements.txt
# RUN xargs -a requirements.txt pipx install
# RUN cat requirements.txt | cut -d'=' -f1 | xargs -n 1 pipx install --include-deps
# Install Python packages using pip
# RUN python3 -m venv venv
# RUN . venv/bin/activate
# RUN python3 -m pip install --upgrade pip
# RUN pip3 install -r requirements.txt
# RUN /home/${USER}/app/venv/bin/pip install --upgrade pip
# Add this before pip install -r requirements.txt
# RUN /home/${USER}/app/venv/bin/pip hash --algorithm sha256 $(cat requirements.txt | grep -v '^#' | cut -d= -f1) > requirements.txt.new
# RUN mv requirements.txt.new requirements.txt
# RUN /home/${USER}/app/venv/bin/pip install -r requirements.txt
# RUN /home/${USER}/app/venv/bin/pip install -r requirements.txt
# RUN pip install --no-cache-dir --upgrade -r requirements.txt --break-system-packages


#   && pip install torch torchaudio --extra-index-url https://download.pytorch.org/whl/cu118 \

ARG USER
RUN python3 -m venv /home/${USER}/.venv \
  && . /home/${USER}/.venv/bin/activate \
  && pip install --upgrade pip \
  && pip install -r requirements.txt


# USER root
# RUN ln -sf /usr/bin/python3 /usr/bin/python

# Do a test run to make sure that the base models are pre-downloaded and baked into the image
# RUN echo "This is a test sentence." > test.txt
# RUN python app.py --headless --ebook test.txt
# RUN rm test.txt

# Expose the required port
EXPOSE 7860

# Start the Gradio app from the repository
CMD ["python", "app.py"]
