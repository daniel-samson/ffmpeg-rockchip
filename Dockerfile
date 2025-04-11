FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install base build tools and dependencies
RUN apt-get update && apt-get install -y \
    autoconf automake build-essential cmake libtool pkg-config \
    yasm nasm git curl wget unzip libdrm-dev libx264-dev \
    libjpeg-dev zlib1g-dev \
    ca-certificates sudo nano vim \
    ninja-build meson \
    && apt-get clean

WORKDIR /opt

### Clone and build MPP (Media Process Platform)
RUN git clone -b jellyfin-mpp --depth=1 https://github.com/nyanmisaka/mpp.git rkmpp && \
    mkdir -p rkmpp/build && cd rkmpp/build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_TEST=OFF .. && \
    make -j$(nproc) && make install

### Clone and build RGA (Raster Graphic Acceleration)
RUN mkdir -p ~/dev && cd ~/dev
RUN git clone -b jellyfin-rga --depth=1 https://github.com/nyanmisaka/rk-mirrors.git rkrga
RUN meson setup rkrga rkrga_build \
    --prefix=/usr \
    --libdir=lib \
    --buildtype=release \
    --default-library=shared \
    -Dcpp_args=-fpermissive \
    -Dlibdrm=false \
    -Dlibrga_demo=false
RUN meson configure rkrga_build
RUN ninja -C rkrga_build install

### Clone and build Rockchip-optimized FFmpeg
RUN git clone --depth=1 https://github.com/nyanmisaka/ffmpeg-rockchip.git ffmpeg && \
    cd ffmpeg && \
    ./configure \
        --prefix=/usr/local \
        --enable-gpl \
        --enable-version3 \
        --enable-libdrm \
        --enable-rkmpp \
        --enable-rkrga \
        --enable-v4l2-request \
        --enable-libx264 \
        --enable-nonfree \
        --enable-shared \
        --disable-static \
        --disable-debug \
    && make -j$(nproc) && make install

# Clean up build dependencies if desired (optional)
RUN apt-get autoremove -y && apt-get clean

# Show ffmpeg version
CMD ["ffmpeg", "-version"]
