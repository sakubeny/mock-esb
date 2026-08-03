#!/bin/bash

PORT=8088

echo "========================================="
echo " Mock ESB Started"
echo " Listening on : ${PORT}"
echo "========================================="

while true
do
{
    REQUEST_LINE=""

    # Request line
    IFS= read REQUEST_LINE

    METHOD=$(echo "$REQUEST_LINE" | awk '{print $1}')
    URI=$(echo "$REQUEST_LINE" | awk '{print $2}')

    CONTENT_LENGTH=0

    # Read Header
    while IFS= read HEADER
    do
        HEADER=$(echo "$HEADER" | tr -d '\r')

        [ -z "$HEADER" ] && break

        case "$HEADER" in
            Content-Length:*)
                CONTENT_LENGTH=$(echo "$HEADER" | awk '{print $2}')
            ;;
        esac
    done

    BODY=""
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
        IFS= read -r -N "$CONTENT_LENGTH" BODY
    fi

    SERVICE_ID=$(echo "$BODY" | grep -o '"service_id"[ ]*:[ ]*"[^"]*"' | cut -d'"' -f4)

    [ -z "$SERVICE_ID" ] && SERVICE_ID="11223344"

    if [ "$SERVICE_ID" = "11223344" ]; then
        JSON=$(cat response/esb-success.json)
    else
        JSON=$(cat response/esb-not-found.json)
    fi

    JSON=$(echo "$JSON" | sed "s/{{SERVICE_ID}}/$SERVICE_ID/g")

    echo "HTTP/1.1 200 OK"
    echo "Content-Type: application/json"
    echo "Connection: close"
    echo "Content-Length: ${#JSON}"
    echo
    echo "$JSON"

} | nc -l 8088
done
