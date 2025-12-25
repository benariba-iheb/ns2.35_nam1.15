# Use multi-stage build to keep final image small
FROM ubuntu:22.04 AS base

# environement variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    CC=gcc-4.8 \
    CXX=g++-4.8 \ 
    PATH=$PATH:/ns-allinone-2.35/tclcl-1.20/:/tmp/ns-allinone-2.35/ns-2.35/bin/:/tmp/ns2/ns-allinone-2.35/ns-2.35/tcl/http:/ns-allinone-2.35/lib/tcl8.5:/ns-allinone-2.35/tcl8.5.10/library/http:/ns-allinone-2.35/include:/ns-allinone-2.35/bin:/ns-allinone-2.35/tcl8.5.10/unix:/ns-allinone-2.35/tk8.5.10/unix \ 
    LD_LIBRARY_PATH=/ns-allinone-2.35/otcl-1.14:/tmp/ns-allinone-2.35/tcl8.5.10/generic:/tmp/ns-allinone-2.35/tcl8.5.10/tests:/ns-allinone-2.35/tcl8.5.10/library/http1.0:/ns-allinone-2.35/tcl8.5.10/library/http:/ns-allinone-2.35/tcl8.5.10/library:/ns-allinone-2.35/tcl8.5.10/unix:/ns-allinone-2.35/otcl-1.14:/ns-allinone-2.35/lib  

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 ca-certificates && \
    echo "deb http://in.archive.ubuntu.com/ubuntu bionic main universe" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc-4.8 g++-4.8 \
        make \ 
        libx11-dev \
        libxmu-dev \
        libxpm-dev \
        libxaw7-dev \
        libxft-dev \
        libxinerama-dev \
        libxrandr-dev \
        libxss-dev \
        libxcursor-dev \
        libxext-dev \
        libxrender-dev \
        libxv-dev \
        libxfixes-dev \
        libxshmfence-dev \
        libxi-dev \
        wget \
        ca-certificates\
        nam \
        xauth \
        x11-apps && \
    apt-get clean 


# Set gcc-4.8 as the system default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 100 && \
    update-alternatives --set gcc /usr/bin/gcc-4.8 && \
    update-alternatives --set g++ /usr/bin/g++-4.8


# copy ns2 source
COPY ns-allinone-2.35/ /ns-allinone-2.35/
RUN cd /ns-allinone-2.35/ &&\
    ./install 


#building tclcl
RUN cd /ns-allinone-2.35/tclcl-1.20 && \
    ./configure \
    --with-tcl=/ns-allinone-2.35/tcl8.5.10/ &&\
    make clean &&\
    make && \
    make install 

  
# compiling NS2 and NAM cuncurrently:

#building the ns2 application
FROM base AS ns2
RUN cd /ns-allinone-2.35/ns-2.35 && \ 
    ./configure \
    --with-tcl=/ns-allinone-2.35/tcl8.5.10/unix \
    --with-tcl-ver=8.5 \
    --with-tk=/ns-allinone-2.35/tk8.5.10/unix \
    --with-tk-ver=8.5 \
    --with-tclcl=/ns-allinone-2.35/tclcl &&\
    make clean &&\
    make

#building the nam simulator 
FROM base AS nam
RUN cd /ns-allinone-2.35/nam-1.15/ &&\
    make clean &&\l
    make


FROM base AS builder
COPY --from=ns2 /ns-allinone-2.35/ns-2.35/ns /ns-allinone-2.35/ns-2.35/ns
COPY --from=nam /ns-allinone-2.35/nam-1.15/nam /ns-allinone-2.35/nam-1.15/nam


#work directory:
WORKDIR /ns-allinone-2.35/

#setting env variables and accessibility for the container:
RUN echo 'export TCLLIBPATH="/ns-allinone-2.35/tcl8.5.10/library"' >> /etc/bash.bashrc && \
    echo 'export LD_LIBRARY_PATH="/ns-allinone-2.35/tcl8.5.10/unix:/ns-allinone-2.35/tk8.5.10/unix:$LD_LIBRARY_PATH"' >> /etc/bash.bashrc && \
    echo 'export TCL_LIBRARY="/ns-allinone-2.35/tcl8.5.10/library"' >> /etc/bash.bashrc && \
    echo 'export TK_LIBRARY="/ns-allinone-2.35/tk8.5.10/library"' >> /etc/bash.bashrc && \
    echo 'export PATH="/ns-allinone-2.35/bin:$PATH"' >> /etc/bash.bashrc &&\
    ln -sf /ns-allinone-2.35/ns-2.35/ns /usr/bin &&\
    ln -sf /ns-allinone-2.35/nam-1.15/nam /usr/local/bin/nam


# Default command: open an interactive shell
CMD ["/bin/bash"]
