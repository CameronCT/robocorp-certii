*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables

*** Variables *** 
${csvUrl}           https://robotsparebinindustries.com/orders.csv
${orderUrl}         https://robotsparebinindustries.com/#/robot-order

*** Tasks ***
Executing Task List
    Download Orders 
    ${orders}=            Parse Orders
    Process Orders        ${orders}

*** Keywords ***
Download Orders
    Download    ${csvUrl}    overwrite=True

Parse Orders 
    ${orders}=    Read table from CSV    orders.csv
    Log           Found Columns: ${orders.columns}
    [Return]      ${orders}

Process Orders 
    [Arguments]     ${orders}
    FOR    ${row}    IN    @{orders}
        Open Store
        Submit Order    ${row}
        Close Browser
    END

Submit Order
    [Arguments]  ${order}
    Log    ${order}

Open Store
    Open Available Browser      ${orderUrl}
    Click Button                I guess so...

    

