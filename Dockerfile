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
COPY --from=nodebuild /build/bw /usr/local/bin/bw
RUN chmod +x /usr/local/bin/bw
RUN apt-get update && apt-get upgrade -y
RUN pip install --upgrade pip

# install fake-headers package, required for hiding headless operation
RUN pip install --no-cache-dir git+https://github.com/moritzj29/Fake-Headers.git
# custom Selenium Requests enabled for remote webdrivers
RUN pip install --no-cache-dir git+https://github.com/moritzj29/Selenium-Requests.git
RUN pip install --no-cache-dir git+https://github.com/moritzj29/finance-dl.git
# RUN pip install --no-cache-dir finance-dl




VOLUME [ "/workspace" ]
WORKDIR /workspace

# interactive shell
ENTRYPOINT [ "/bin/sh" ]
# ENTRYPOINT [ "/bin/sh", "-c", "while sleep 1000; do :; done" ]
