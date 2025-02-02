#!/bin/bash
set -e # Exit on errors
trap 'echo "Error on line $LINENO"; exit 1' ERR # Track line error

# --- VARS ---
valid_url="^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/.*)?$"
check_time=$(date)
webiste_URL=${1}
webiste_NAME=${webiste_URL##*/}
log_file=.logs/${webiste_NAME}-status

# --- BODY ---
if [ -z "${1}" ]; then 
    echo "No URL provided"
    exit 1
fi

if ! [[ ${webiste_URL} =~ ${valid_url} ]]; then
    echo "Not a valid URL, provided"
    exit 1
fi

# --- URL TEST ---

status_FULL=$(curl -m 10 -s --head  --request GET ${webiste_URL} | grep -E "^HTTP")
status_CODE=$(echo $status_FULL | grep -oE '[0-9]{3}')
if [[ ${status_CODE} =~ ^[0-9]+$ ]] && [[ "${status_CODE}" -lt 400 ]]; then
    echo "${check_time}: ${webiste_NAME} is UP, status code: ${status_FULL}" >> ${log_file}
elif [[ ${status_CODE} =~ ^[0-9]+$ ]] && [[ "${status_CODE}" -ge 400 ]]; then
        echo "${check_time}: ${webiste_NAME} is DOWN" >> ${log_file}
else
    if ping -c 1 1.1.1.1 &> /dev/null && host ${webiste_NAME} &> /dev/null && ! ping -c 1 $webiste_URL &> /dev/null; then 
        echo "${check_time}: It seems that the web server is fully down, not answering with http protocol and ICMP package" >> ${log_file}
    elif ping -c 1 1.1.1.1 &> /dev/null && ! host ${webiste_NAME} &> /dev/null; then
        echo "${check_time}: There is something wrong with domain, is the domain ${webiste_NAME} real?" >> ${log_file}
    else
        echo "${check_time}: Do you have an internet connection?" >> ${log_file}
    fi
fi

cat << EOF 
    SUCCESS TEST
    ${check_time}
    ${status_CODE}
    ${status_FULL}
    $(echo "--- ---")
    $(cat ${log_file}) 
EOF