#!/bin/bash
# Scales an OpenShift object

NAMESPACE=${1:-openshift-operators}
OBJ_TYPE=${2:-deployment}
OBJ_NAME=${2:-rhods-operator}
OBJ_COUNT=${3:-1}

target_obj=`oc get $OBJ_TYPE -n $NAMESPACE -o custom-columns=POD:.metadata.name --no-headers | grep "$OBJ_NAME"`
oc scale $OBJ_TYPE $target_ojb -n $NAMESPACE --replicas=$OBJ_COUNT
