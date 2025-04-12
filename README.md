# ffmpeg-rockchip
Docker image for running a ffmpeg with hardware acceleration, optimised for Rockchip SoCs. This is a ideal base image to build your video technology on top.

## Features

if you do not have a singe board computer with a rockchip SoC, then it is probably best to use [linuxserver/ffmpeg](https://hub.docker.com/r/linuxserver/ffmpeg) instead.


| Feature                     | VAAPI (`linuxserver/ffmpeg`)        | Rockchip MPP / V4L2 Request (`ffmpeg-rockchip`) |
|----------------------------|--------------------------------------|--------------------------------------------------|
| **Acceleration Backend**   |  ⚠️ Intel, AMD, some ARM (via Mesa)     | ✅ Rockchip-specific drivers (MPP, RGA, VPU)        |
| **Compatibility**          |  ⚠️ Cross-platform (x86/ARM64)          | ✅ Optimized only for Rockchip SoCs                |
| **Driver Source**          |  ⚠️ Mesa, DRM, kernel VAAPI             | ✅ Rockchip SDK drivers (`rk-mpp`, `rga`, etc.)     |
| **FFmpeg Support**         |  ⚠️ Mainline FFmpeg + VAAPI             | ✅  patched/custom FFmpeg build            |
| **Performance (ROCK 5)**   | ❗ Often **lower** / fallback to CPU | ✅ Best possible (full VPU offload)              |



## Usage

### Install from the command line

```sh
docker pull ghcr.io/daniel-samson/ffmpeg-rockchip:main
```

Yuo can run it
```sh
docker run --rm \
  --device /dev/mpp_service \
  --device /dev/rga \
  --device /dev/video0 \
  -v $(pwd):/videos \
  rockchip-ffmpeg \
  ffmpeg -hwaccel rkmpp -i /videos/input.mp4 -c:v h264_rkmpp -b:v 4M /videos/output.mp4
```

### Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/daniel-samson/ffmpeg-rockchip:main

CMD ["ffmpeg", "-version"]
```
