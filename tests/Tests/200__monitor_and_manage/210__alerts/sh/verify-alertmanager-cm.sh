#!/bin/sh
# Checks if the PagerDuty key in the alertmanager CM matches the key in the PagerDuty Secret

### Step 1: Gather Data and translate yaml config into json for parsing###
alertmanager_cfg=`oc get cm -n redhat-ods-monitoring -o yaml alertmanager | yq r - 'data."alertmanager.yml"' | yq r --tojson -`
if [ $? -ne 0 ];
then
	echo "FAIL: Could not get or parse alertmanager.yml from ODH Alertmanager ConfigMap"
	exit 1
fi

secret_json=`oc get secret -n redhat-ods-monitoring -o json redhat-rhods-pagerduty`
if [ $? -ne 0 ];
then
	echo "FAIL: Could not get ODH PagerDuty Secret"
	exit 1
fi

### STEP 2: Parse and Validate Alertmanager CM ###
pd_configs=`echo $alertmanager_cfg | jq -r '.receivers[].pagerduty_configs | select( . != null )'`
if [ $? -ne 0 ];
then
	echo "FAIL: Could not parse PagerDuty receiver from alertmanager.yml"
	exit 1
fi

service_keys=`echo $pd_configs | jq -r '.[].service_key'`
if [ $? -ne 0 ];
then
	echo "FAIL: Could not parse PagerDuty keys from PagerDuty reciever"
	exit 1
fi

### STEP 3: Validate CM-based key ###
for key in $service_keys; do
	echo $key | base64 -d 2&>1 /dev/null
	if [ "$?" -eq 0 ]; then
		  # TODO: this is a requirement in the automation doc req list, but it is possible
			# for this to have false failures, if a password happens to be b64-decodable. Ex: d34df00d
			echo "FAIL: PagerDuty key in AlertManager Config is base64 encrypted"
			exit 1
	fi
done

### STEP 4: Parse PagerDuty Secret ###
hashed_value=`echo $secret_json | jq -r '.data.PAGERDUTY_KEY'`
if [ $? -ne 0 ];
then
	echo "FAIL: Could not parse notification-email from Secret data"
	exit 1
fi

pd_key=`echo -ne $hashed_value | base64 -d`
if [ $? -ne 0 ];
then
	echo "FAIL: Could not decrypt base64-encoded value from notification-email data"
	exit 1
fi

### STEP 5: Verify Match ###
echo "$service_keys" | grep "$pd_key" -w -q
if [ "$?" -eq 0 ];
then
	echo "PASS: PagerDuty keys match"
else
	echo "FAIL: PagerDuty keys do not match"
	exit 1
fi
