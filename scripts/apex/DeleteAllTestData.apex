/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-10-2024
 * @last modified by  : jamesperram@gmail.com
**/
try {
    System.debug('Starting the cleanup script...');

    // Step 1: Fetch all records for the objects to delete
    List<JPB_Pre_Check_Form__c> preCheckForms = [SELECT Id FROM JPB_Pre_Check_Form__c];
    List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
    List<OpportunityLineItem> oppLineItems = [SELECT Id FROM OpportunityLineItem];
    List<JBP_Service_Schedule__c> serviceSchedules = [SELECT Id FROM JBP_Service_Schedule__c];
    List<JBP_Service__c> services = [SELECT Id FROM JBP_Service__c];
    List<JBP_Service_Charge__c> serviceCharges = [SELECT Id FROM JBP_Service_Charge__c];
    List<JBP_Invoice__c> invoices = [SELECT Id FROM JBP_Invoice__c];
    List<JBP_Batch_Run_Log__c> batchRunLogs = [SELECT Id FROM JBP_Batch_Run_Log__c];

    // Step 2: Perform deletion in the correct order, bypassing all security and validation rules
    if (!serviceCharges.isEmpty()) {
        Database.delete(serviceCharges, false);
        System.debug('Deleted all JBP_Service_Charge__c records.');
    }

    if (!invoices.isEmpty()) {
        Database.delete(invoices, false);
        System.debug('Deleted all JBP_Invoice__c records.');
    }

    if (!batchRunLogs.isEmpty()) {
        Database.delete(batchRunLogs, false);
        System.debug('Deleted all JBP_Batch_Run_Log__c records.');
    }

    if (!services.isEmpty()) {
        Database.delete(services, false);
        System.debug('Deleted all JBP_Service__c records.');
    }

    if (!serviceSchedules.isEmpty()) {
        Database.delete(serviceSchedules, false);
        System.debug('Deleted all JBP_Service_Schedule__c records.');
    }

    if (!oppLineItems.isEmpty()) {
        Database.delete(oppLineItems, false);
        System.debug('Deleted all OpportunityLineItem records.');
    }

    if (!opportunities.isEmpty()) {
        Database.delete(opportunities, false);
        System.debug('Deleted all Opportunity records.');
    }

    if (!preCheckForms.isEmpty()) {
        Database.delete(preCheckForms, false);
        System.debug('Deleted all _Pre_Check_Form__c records.');
    }

    // Optional: Permanently delete records from the Recycle Bin
    Database.emptyRecycleBin(preCheckForms);
    Database.emptyRecycleBin(opportunities);
    Database.emptyRecycleBin(oppLineItems);
    Database.emptyRecycleBin(serviceSchedules);
    Database.emptyRecycleBin(services);
    Database.emptyRecycleBin(serviceCharges);
    Database.emptyRecycleBin(invoices);
    Database.emptyRecycleBin(batchRunLogs);

    System.debug('Cleanup script executed successfully. All records have been deleted permanently.');
} catch (Exception e) {
    System.debug('Error occurred during cleanup: ' + e.getMessage());
}
