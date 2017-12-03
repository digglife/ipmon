#!/bin/bash

script_path=$(dirname $0)
config="${script_path}/config"
ip_file="${script_path}/public_ip"

source "${config}"
source "${script_path}/functions.sh"

if [ -z $domain ] || [ -z $auth_email ] || [ -z $auth_key ];then
    echo "Missing configuration. Refer to ${config}."
    exit 1
fi

public_ip=$(curl -s https://api.ipify.org)

if is_diff_ip ${public_ip} ${ip_file};then
    update_result=$(update_domain ${domain} ${public_ip})
    if ${update_result};then
        syslog "${domain} updated to ${public_ip}"
    else
        syslog "domain updating failed"
    fi
else
    syslog "public ip not changed (${public_ip})"
fi
