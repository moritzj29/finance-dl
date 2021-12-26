Python package for scraping personal financial data from financial
institutions.

[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](LICENSE)
[![PyPI](https://img.shields.io/pypi/v/finance-dl)](https://pypi.org/project/finance-dl)
[![Build](https://github.com/jbms/finance-dl/workflows/Build/badge.svg)](https://github.com/jbms/finance-dl/actions?query=workflow%3ABuild)

This package may be useful on its own, but is specifically designed to be
used with
[beancount-import](https://github.com/jbms/beancount-import).

Supported data sources
==

- [finance_dl.ofx](finance_dl/ofx.py): uses
  [ofxclient](https://github.com/captin411/ofxclient) to download data
  using the OFX protocol.
- [finance_dl.mint](finance_dl/mint.py): uses
  [mintapi](https://github.com/mrooney/mintapi) to download data from
  the Mint.com website.
- [finance_dl.venmo](finance_dl/venmo.py): downloads transaction and
  balance information from the Venmo.com website
- [finance_dl.paypal](finance_dl/paypal.py): downloads transactions
  from the Paypal.com website
- [finance_dl.amazon](finance_dl/amazon.py): downloads order invoices
  from the Amazon website
- [finance_dl.healthequity](finance_dl/healthequity.py): downloads
  transaction history and balance information from the HealthEquity
  website.
- [finance_dl.google_purchases](finance_dl/google_purchases.py):
  downloads purchases that Google has heuristically extracted from
  Gmail messages.
- [finance_dl.stockplanconnect](finance_dl/stockplanconnect.py):
  downloads PDF documents (including release and trade confirmations)
  from the Morgan Stanley Stockplanconnect website.
- [finance_dl.pge](finance_dl/pge.py): downloads Pacific Gas &
  Electric (PG&E) PDF bills.
- [finance_dl.comcast](finance_dl/comcast.py): downloads Comcast PDF
  bills.
- [finance_dl.ebmud](finance_dl/ebmud.py): downloads East Bay
  Municipal Utility District (EBMUD) water bills.
- [finance_dl.anthem](finance_dl/anthem.py): downloads Anthem
  BlueCross insurance claim statements.
- [finance_dl.waveapps](finance_dl/waveapps.py): downloads receipt
  images and extracted transaction data from
  [Wave](https://waveapps.com), which is a free receipt-scanning
  website/mobile app.
- [finance_dl.ultipro_google](finance_dl/ultipro_google.py): downloads
  Google employee payroll statements in PDF format from Ultipro.
- [finance_dl.usbank](finance_dl/usbank.py): downloads data from US Bank credit cards in OFX format.
- [finance_dl.radiusbank](finance_dl/radiusbank.py): downloads data from Radius Bank in QFX format.
- [finance_dl.schwab](finance_dl/schwab.py): downloads data from Schwab Brokerage accounts in CSV format.
- [finance_dl.gemini](finance_dl/gemini.py): downloads trades, transfers and balances from Gemini crypto exchange using REST API, stores in a custom CSV format.

Setup
==

To install the most recent published package from PyPi, simply type:

```shell
pip install finance-dl
```

To install from a clone of the repository, type:

```shell
pip install .
```

or for development:

```shell
pip install -e .
```
`finance-dl` is based on the `selenium` framework (v3) to automatically scrape the data from supported websites.
To function correctly, a working Google Chrome browser and the matching `chromedriver` needs to be installed and available in `$PATH`.

Docker
--
It is possible to run `finance-dl` completely within docker, so no software needs to be installed (except docker of course). Check this example `docker-compose.yml`:

```yml
version: "3"

services:
  finance_dl:
    container_name: finance_dl
    build: .
    volumes:
      - ./:/workspace
    # forever running entrypoint command, otherwise conatiner shuts down immediately
    entrypoint: /bin/sh -c "while sleep 1000; do :; done"

  standalonechrome:
    container_name: standalonechrome
    image: docker.io/selenium/standalone-chrome:local
    volumes:
      - ./Downloads:/Downloads
      - ./.cache:/Cache
    expose:
      - 4444
    # increased size of shared memory required
    shm_size: '2gb'
```

The package depends on [`selenium` version 3](https://github.com/SeleniumHQ/docker-selenium/tree/selenium-3), therefore be sure to use v3 docker images. These are not updated with current Google Chrome releases anymore, but it is straightforward to build the image yourself:

- download the [latest `selenium` Docker code from the version 3 branch](https://github.com/SeleniumHQ/docker-selenium/tree/selenium-3)
- from within the directory build a custom local image with your desired Google Chrome and `chromedriver` version by setting the appropriate `BUILD_ARGS`, e.g.

```shell
$ VERSION=local BUILD_ARGS="--build-arg CHROME_VERSION=google-chrome-stable=96.0.4664.110-1 --build-arg CHROME_DRIVER_VERSION=96.0.4664.45" make standalone_chrome
```
- check the name of the resulting image, e.g. `docker.io/selenium/standalone-chrome:local` and update the `docker-compose.yml` accordingly
- for more detailed information on the available options refer to the selenium Docker documentation


Configuration
==

Create a Python file like `example_finance_dl_config.py`.

Refer to the documentation of the individual scraper modules for
details.

Basic Usage
==

You can run a scraping configuration named `myconfig` as follows:

    python -m finance_dl.cli --config-module example_finance_dl_config --config myconfig

The configuration `myconfig` refers to a function named
`CONFIG_myconfig` in the configuration module.

Make sure that your configuration module is accessible in your Python
`sys.path`.  Since `sys.path` includes the current directory by
default, you can simply run this command from the directory that
contains your configuration module.

By default, the scrapers run fully automatically, and the ones based
on `selenium` and `chromedriver` run in headless mode.  If the initial
attempt for a `selenium`-based scraper fails, it is automatically
retried again with the browser window visible.  This allows you to
manually complete the login process and enter any multi-factor
authentication code that is required.

To debug a scraper, you can run it in interactive mode by specifying
the `-i` command-line argument.  This runs an interactive IPython
shell that lets you manually invoke parts of the scraping process.

Automatic Usage
==

To run multiple configurations at once, and keep track of when each
configuration was last updated, you can use the `finance_dl.update`
tool.

To display the update status, first create a `logs` directory and run:

    python -m finance_dl.update --config-module example_finance_dl_config --log-dir logs status

Initially, this will indicate that none of the configurations have
been updated.  To update a single configuration `myconfig`, run:

    python -m finance_dl.update --config-module example_finance_dl_config --log-dir logs update myconfig

With a single configuration specified, this does the same thing as the
`finance_dl.cli` tool, except that the log messages are written to
`logs/myconfig.txt` and a `logs/myconfig.lastupdate` file is created
if it is successful.

If multiple configurations are specified, as in:

    python -m finance_dl.update --config-module example_finance_dl_config --log-dir logs update myconfig1 myconfig2

then all specified configurations are run in parallel.

To update all configurations, run:

    python -m finance_dl.update --config-module example_finance_dl_config --log-dir logs update --all

License
==

Copyright (C) 2014-2018 Jeremy Maitin-Shepard.

Distributed under the GNU General Public License, Version 2.0 only.
See [LICENSE](LICENSE) file for details.
