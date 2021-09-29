*** Settings ***
Documentation     Check if PagerDuty key is properly set after RHODS installation
Resource          ../../../Resources/ODS.robot
Resource          ../../../Resources/Common.robot
Resource         ../../../Resources/Page/OCPDashboard/OCPDashboard.resource
Library           DebugLibrary
Library           SeleniumLibrary
Library           Process
Library           yaml
Library           Collections
Test Setup        Begin Web Test
Test Teardown     End Web Test


*** Variables ***
${MONITORING_NAMESPACE}  redhat-ods-monitoring
${PAGERDUTY_SECRET}  redhat-rhods-pagerduty
${ALERTMANAGER_CM}   alertmanager
${ALERTMANAGER_CFG_NAME}  alertmanager.yml
${OPERATORS_NAMESPACE}  openshift-operators
${APPLICATIONS_NAMESPACE}  redhat-ods-applications
${OPERATOR_DEPLOYMENT_NAME}  rhods-operator
${DASHBOARD_DEPLOYMENT_NAME}  rhods-dashboard

*** Test Cases ***
Verify RHODS PagerDuty Secret properly set
  [Tags]  Smoke  Sanity  ODS-500
  [Documentation]  Check if the PagerDuty key is properly set in the alertmanager CM and redhat-rhods-pagerduty Secret
  ${pd_key}   Run   oc get secret -n ${MONITORING_NAMESPACE} -o go-template --template="{{.data.PAGERDUTY_KEY | base64decode}}" ${PAGERDUTY_SECRET}
  Should Not Contain    ${pd_key}    "error:"

Verify AlertManager Config is Valid
  [Tags]  Smoke  Sanity  ODS-500
  ${pd_key}   Run   oc get secret -n ${MONITORING_NAMESPACE} -o go-template --template="{{.data.PAGERDUTY_KEY | base64decode}}" ${PAGERDUTY_SECRET}
  ${am_cfg}   Run   oc get cm -n ${MONITORING_NAMESPACE} -o go-template --template='{{ index .data "${ALERTMANAGER_CFG_NAME}" }}' ${ALERTMANAGER_CM}
  Should Not Contain    ${am_cfg}    "error:"
  ${loaded_cfg}=   yaml.Safe Load  ${am_cfg}
  @{receivers}=      Set Variable  ${loaded_cfg}[receivers]
  FOR   ${rcv}   IN   @{receivers}
    Run keyword if  'pagerduty_configs' in ${rcv}  Find PagerDuty Key In Configs  ${rcv}  ${pd_key}
  END


#TODO
#Scale Down RHODS Operator and Dashboard Pods
#  [Tags]  Smoke  Sanity  ODS-500
#  Scale Deployment  ${OPERATOR_NAMESPACE}  ${OPERATOR_DEPLOYMENT_NAME}  0
#  Scale Deployment  ${APPLICATIONS_NAMESPACE}  ${DASHBOARD_DEPLOYMENT_NAME}  0

#TODO
Verify Alert Flow
  [Tags]  Smoke  Sanity  ODS-500
  Should Be Equal  0  0


*** Keywords ***
Scale Deployment
  [Arguments]  ${SCALE_TARGET_NAMESPACE}  ${SCALE_OBJECT_NAME}  ${SCALE_OBJECT_NUMBER}
  ${target_obj}=  Run  oc get deployement -n ${SCALE_TARGET_NAMESPACE} -o custom-columns=POD:.metadata.name --no-headers | grep "${SCALE_OBJECT_NAME}"`
  Run  oc scale deployment ${target_obj} -n $${SCALE_TARGET_NAMESPACE} --replicas=${SCALE_OBJECT_NUMBER}


Find PagerDuty Key In Configs
  [Arguments]  ${rcv}  ${pd_key}
  @{pd_configs}=   Set Variable  ${rcv}[pagerduty_configs]
  ${found} =   Set Variable  ${false}

  FOR  ${cfg}  IN  @{pd_configs}
    ${cfg_dict}=  Convert To Dictionary  ${cfg}
    IF  'service_key' in ${cfg_dict}
      IF  "${cfg_dict}[service_key]" == "${pd_key}"
        ${found} =  Set Variable  ${true}
      END
    END
    #Run keyword if  service_key in ${cfg_dict} and ${cfg_dict}[service_key] == ${pd_key}  Log To Console  "FOOOOO"
  END
  Should Be True  ${found}
