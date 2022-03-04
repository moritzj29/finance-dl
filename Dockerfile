FROM python:3
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
