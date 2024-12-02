/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-02-2024
 * @last modified by  : jamesperram@gmail.com
**/
global class GenerateInvoicesBatch implements Database.Batchable<SObject>, Database.Stateful {
    private Date batchStartDate;
    private Date batchEndDate;
    private Integer totalProcessedRecords = 0;
    private List<String> errorMessages = new List<String>();
    private Id batchRunLogId; // Store the Batch_Run_Log__c ID
    
    // Constructor
    global GenerateInvoicesBatch(Date startDate, Date endDate) {
        this.batchStartDate = startDate;
        this.batchEndDate = endDate;

        // Create the Batch_Run_Log__c record at the start
        JBP_Batch_Run_Log__c log = new JBP_Batch_Run_Log__c(
            JBP_Batch_Type__c = 'Weekly',
            JBP_Execution_Date__c = System.now(),
            JBP_Number_of_Records_Processed__c = 0, // Will update this later
            JBP_Status__c = 'In Progress'
        );
        insert log;
        batchRunLogId = log.Id; // Capture the ID of the Batch_Run_Log__c
    }
    
    // Query for Service Charges
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Contact__c, JBP_Total_Charge__c
            FROM JBP_Service_Charge__c
            WHERE JBP_Charge_Date__c >= :batchStartDate
            AND JBP_Charge_Date__c <= :batchEndDate
            AND JBP_Locked__c = FALSE
			AND JBP_Invoice__c = NULL
        ]);
    }
    
    // Process the batch
    global void execute(Database.BatchableContext BC, List<JBP_Service_Charge__c> scope) {
        Map<Id, JBP_Invoice__c> invoiceMap = new Map<Id, JBP_Invoice__c>();
        Map<Id, Decimal> invoiceTotalMap = new Map<Id, Decimal>();
        Map<Id, Integer> invoiceChargeCountMap = new Map<Id, Integer>();
        Map<Id, List<JBP_Service_Charge__c>> chargesGroupedByBillingContact = new Map<Id, List<JBP_Service_Charge__c>>();
        
        Set<Id> contactIds = new Set<Id>();
        for (JBP_Service_Charge__c charge : scope) {
            contactIds.add(charge.Contact__c);
        }
        
        Map<Id, Id> contactToBillingContactMap = new Map<Id, Id>();
        if (!contactIds.isEmpty()) {
            for (JBP_Billing_Contact__c billingContact : [
                SELECT Id, Contact__c
                FROM JBP_Billing_Contact__c
                WHERE Contact__c IN :contactIds
            ]) {
                contactToBillingContactMap.put(billingContact.Contact__c, billingContact.Id);
            }
        }
        
        try {
            for (JBP_Service_Charge__c charge : scope) {
                Id billingContactId = contactToBillingContactMap.get(charge.Contact__c);
                
                if (billingContactId != null) {
                    if (!invoiceMap.containsKey(billingContactId)) {
                        invoiceMap.put(billingContactId, new JBP_Invoice__c(
                            JBP_Customer_Account__c = billingContactId,
                            JBP_Total_Invoice_Amount__c = 0,
                            JBP_Invoice_Status__c = 'Pending',
                            JBP_Batch_Run_Id__c = String.valueOf(System.now()),
                            Batch_Run_Log__c = batchRunLogId // Link to Batch_Run_Log__c
                        ));
                        invoiceChargeCountMap.put(billingContactId, 0);
                    }
                    
                    if (!chargesGroupedByBillingContact.containsKey(billingContactId)) {
                        chargesGroupedByBillingContact.put(billingContactId, new List<JBP_Service_Charge__c>());
                    }
                    chargesGroupedByBillingContact.get(billingContactId).add(charge);
                    
                    if (!invoiceTotalMap.containsKey(billingContactId)) {
                        invoiceTotalMap.put(billingContactId, 0);
                    }
                    invoiceTotalMap.put(billingContactId, invoiceTotalMap.get(billingContactId) + charge.JBP_Total_Charge__c);
                    
                    invoiceChargeCountMap.put(billingContactId, invoiceChargeCountMap.get(billingContactId) + 1);
                }
            }
            
            if (!invoiceMap.isEmpty()) {
                insert invoiceMap.values();
            }
            
            for (Id billingContactId : chargesGroupedByBillingContact.keySet()) {
                if (invoiceMap.containsKey(billingContactId)) {
                    Id invoiceId = invoiceMap.get(billingContactId).Id;
                    for (JBP_Service_Charge__c charge : chargesGroupedByBillingContact.get(billingContactId)) {
                        charge.JBP_Invoice__c = invoiceId;
                        charge.JBP_Locked__c = TRUE;
                    }
                }
            }
            
            List<JBP_Service_Charge__c> chargesToUpdate = new List<JBP_Service_Charge__c>();
            for (List<JBP_Service_Charge__c> charges : chargesGroupedByBillingContact.values()) {
                chargesToUpdate.addAll(charges);
            }
            
            if (!chargesToUpdate.isEmpty()) {
                update chargesToUpdate;
            }
            
            List<JBP_Invoice__c> invoicesToUpdate = new List<JBP_Invoice__c>();
            for (Id billingContactId : invoiceMap.keySet()) {
                JBP_Invoice__c invoice = invoiceMap.get(billingContactId);
                if (invoiceTotalMap.containsKey(billingContactId)) {
                    invoice.JBP_Total_Invoice_Amount__c = invoiceTotalMap.get(billingContactId);
                }
                if (invoiceChargeCountMap.containsKey(billingContactId)) {
                    invoice.JBP_Number_of_Charges__c = invoiceChargeCountMap.get(billingContactId);
                }
                invoicesToUpdate.add(invoice);
            }
            
            if (!invoicesToUpdate.isEmpty()) {
                update invoicesToUpdate;
            }
            
            totalProcessedRecords += chargesToUpdate.size();
        } catch (Exception e) {
            errorMessages.add('Error during execution: ' + e.getMessage());
        }
    }
    
    // Finalize the batch
    global void finish(Database.BatchableContext BC) {
        try {
            // Update the Batch_Run_Log__c record with results
            JBP_Batch_Run_Log__c log = [
                SELECT Id, JBP_Number_of_Records_Processed__c, JBP_Status__c, JBP_Error_Message__c
                FROM JBP_Batch_Run_Log__c
                WHERE Id = :batchRunLogId
                LIMIT 1
            ];
            log.JBP_Number_of_Records_Processed__c = totalProcessedRecords;
            log.JBP_Status__c = errorMessages.isEmpty() ? 'Success' : 'Partial Failure';
            log.JBP_Error_Message__c = errorMessages.isEmpty() ? null : String.join(errorMessages, '; ');
            update log;
            
            System.debug('Batch completed with status: ' + log.JBP_Status__c);
        } catch (Exception e) {
            System.debug('Error updating batch run log: ' + e.getMessage());
        }
    }
}
