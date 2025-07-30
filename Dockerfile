# Base Image
FROM fedora:40

# 1. Setup home directory, environment variables
RUN mkdir -p /bot /tgenc && chmod 777 /bot
WORKDIR /bot
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Lagos
ENV TERM=xterm

# 2. Install dependencies & build tools (gcc, python3-devel) for all platforms
RUN dnf -y update \
    && dnf -y install git aria2 bash xz wget curl pv jq python3-pip mediainfo \
        psmisc procps-ng qbittorrent-nox gcc python3-devel \
    && python3 -m pip install --upgrade pip setuptools

# 3. Install latest ffmpeg
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/64/) \
    && wget -q https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n7.1-latest-linux${arch}-gpl-7.1.tar.xz \
    && tar -xvf *xz \
    && cp *7.1/bin/* /usr/bin \
    && rm -rf *xz *7.1

# 4. Copy files from repo to home directory
COPY . .

# 5. Install python3 requirements
RUN pip3 install -r requirements.txt

# 6. Optional: remove build tools (if image size matters), clean up
RUN dnf -y remove gcc python3-devel || true \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# 7. Start bot
CMD ["bash","run.sh"]
