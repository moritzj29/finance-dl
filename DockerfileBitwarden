# build Bitwarden CLI password manager
# -> no official binary for arm64 platform yet
FROM node:lts as nodebuild
# always use lts versions for production (=even version number)
WORKDIR /build
RUN npm install -g @bitwarden/cli \
    && npm install -g pkg \
    && pkg /usr/local/lib/node_modules/@bitwarden/cli --output ./bw

FROM python:3
COPY --from=nodebuild /build/bw /usr/local/bin/bw
RUN chmod +x /usr/local/bin/bw
RUN apt-get update && apt-get upgrade -y

RUN pip install --upgrade pip && pip install --no-cache-dir \
    # install fake-headers package, required for hiding headless operation
    # updated with more recent browser versions
    git+https://github.com/moritzj29/Fake-Headers.git \
    selenium-requests \
    # finance-dl fork with Docker support and Bitwarden CLI integration
    git+https://github.com/moritzj29/finance-dl.git

VOLUME [ "/workspace" ]
WORKDIR /workspace

# interactive shell
ENTRYPOINT [ "/bin/sh" ]
