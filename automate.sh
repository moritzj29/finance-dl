#!/bin/bash -i

echo "Automated finance_dl script by Moritz Jung"
ret=$(bw unlock)
echo "$ret"

# if return is empty, try logging in
if [[  -z  $ret  ]]
then
    ret=$(bw login)
    echo "$ret"
fi

# parse output to extract environment variable BW_SESSION
# -r: capture groups not escaped, plain () work
# -n: do not default to print each line
# 's/REGEX/\1/p'
# s: subsitution, syntax s/find/replace/
# \1: replace with 1st capturing group
# p flag: print substituiton (in combination with -n only print substitution)
unlock_env=$(echo "$ret" | sed -rn 's/^\$\sexport\s(BW_SESSION=.+)$/\1/p')

# exit if unlock_env is still empty
[[  -z  $unlock_env  ]] && \
echo "Unlocking Bitwarden was not successful... exiting." && \
exit

# unlock vault
export "$unlock_env"

# sync vault
bw sync

# run finance_dl scripts
# set parallel threads to 1 sine only 1 standalonechrome container
python -m finance_dl.update --config-module finance_dl_config --log-dir logs update --all --parallelism 1 --force

echo "Finished running updates, exiting..."
exit


