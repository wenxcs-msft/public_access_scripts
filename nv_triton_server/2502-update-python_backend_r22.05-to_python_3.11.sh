#!/bin/bash
# Wenxiang Hu @ MSFT

# docker run -idt --name tritonserver2205test nvcr.io/nvidia/tritonserver:22.05-py3
# docker exec -it tritonserver2205test bash

# Create Working Dir
mkdir -p /opt/tritonserver/python

# Checkout branch
git clone https://github.com/triton-inference-server/python_backend -b r22.05 /opt/tritonserver/python/python_backend

# Install Conda
wget -O /opt/tritonserver/python/Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash /opt/tritonserver/python/Miniforge3.sh -b -p "/opt/tritonserver/python/conda"
rm /opt/tritonserver/python/Miniforge3.sh
apt update && apt install rapidjson-dev libarchive-dev zlib1g-dev -y
/opt/tritonserver/python/conda/bin/conda install python=3.11 cmake numpy -y
# /opt/tritonserver/python/conda/bin/conda run -n base python --version

# Re-make the build folder
rm -rf /opt/tritonserver/python/python_backend/build && mkdir -p /opt/tritonserver/python/python_backend/build

# Fix invalid boost url
sed -i  's/https:\/\/boostorg.jfrog.io\/artifactory\/main\/release\/1.76.0\/source\/boost_1_76_0.tar.gz/https:\/\/archives.boost.io\/release\/1.76.0\/source\/boost_1_76_0.tar.gz/g' /opt/tritonserver/python/python_backend/CMakeLists.txt

# Fix compiling issue to update pybind from 2.6 to 2.12 for python 3.11
sed -i  's/2\.6/2.12/g' /opt/tritonserver/python/python_backend/CMakeLists.txt

# Cmake .
/opt/tritonserver/python/conda/bin/conda run -n base cmake -S/opt/tritonserver/python/python_backend/ -B/opt/tritonserver/python/python_backend/build  -DTRITON_ENABLE_GPU=ON -DTRITON_BACKEND_REPO_TAG=r22.05 -DTRITON_COMMON_REPO_TAG=r22.05 -DTRITON_CORE_REPO_TAG=r22.05 -DCMAKE_INSTALL_PREFIX=/opt/tritonserver

# Build
/opt/tritonserver/python/conda/bin/conda run -n base cmake --build /opt/tritonserver/python/python_backend/build

# Install 
/opt/tritonserver/python/conda/bin/conda run -n base cmake --install /opt/tritonserver/python/python_backend/build --prefix /opt/tritonserver/


# Test
# mkdir -p models/add_sub/1/
# cp examples/add_sub/model.py models/add_sub/1/model.py
# cp examples/add_sub/config.pbtxt models/add_sub/config.pbtxt
# /opt/tritonserver/bin/tritonserver --model-repository=`pwd`/models
# /opt/tritonserver/python/conda/bin/conda install tritonclient -y
