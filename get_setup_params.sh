#!/bin/bash


## This Script installs sls operator for MAS.
SCRIPT_DIR=$(
  cd $(dirname $0)
  pwd
)

source "${SCRIPT_DIR}/behavior-analytics-services/Installation Scripts/bas-script-functions.bash"
function stepLog() {
  echo -e "STEP $1/3: $2"
}

status=$(oc whoami 2>&1)
if [[ $? -gt 0 ]]; then
  echoRed "Login to OpenShift to continue SLS Operator installation."
  exit 1
fi

displayStepHeader 1 "MongoDB Setup Parameters"
echo "===========Hosts=============="
oc get MongoDBCommunity -n mongo  -o 'jsonpath={..status.mongoUri}' | sed -e 's|mongodb\://||g' -e 's/,/\n/g'

echo ""
echo "===========MongoDB login account credentials=============="
echo "Username: admin"
MONGO_PASSWORD=$(oc get secret mas-mongo-ce-admin-password -n mongo --output="jsonpath={.data.password}" | base64 -d)
echo "Password: ${MONGO_PASSWORD}"

echo "===========Certificates=============="
oc get configmap mas-mongo-ce-cert-map -n mongo -o jsonpath='{.data.ca\.crt}'

displayStepHeader 2 "BAS Setup Parameters"
projectName="bas"
echo "===========BAS Endpoint URL=============="
echo https://$(oc get routes bas-endpoint -n "${projectName}" |awk 'NR==2 {print $2}')

echo "===========API KEY=============="
oc get secret bas-api-key -n "${projectName}" --output="jsonpath={.data.apikey}" | base64 -d
echo ""

echo "===========Certificates=============="
oc get secret router-certs-default -n "openshift-ingress" -o "jsonpath={.data.tls\.crt}" | base64 -d

displayStepHeader 3 "SLS Setup Parameters"

echo "===========SLS Endpoint URL=============="
oc get configmap -n 'ibm-sls' sls-suite-registration -o jsonpath='{.data.url}'
echo ""
echo "===========registration Key=============="
oc get configmap -n 'ibm-sls' sls-suite-registration -o jsonpath='{.data.registrationKey}'
echo ""
echo "===========Certificates=============="
oc get configmap -n 'ibm-sls' sls-suite-registration -o jsonpath='{.data.ca}'
echo ""