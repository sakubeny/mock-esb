Untuk Rnning service 
./start.sh

service willbe run on port 8088
Testing
curl -X POST http://203.194.114.55:8088/esb/v1/fmc/pia-renewal -H "Content-Type: application/json" -d '{
    "service_id":"11223344"
}'
