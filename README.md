

This fork of `jbms/finance-dl` provides docker images to run `finance-dl` and the required webdriver completely within docker. 

Note: Currently the image uses my own fork of `finance-dl` which adds support for:
- `amazon.de` (PR: #50](https://github.com/jbms/finance-dl/pull/50))
- Bitwarden CLI (optionally)
- Paypal 2FA authentication

Support for Bitwarden CLI is added to fill in passwords and OTP codes when required instead of hardcoding them into config files.

Please check the [original repo's README](https://github.com/jbms/finance-dl) as well.

# finance-dl

- [finance-dl](#finance-dl)
  - [Preparation](#preparation)
    - [Set up Bitwarden CLI](#set-up-bitwarden-cli)
  - [Run downloaders](#run-downloaders)
    - [Conventional (no Bitwarden CLI)](#conventional-no-bitwarden-cli)
    - [Bitwarden CLI](#bitwarden-cli)
  - [Shutting down](#shutting-down)
  - [Observe automation with noVNC in browser (debugging)](#observe-automation-with-novnc-in-browser-debugging)
  - [Development](#development)
- [Bitwarden](#bitwarden)
- [License](#license)

## Preparation

Set up a `docker-compose` file like:

```yml
version: "3"

services:
  finance_dl:
    container_name: finance_dl
    # image with integrate Bitwarden CLI
    image: ghcr.io/moritzj29/finance-dl:bitwarden
    # image without Bitwarden CLI
    # image: ghcr.io/moritzj29/finance-dl:latest
    volumes:
      - ./:/workspace
      - "./Bitwarden Config:/root/.config/Bitwarden CLI"
      - "../beancount/Downloads finance-dl:/Downloads"
    ## change entrypoint to interactive shell
    entrypoint: /bin/bash
    stdin_open: true # docker run -i
    tty: true        # docker run -t
    depends_on:
      - standalonechrome

  standalonechrome:
    container_name: standalonechrome
    # multi-arch build of selenium docker: https://github.com/seleniarm/docker-selenium/issues/2
    image: seleniarm/standalone-chromium:4.1.2-20220227
    # or official image without arm64 support
    # image: selenium/standalone-chrome:latest
    volumes:
      - "../beancount/Downloads finance-dl:/Downloads"
      - ./.cache:/Cache
    expose:
      - 4444 # remote webdriver
      - 5900 # VNC
    ports:
      - "7900:7900" # noVNC -> browser
    # increased size of shared memory required
    shm_size: '2gb'
```

The `data_dir` set in the configuration file (`/Downloads` in the above example) needs to be available in both containers under the same path.

Populate the `finance_dl_config.py` with the desired configuration entries. Follow the examples given in [`example_finance_dl_config_docker_bw.py`](https://github.com/moritzj29/finance-dl/blob/master/example_finance_dl_config_docker_bw.py).

Make sure to add the following options to all your `CONFIG_`s:
```python
{
  # use remote browser in separate container
  # hostname = container_name in docker-compose
  connect_remote="http://standalonechrome:4444/wd/hub",
  # if using scraper which requires selenium requests, e.g. Paypal
  # set hostname/IP of container running finance-dl
  requests_proxy_host="finance_dl",
  # GPU needs to be disabled when Chrome is run in docker
  chromedriver_args=['--disable-gpu'],
}
```
### Set up Bitwarden CLI
Run the docker container interactively to set up Bitwarden CLI for the first time:
```shell
docker compose run --rm finance_dl
```
Within the container Bitwarden CLI is available as `bw`. Follow the [instructions](#bitwarden) to set up your Bitwarden account.

## Run downloaders

### Conventional (no Bitwarden CLI)
Get interactive shell for setup and manually running commands:
```shell
docker compose run
docker exec -it finance_dl /bin/bash
```

Run single configuration without saving logs:
```bash
python3 -m finance_dl.cli --config-module finance_dl_config --config amazon
```

### Bitwarden CLI
Instead of running `finance_dl` directly, it is wrapped into `automate.sh` to handle the unlocking of the Bitwarden vault. Thererfore any modifications to the `finance_dl` call should be made in the bash script. Adjust it to your needs.

Run downloaders:
```shell
docker compose run --rm --name finance_dl finance_dl ./automate.sh
```

Note: Explicitly set the container name. It is needed to resolve the conatiner IP.

## Shutting down
Stop depending containers and remove networks with `docker compose down`.

## Observe automation with noVNC in browser (debugging)
access noVNC (password: secret):
http://127.0.0.1:7900

set `headless=False` in `CONFIG`

## Development
Open interactive shell in `finance_dl` container and manually install `finance-dl` package from local directory.

# Bitwarden
If Bitwarden's `data.json` is not present in the specified Bitwarden directory yet (fresh start), start with setting config:
```bash
# only if applicable
bw server https://bw.example.com
bw login # follow interactive prompts to complete login
```
Now `data.json` should be present and contain encrypted vault data.

From now on it is sufficient to `unlock` the vault and eventually `sync` to get updates:
```bash
bw unlock
# set environment variable by copying "export BW_SESSION=..."
bw sync
```
To populate the config file, it is necessary to find the `id` of the desired item.
```
bw list items --search Paypal
```
For further options check the Bitwarden CLI documentation.

License
==

Copyright (C) 2014-2018 Jeremy Maitin-Shepard.

Additions: Copyright (C) 2022 Moritz Jung.

Distributed under the GNU General Public License, Version 2.0 only.
See [LICENSE](LICENSE) file for details.