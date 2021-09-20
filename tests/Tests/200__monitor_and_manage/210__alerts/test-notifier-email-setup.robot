*** Settings ***
Documentation     Check if notifications emails list parameter is properly set after RHODS installation
Resource          ../../../Resources/ODS.robot
Resource          ../../../Resources/Common.robot
Resource         ../../../Resources/Page/OCPDashboard/OCPDashboard.resource
Library           DebugLibrary
Library           SeleniumLibrary
Library           Process
Test Setup        Begin Web Test
Test Teardown     End Web Test


*** Variables ***
${MOCK_EMAIL_ADDRESS}  dummyEmail@redhat.com


*** Test Cases ***
#TODO
Can Install RHODS Operator With custom notification emails list
  [Tags]  TBC  ODS-518
  Should Be Equal  0  0
#  Open OperatorHub
#  Install RHODS Operator With Notification Emails  ${MOCK_EMAIL_ADDRESS}  # TODO: feature not implemented?
#  RHODS Operator Should Be Installed


Verify RHODS notification emails list Secret properly set
  [Tags]  Smoke  Sanity  ODS-518
  [Documentation]  Check if the addon-managed-odh-parameters Secret has a properly set notication-emails value
  ...              Note: in order to run this, user must be logged into openshift console via oc
  ...              Note: this also requires json-parsing cmd line utility 'jq'
  ${output}    Run process    tests/Tests/200__monitor_and_manage/210__alerts/sh/get-notification-emails.sh ${MOCK_EMAIL_ADDRESS}   shell=yes
  Should Not Contain    ${output.stdout}    FAIL
  Should Contain    ${output.stdout}    PASS


*** Keywords ***
# @override
Begin Web Test
    # Much faster test setup procedure for development usage  - TODO:remove (will default back to standard setup)
    Set Library Search Order  SeleniumLibrary
    #Open Browser  ${ODH_DASHBOARD_URL}  browser=${BROWSER.NAME}  options=${BROWSER.OPTIONS}
    #Login To RHODS Dashboard  ${TEST_USER.USERNAME}  ${TEST_USER.PASSWORD}  ${TEST_USER.AUTH_TYPE}
