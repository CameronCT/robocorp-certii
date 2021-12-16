*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.Dialogs
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Robocorp.Vault
Library           RPA.FileSystem
Library           Process

*** Variables *** 
${useCurDir}            ${CURDIR}${/}
${useDataDir}           ${CURDIR}${/}data${/}
${useFilesDir}          ${CURDIR}${/}files${/}

*** Tasks ***
Executing Task List
    ${isHuman}=           Validate Is Human
    IF     '${isHuman}' == 'YES'
        Download Orders 
        ${orders}=            Parse Orders
        Process Orders        ${orders}
    ELSE  
        Log    "Not human"
        Terminate All Processes     kill=True
    END

*** Keywords ***
Validate Is Human
    Add text input    validate    label=Type "YES" if you are a human
    ${response}=    Run dialog
    [Return]    ${response.validate}

Download Orders
    ${websites}=    Get Secret    websites
    Log    websites
    Download    ${websites}[csv]    overwrite=True

Parse Orders 
    ${orders}=    Read table from CSV    orders.csv
    Log           Found Columns: ${orders.columns}
    [Return]      ${orders}

Open Store
    ${websites}=    Get Secret    websites
    Open Available Browser      ${websites}[form]
    Click Button                I guess so...

Process Orders 
    [Arguments]     ${orders}
    FOR    ${row}    IN    @{orders}
        Open Store
        Wait Until Page Contains Element     //button[@type="submit"]
        Submit Order    ${row}
        Close Browser
    END
    Archive Files
    Remove All Files
    [Teardown]    Close All Browsers

Submit Order
    [Arguments]     ${order}
    Select From List By Value     //select[@name="head"]    ${order}[Head]
    Click Element                 //input[@value="${order}[Body]"]
    Input Text                    //input[@type="number"]    ${order}[Legs]
    Input Text                    //input[@type="text"]    ${order}[Address]
    Click Element                 //button[@id="preview"]
    Click Element                 //button[@id="order"]

    ${isReceiptAvailable}=    Is Element Visible    //div[@id="receipt"]

    IF   ${isReceiptAvailable}
        Process Order File      ${order}
    ELSE 
        Submit Order            ${order}
    END
        
    Log    ${order}

Process Order File 
    [Arguments]                     ${order}
    Screenshot                      //div[@id="robot-preview-image"]                 ${useDataDir}${order}[Order number].png
    ${receiptData}=                 Get Element Attribute    //div[@id="receipt"]    outerHTML
    Html To Pdf                     ${receiptData}    ${useDataDir}${order}[Order number].pdf
    Add Watermark Image To Pdf      ${useDataDir}${order}[Order number].png    ${useDataDir}${order}[Order number].pdf    ${useDataDir}${order}[Order number].pdf
    Remove file                     ${useDataDir}${order}[Order number].png

Remove All Files 
    ${files}=    List files in directory    ${useDataDir}
    FOR    ${file}  IN  @{FILES}
        Remove file     ${file}
    END
    Remove file     ${useCurDir}orders.csv

Archive Files 
    Create Directory         ${useFilesDir}
    Archive Folder With Zip  ${useDataDir}  ${useFilesDir}receipts.zip    True
    


