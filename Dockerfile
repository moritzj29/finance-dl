FROM python:3
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
