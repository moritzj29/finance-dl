# build Bitwarden CLI password manager
# -> possible to run natively on arm64 platform
FROM node:lts as nodebuild
# always use lts versions for production (=even version number)
WORKDIR /build
RUN npm install -g @bitwarden/cli \
    && npm install -g pkg \
    && pkg /usr/local/lib/node_modules/@bitwarden/cli --output ./bw
# takes current platform or sepcify via
# --targets latest-linux-arm64

FROM python:3
ARG CHROME_DRIVER_VERSION=97.0.4692.71
COPY --from=nodebuild /build/bw /usr/local/bin/bw
RUN chmod +x /usr/local/bin/bw
RUN apt-get update && apt-get upgrade -y
RUN pip install --upgrade pip

# install fake-headers package, required for hiding headless operation
RUN pip install --no-cache-dir git+https://github.com/moritzj29/Fake-Headers.git
# set selenium version explicitly, otherwise v4 is installed automatically
RUN pip install --no-cache-dir selenium==3.141.0 chromedriver-binary==${CHROME_DRIVER_VERSION} finance-dl




VOLUME [ "/workspace" ]
WORKDIR /workspace

# interactive shell
ENTRYPOINT [ "/bin/sh" ]
# ENTRYPOINT [ "/bin/sh", "-c", "while sleep 1000; do :; done" ]
