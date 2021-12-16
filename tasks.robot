*** Settings ***
Documentation     Template robot main suite.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.Robocorp.Vault

*** Tasks ***
Executing Task List
    Get Secrets
    Download Orders 
    Parse Orders
    Open Store

*** Keywords ***
Get Secrets
    ${secret}=    Get Secret    credentials

Download Orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Parse Orders 
    ${orders}=    Read table from CSV    orders.csv
    Log           Found Columns: ${orders.columns}

Open Store
    Open Available Browser      https://robotsparebinindustries.com/#/robot-order
    Click Button                I guess so...

Process Orders 
    FOR    ${row}    IN    @{orders}

