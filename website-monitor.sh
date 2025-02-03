#!/bin/bash

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

curl -s -o /dev/null ${webiste_URL}
curl_exit=$? 

# --- URL TEST ---
# At first, testing an internet connection pinging cloudflare and google.
if (ping -c 1 1.1.1.1 &> /dev/null || ping -c 1 8.8.8.8 &> /dev/null) then 
    if (host -W 1 ${webiste_NAME} &> /dev/null); then
        if [ "${curl_exit}" -eq 0 ]; then
            status_FULL=$(curl -m 10 -s --head  --request GET ${webiste_URL} | grep -E "^HTTP")
            status_CODE=$(echo $status_FULL | grep -oE '[0-9]{3}')
            if [[ ${status_CODE} =~ ^[0-9]+$ ]] && [[ "${status_CODE}" -lt 400 ]]; then
                echo "${check_time}: ${webiste_NAME} is UP, status code: ${status_FULL}" >> ${log_file}
            elif [[ ${status_CODE} =~ ^[0-9]+$ ]] && [[ "${status_CODE}" -ge 400 ]]; then
                echo "${check_time}: ${webiste_NAME} is DOWN, status code: ${status_FULL}" >> ${log_file}
            fi 
        else
           echo "${check_time}: curl error number: ${curl_exit}" >> ${log_file} 
        fi
    else
        echo "${check_time}: Error: The specified domain probably does not exist. Please check the address \"${webiste_NAME}\" and try again." >> ${log_file}
    fi
else
    echo "${check_time}: Cloudflere (1.1.1.1) and Google (8.8.8.8) DNS not responding. Do you have an internet connection?" >> ${log_file}
fi

cat ${log_file}