/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-05-2024
 * @last modified by  : jamesperram@gmail.com
**/
// Retrieve all sObjects in the org
Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();

// Loop through each sObject and print its name
for (String sObjectName : sObjectMap.keySet()) {
    // Get the DescribeSObjectResult for each sObject
    DescribeSObjectResult describeResult = sObjectMap.get(sObjectName).getDescribe();
    
    // Print the object name and whether it is custom
    System.debug('Object Name: ' + describeResult.getName());
    System.debug('Is Custom Object: ' + describeResult.isCustom());
}

//Steps to Test in Developer Console
// Open Developer Console in Salesforce.
// Go to the top menu and click Debug → Open Execute Anonymous Window.
// Paste the above code into the editor.
// Click Execute.
// View the results in the Debug Logs to see the list of objects in your org, along with metadata details like whether they are custom objects.
// Expected Output
// A list of all objects (standard and custom) in the org.
// Example debug log output:
// vbnet
// Copy code
// Object Name: Account
// Is Custom Object: false
// Object Name: MyCustomObject__c
// Is Custom Object: true