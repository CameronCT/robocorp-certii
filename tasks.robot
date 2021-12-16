*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library    RPA.PDF

*** Variables *** 
${useDir}           ${CURDIR}${/}data${/}
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

Open Store
    Open Available Browser      ${orderUrl}
    Click Button                I guess so...

Process Orders 
    [Arguments]     ${orders}
    FOR    ${row}    IN    @{orders}
        Open Store
        Wait Until Page Contains Element     //button[@type="submit"]
        Submit Order    ${row}
        Close Browser
    END

Submit Order
    [Arguments]     ${order}
    Select From List By Value     //select[@name="head"]    ${order}[Head]
    Click Element                 //input[@value="${order}[Body]"]
    Input Text                    //input[@type="number"]    ${order}[Legs]
    Input Text                    //input[@type="text"]    ${order}[Address]
    Click Element                 //button[@id="preview"]
    Click Element                 //button[@id="order"]

    Sleep     3
    ${isReceiptAvailable}=    Is Element Visible    //div[@id="receipt"]

    IF   ${isReceiptAvailable}
        Process Order File     ${order}
    ELSE 
        Submit Order    ${order}
    END
        
    Log    ${order}

Process Order File 
    [Arguments]     ${order}
    Screenshot          //div[@id="robot-preview-image"]                 ${useDir}${order}[Order number].png
    ${receiptData}=     Get Element Attribute    //div[@id="receipt"]    outerHTML
    Html To Pdf         ${receiptData}    ${useDir}${order}[Order number].pdf
    Add Watermark Image To Pdf    ${useDir}${order}[Order number].png    ${useDir}${order}[Order number].pdf    ${useDir}${order}[Order number].pdf


    


