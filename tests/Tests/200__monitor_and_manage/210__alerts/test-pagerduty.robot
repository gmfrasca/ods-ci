*** Settings ***
Documentation     Check if PagerDuty key is properly set after RHODS installation
Resource          ../../../Resources/ODS.robot
Resource          ../../../Resources/Common.robot
Resource         ../../../Resources/Page/OCPDashboard/OCPDashboard.resource
Library           DebugLibrary
Library           SeleniumLibrary
Library           Process
Test Setup        Begin Web Test
Test Teardown     End Web Test


*** Variables ***


*** Test Cases ***
#TODO
Can Install RHODS Operator
  [Tags]  Smoke  Sanity  ODS-500
  Should Be Equal  0  0
#  Open OperatorHub
#  Install RHODS Operator
#  RHODS Operator Should Be Installed

Verify RHODS notification emails list Secret properly set
  [Tags]  Smoke  Sanity  ODS-500
  [Documentation]  Check if the PagerDuty key is properly set in the alertmanager CM and redhat-rhods-pagerduty Secret
  ...              Note: this also requires json- and yaml-parsing cmd line utilities 'jq' and 'yq'
  ${output}    Run process    tests/Tests/200__monitor_and_manage/210__alerts/sh/verify-alertmanager-cm.sh   shell=yes
  Should Not Contain    ${output.stdout}    FAIL
  Should Contain    ${output.stdout}    PASS

#TODO
Scale Down RHODS Operator and Dashboard Pods
  [Tags]  Smoke  Sanity  ODS-500
  Scale Deployment  openshift-operators  rhods-operator  0
  Scale Deployment  redhat-ods-applications  rhods-dashboard  0

#TODO
Verify Alert Flow
  [Tags]  Smoke  Sanity  ODS-500
  Should Be Equal  0  0


*** Keywords ***
# @override
Begin Web Test
    # Much faster test setup procedure for development usage  - TODO:remove (will default back to standard setup)
    Set Library Search Order  SeleniumLibrary
    #Open Browser  ${ODH_DASHBOARD_URL}  browser=${BROWSER.NAME}  options=${BROWSER.OPTIONS}
    #Login To RHODS Dashboard  ${TEST_USER.USERNAME}  ${TEST_USER.PASSWORD}  ${TEST_USER.AUTH_TYPE}

Scale Deployment
  Arguments  ${SCALE_TARGET_NAMESPACE}  ${SCALE_OBJECT_NAME}  ${SCALE_OBJECT_NUMBER}
  Run process    tests/Tests/200__monitor_and_manage/210__alerts/sh/scale-object.sh ${SCALE_TARGET_NAMESPACE} deployment ${SCALE_OBJECT_NAME} ${SCALE_OBJECT_NUMBER}   shell=yes
