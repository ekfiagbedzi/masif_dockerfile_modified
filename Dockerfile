# Use PyMesh as the base image
FROM pymesh/pymesh

# Install system dependencies
RUN apt-get update && \
    apt-get install -y wget git unzip cmake vim libgl1-mesa-glx dssp

# Set up APBS installation directory
RUN mkdir /install
WORKDIR /install

# Clone and build APBS
RUN git clone https://github.com/Electrostatics/apbs-pdb2pqr
WORKDIR /install/apbs-pdb2pqr
RUN git checkout b3bfeec && \
    git submodule init && \
    git submodule update && \
    cmake -DGET_MSMS=ON apbs && \
    make && \
    make install

# Copy MSMS from APBS externals
RUN cp -r /install/apbs-pdb2pqr/apbs/externals/mesh_routines/msms/msms_i86_64Linux2_2.6.1 /root/msms/

# Install pip for Python 3
RUN curl https://bootstrap.pypa.io/pip/3.6/get-pip.py -o get-pip.py && \
    python get-pip.py

# Install PDB2PQR
WORKDIR /install/apbs-pdb2pqr/pdb2pqr
RUN git checkout b3bfeec && \
    python2.7 scons/scons.py install

# Fix permissions for /root/pdb2pqr/pdb2pqr.py
RUN chmod -R 777 /root/

# Set environment variables (corrected syntax)
ENV MSMS_BIN=/usr/local/bin/msms
ENV APBS_BIN=/usr/local/bin/apbs
ENV MULTIVALUE_BIN=/usr/local/share/apbs/tools/bin/multivalue
ENV PDB2PQR_BIN=/root/pdb2pqr/pdb2pqr.py

# Install Reduce (for protonation)
WORKDIR /install
RUN git clone https://github.com/rlabduke/reduce.git && \
    cd reduce && \
    make install && \
    mkdir -p build/reduce && \
    cd build/reduce && \
    cmake /install/reduce/reduce_src && \
    cd /install/reduce/reduce_src && \
    make && \
    make install

# Install Python libraries
RUN pip3 install matplotlib ipython Biopython sklearn \
    tensorflow==1.12 networkx open3d==0.8.0.0 dask==1.2.2 packaging

# Default command
CMD ["bash"]