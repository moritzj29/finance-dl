FROM python:3
ARG CHROME_DRIVER_VERSION=97.0.4692.71
ARG INCLUDE_BITWARDEN=0
ARG BITWARDEN_VERSION=1.19.1
RUN apt-get update && apt-get upgrade -y
RUN pip install --upgrade pip

# install fake-headers package, required for hiding headless operation
RUN pip install --no-cache-dir git+https://github.com/moritzj29/Fake-Headers.git
# set selenium version explicitly, otherwise v4 is installed automatically
RUN pip install --no-cache-dir selenium==3.141.0 chromedriver-binary==${CHROME_DRIVER_VERSION} finance-dl

# install Bitwarden CLI password manager
WORKDIR /temp
RUN if [ $INCLUDE_BITWARDEN = 1 ] ; \
    then \
        wget -O bw.zip https://github.com/bitwarden/cli/releases/download/v${BITWARDEN_VERSION}/bw-linux-${BITWARDEN_VERSION}.zip \
        && unzip bw.zip \
        && rm bw.zip \
        && chmod +x bw \
        && mv bw /usr/local/bin/bw \
        ; fi

VOLUME [ "/workspace" ]
WORKDIR /workspace
RUN rm -r /temp

# interactive shell
ENTRYPOINT [ "/bin/sh" ]
# ENTRYPOINT [ "/bin/sh", "-c", "while sleep 1000; do :; done" ]
