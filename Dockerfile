FROM fedora:latest

RUN dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm && \
    dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf -y update

RUN dnf install -y autoconf \
                   automake \
                   cmake \
                   freetype-devel \
                   gcc \
                   gcc-c++ \
                   git \
                   libtool \
                   make \
                   nasm \
                   pkgconfig \
                   zlib-devel \
                   numactl \
                   numactl-devel \
                   libxcb \
                   libxcb-devel

# Yasm
RUN cd /usr/local/src \
    && git clone --depth 1 git://github.com/yasm/yasm.git \
    && cd yasm \
    && autoreconf -fiv \
    && ./configure --prefix="/usr/local" \
    && make \
    && make install

# libx264
RUN cd /usr/local/src \
    && git clone --depth 1 https://code.videolan.org/videolan/x264.git \
    && cd x264 \
    && ./configure --prefix="/usr/local" --enable-static \
    && make \
    && make install

# ffmpeg
RUN cd /usr/local/src \
    && git clone --depth 1 git://source.ffmpeg.org/ffmpeg \
    && cd ffmpeg \
    && PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" ./configure --prefix="/usr/local" \
                                                              --extra-cflags="-I/usr/local/include" \
                                                              --extra-ldflags="-L/usr/local/lib" \
                                                              --pkg-config-flags="--static" \
                                                              --enable-gpl \
                                                              --enable-nonfree \
                                                              --enable-libx264 \
                                                              --enable-libxcb \
    && make \
    && make install

# Cleanup
RUN rm -rf /usr/local/src/* \
    && dnf clean all \
    && dnf erase -y autoconf \
                    automake \
                    cmake \
                    freetype-devel \
                    gcc \
                    gcc-c++ \
                    git \
                    libtool \
                    make \
                    nasm \
                    pkgconfig \
                    zlib-devel \
                    numactl-devel \
                    libxcb-devel

ENTRYPOINT ["/usr/local/bin/ffmpeg"]
