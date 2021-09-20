#!/bin/sh
# Gets and parses the odh parameters secret for the notication-email dict
expected="${1:-dummyEmail@redhat.com}"

secret_json=`oc get secret -n redhat-ods-operator -o json addon-managed-odh-parameters`
if [ $? -ne 0 ];
then
	echo "FAIL: Could not get ODH Parameters Secret"
	exit 1
fi

hashed_value=`echo $secret_json | jq -r '.data."notification-email"'`
if [ $? -ne 0 ];
then
	echo "FAIL: Could not parse notification-email from Secret data"
	exit 1
fi

actual=`echo -ne $hashed_value | base64 -d`
if [ $? -ne 0 ];
then
	echo "FAIL: Could not decrypt base64-encoded value from notification-email data"
	exit 1
fi

if [ "$expected" == "$actual" ];
then
	echo "PASS: notification-email matches"
else
	echo "FAIL: notification-email does not match"
	exit 1
fi
