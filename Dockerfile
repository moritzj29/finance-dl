FROM python:3
RUN apt-get update && apt-get upgrade -y
RUN pip install --upgrade pip

# install fake-headers package, required for hiding headless operation
RUN pip install --no-cache-dir git+https://github.com/moritzj29/Fake-Headers.git
# set selenium version explicitly, otherwise v4 is installed automatically
RUN pip install --no-cache-dir selenium==3.141.0 chromedriver-binary==96.0.4664.45.0 finance-dl

VOLUME [ "/workspace" ]

ENTRYPOINT [ "/bin/sh", "-c", "while sleep 1000; do :; done" ]
