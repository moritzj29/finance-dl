"""Retrieves Paypal activity from https://paypal.com.

This uses the `selenium` Python package in conjunction with `chromedriver` to
scrape the Paypal purchases website.

Configuration:
==============

The following keys may be specified as part of the configuration dict:

- `credentials`: Required.  Must be a `dict` with `'username'`, `'password'`
  and `'otp'` keys.

- The OTP (one-time-password) expires quickly, so you need to pass a method to
  generate it in place. For example retrieve it from a password manager or
  generate it from the secret.

- `output_directory`: Required.  Must be a `str` that specifies the path on the
  local filesystem where the output will be written.  If the directory does not
  exist, it will be created.

- `profile_dir`: Optional.  If specified, must be a `str` that specifies the
  path to a persistent Chrome browser profile to use.  This should be a path
  used solely for this single configuration; it should not refer to your normal
  browser profile.  If not specified, a fresh temporary profile will be used
  each time.

Output format:
==============

For each Paypal transaction, two files are written to the specified
`output_directory`: `<id>.json` contains a JSON representation of the
transaction as returned by the Paypal server, and `<id>.html` contains an HTML
representation.

For invoices, instead the files `<id>.pdf` and `<id>.invoice.json` are written
to the specified `output_directory`.

Interactive shell:
==================

From the interactive shell, type: `self.run()` to start the scraper.

"""

import logging
import time
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from fake_headers import Headers
from . import scrape_lib
from . import paypal


logger = logging.getLogger('paypal_otp')

class Scraper(paypal.Scraper):
    def __init__(self, credentials: dict, output_directory: str, 
                 chromedriver_args=[], **kwargs):
        # based on:
        # https://stackoverflow.com/a/69464060
        # selenium sends a "headless" hint in its User-Agent field
        # PayPal is tracking the User-Agent for OTP / 2FA and
        # denies access / alters the website
        # the script works wihtout header modification in interactive mode
        header = Headers(
            browser="chrome",  # Generate only Chrome UA
            os="win",  # Generate only Windows platform
            headers=False  # generate misc headers
        )
        customUserAgent = header.generate()['User-Agent']

        chromedriver_args.append(f"user-agent={customUserAgent}")

        super().__init__(
            credentials, output_directory,
            chromedriver_args=chromedriver_args, 
            **kwargs)

    def login(self):
        if self.logged_in:
            return

        self.driver.get('https://www.paypal.com/us/signin')
        time.sleep(0.2)
        logger.info('Finding username field')
        username, = self.wait_and_locate((By.XPATH, '//input[@type="email"]'),
                                         only_displayed=True)
        logger.info('Entering username')
        username.clear()
        username.send_keys(self.credentials['username'])
        username.send_keys(Keys.ENTER)
        time.sleep(0.2)
        logger.info('Finding password field')
        password, = self.wait_and_locate(
            (By.XPATH, '//input[@type="password"]'), only_displayed=True)
        logger.info('Entering password')
        password.send_keys(self.credentials['password']())
        with self.wait_for_page_load():
            password.send_keys(Keys.ENTER)
        # same as parent login method, except for this block
        # start OTP code
        time.sleep(0.2)
        logger.info('Finding OTP field')
        totp, = self.wait_and_locate(
            #(By.XPATH, '//input[@type="tel"]'),
            (By.ID, 'otpCode'), 
            only_displayed=True)
        logger.info('Entering OTP')
        totp.send_keys(self.credentials['otp']())

        logger.info('Send Enter')
        with self.wait_for_page_load():
            totp.send_keys(Keys.ENTER)
        # end OTP code
        logger.info('Logged in')
        self.logged_in = True
        self.csrf_token = None


def run(**kwargs):
    scrape_lib.run_with_scraper(Scraper, **kwargs)


def interactive(**kwargs):
    return scrape_lib.interact_with_scraper(Scraper, **kwargs)