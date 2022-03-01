import subprocess
import json

def bw_get_pw(id):
    # check if bitwarden vault is unlocked
    process = subprocess.run(
        ['bw', 'status'], capture_output=True, text=True
        )
    status = json.loads(process.stdout)
    if status['status'] != 'unlocked':
        raise LookupError('Bitwarden Vault still %s!' % status['status'])

    process = subprocess.run(
        ['bw', 'get', 'password', id], capture_output=True, text=True
        )
    return process.stdout

def bw_get_otp(id):
    process = subprocess.run(
        ['bw', 'get', 'totp', id], capture_output=True, text=True
        )
    return process.stdout