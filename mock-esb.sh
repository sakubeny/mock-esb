#!/bin/bash

SERVICE_ID="${service_id}"

# default value
[ -z "$SERVICE_ID" ] && SERVICE_ID="123456789"

case "$SERVICE_ID" in
    "123456789")
        cat response/esb-success.json \
        | sed "s/{{SERVICE_ID}}/$SERVICE_ID/g"
        ;;
    *)
        cat response/esb-not-found.json \
        | sed "s/{{SERVICE_ID}}/$SERVICE_ID/g"
        ;;
esac
