import os
from finance_dl.bitwarden import bw_get_pw, bw_get_otp

# Directory for persistent browser profiles
# -> must be available in standalonechrome container!
profile_dir = 'Cache/finance_dl'
# data directory must be available in BOTH containers
# (finance_dl and standalonechrome under this exact path!)
# final directory is finance_dl container -> volume mount
data_dir = '/Downloads'

def CONFIG_amazon():
    return dict(
        module='finance_dl.amazon',
        credentials={
            'username': 'johndoe@gmail.com',
            'password': bw_get_pw('***bw_id_amazon***'),
        },
        amazon_domain='.de',
        order_groups=['letzte 3 Monate'], # takes quite some time otherwise!
        output_directory=os.path.join(data_dir, 'amazon'),
        # profile_dir is optional.
        profile_dir=os.path.join(profile_dir, 'amazon'),
        connect_remote="http://standalonechrome:4444/wd/hub",
        chromedriver_args=['--disable-gpu'],
        headless=True
    )

def CONFIG_paypal_moritz():
    return dict(
        module='finance_dl.paypal_otp',
        credentials={
            'username': 'johndoe@gmail.com',
            'password': (lambda: bw_get_pw('***bw_id_paypal***')),
            'otp': (lambda: bw_get_otp('***bw_id_paypal***'))
        },
        output_directory=os.path.join(data_dir, 'paypal'),
        connect_remote="http://standalonechrome:4444/wd/hub",
        chromedriver_args=['--disable-gpu'],
        requests_proxy_host='finance_dl',
        headless=True
    )