FROM python:3
ARG CHROME_DRIVER_VERSION=97.0.4692.71
RUN apt-get update && apt-get upgrade -y
RUN pip install --upgrade pip

# install fake-headers package, required for hiding headless operation
RUN pip install --no-cache-dir git+https://github.com/moritzj29/Fake-Headers.git
# set selenium version explicitly, otherwise v4 is installed automatically
RUN pip install --no-cache-dir selenium==3.141.0 chromedriver-binary==${CHROME_DRIVER_VERSION} finance-dl

VOLUME [ "/workspace" ]

# interactive shell
ENTRYPOINT [ "/bin/sh" ]
# ENTRYPOINT [ "/bin/sh", "-c", "while sleep 1000; do :; done" ]
