#!/bin/bash
webiste_URL=https://example.com
webiste_NAME=example.com

status_FULL=$(curl -m 10 -s --head  --request GET ${webiste_URL} | grep -E "^HTTP")
status_CODE=$(echo $status_FULL | grep -oE '[0-9]{3}')
if [[ ${status_CODE} =~ ^[0-9]+$ ]] && [[ "${status_CODE}" -lt 400 ]]; then
    echo "$(date): ${webiste_NAME} is UP, status code: ${status_FULL}" >> ${webiste_NAME}-status
elif [[ ${status_CODE} =~ ^[0-9]+$ ]] && [[ "${status_CODE}" -ge 400 ]]; then
        echo "$(date): ${webiste_NAME} is DOWN" >> ${webiste_NAME}-status
else
    if ping -c 1 1.1.1.1 &> /dev/null && host ${webiste_NAME} &> /dev/null && ! ping -c 1 $webiste_URL &> /dev/null; then 
        echo "It seems that web server is fully down, not answering with http protocol nad ICMP package"
    elif ping -c 1 1.1.1.1 &> /dev/null && ! host ${webiste_NAME} &> /dev/null; then
        echo "There is something wrong with domain, is domain ${webiste_NAME} real?"
    else
        echo "Do you have internet connection?"
    fi
fi
echo ${status_CODE}
echo ${status_FULL}