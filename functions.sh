#!/bin/bash


function is_cmd_available() {
    command -v $1 >/dev/null 2>&1
}

function syslog(){
    local message=$1
    logger -t "UPDATE_HOME_DNS" "${message}"
}

function is_diff_ip(){
    local public_ip=$1
    local ip_file=$2
    if [ -r "${ip_file}" ];then
        old_ip=$(cat "${ip_file}")
        if [ "${old_ip}" != "${public_ip}" ];then
            echo ${public_ip} > "${ip_file}"
            return 0
        else
            return 1
        fi
    else
        # execute at the first time
        echo ${public_ip} > "${ip_file}"
        return 0
    fi
}

function get_zone_id(){
    local domain_name=$1
    # extract root domain
    domain_name=$(echo "$domain_name" | awk -F'.' '{ print $(NF-1)"."$NF }')

    zone_id=$(curl -s -X GET "${cloud_flare_api_url}/zones/?name=${domain_name}" \
    -H "X-Auth-Email:${auth_email}"  \
    -H "X-Auth-Key:${auth_key}" \
    -H "Content-Type:application/json" \
    | jq '.result[0].id')
    echo ${zone_id//\"/}
}


function update_domain(){
    local domain_name=$1
    local ip=$2

    zone_id=$(get_zone_id $domain_name)

    domain_result=$(curl -s -X GET "${cloud_flare_api_url}/zones/${zone_id}/dns_records?name=${domain_name}" \
    -H "X-Auth-Email:${auth_email}"  \
    -H "X-Auth-Key:${auth_key}" \
    -H "Content-Type:application/json")

    if [ $(echo "${domain_result}" | jq '.success') = 'false' ];then
        echo "no such domain"
        return 1
    fi

    domain_id=$(echo "${domain_result}" | jq '.result[0].id' | sed 's/^"\(.*\)"$/\1/')

    update_result=$(curl -s -X PUT "${cloud_flare_api_url}/zones/${zone_id}/dns_records/${domain_id}" \
    -H "X-Auth-Email:${auth_email}"  \
    -H "X-Auth-Key:${auth_key}" \
    -H "Content-Type:application/json" \
    --data '{"type": "A", "name": "'${domain_name}'", "content": "'${ip}'"}' | \
    jq '.success')

    if [ "${update_result}" = "true" ];then
        return 0
    else
        echo "update failed"
        return 1
    fi
}
