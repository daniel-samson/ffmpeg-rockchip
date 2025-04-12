FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install base build tools and dependencies
RUN apt-get update && apt-get install -y \
    autoconf automake build-essential cmake libtool pkg-config \
    yasm nasm git curl wget unzip libdrm-dev libx264-dev \
    libjpeg-dev zlib1g-dev ca-certificates sudo nano vim \
    && apt-get clean

WORKDIR /opt

# Clone and build FFmpeg with V4L2 Request support
RUN git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg && \
    cd ffmpeg && \
    ./configure \
        --prefix=/usr/local \
        --enable-gpl \
        --enable-version3 \
        --enable-libdrm \
        --enable-libx264 \
        --enable-v4l2-request \
        --enable-nonfree \
        --enable-shared \
        --disable-static \
        --disable-debug && \
    make -j$(nproc) && make install

# Clean up build dependencies if desired (optional)
RUN apt-get autoremove -y && apt-get clean

ENV LD_LIBRARY_PATH=/usr/local/lib

# Show ffmpeg version
CMD ["ffmpeg", "-version"]
