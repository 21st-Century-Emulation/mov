docker build -q -t mov .
docker run --rm --name mov -d -p 8080:8080 -e READ_MEMORY_API=http://localhost:8080/api/v1/debug/readMemory -e WRITE_MEMORY_API=http://localhost:8080/api/v1/debug/writeMemory mov

sleep 5
RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":94,"state":{"a":181,"b":0,"c":0,"d":0,"e":0,"h":25,"l":10,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":0,"stackPointer":0,"cycles":2,"interruptsEnabled":true}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":94,"state":{"a":181,"b":0,"c":0,"d":0,"e":10,"h":25,"l":10,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":0,"stackPointer":0,"cycles":9,"interruptsEnabled":true}}'

docker kill mov

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mMOV Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mMOV Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi