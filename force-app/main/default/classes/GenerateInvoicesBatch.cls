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
global GenerateInvoicesBatch(Date startDate, Date endDate) {
        this.batchStartDate = startDate;
        this.batchEndDate = endDate;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Contact__c, JBP_Total_Charge__c
            FROM JBP_Service_Charge__c
            WHERE JBP_Charge_Date__c >= :batchStartDate
            AND JBP_Charge_Date__c <= :batchEndDate
            AND JBP_Locked__c = FALSE
        ]);
    }
    global void execute(Database.BatchableContext BC, List<JBP_Service_Charge__c> scope) {
        Map<Id, JBP_Invoice__c> invoiceMap = new Map<Id, JBP_Invoice__c>();
        List<JBP_Service_Charge__c> chargesToUpdate = new List<JBP_Service_Charge__c>();
        
        try {
            // Group charges by customer and create invoices
            for (JBP_Service_Charge__c charge : scope) {
                if (!invoiceMap.containsKey(charge.Contact__c)) {
                    invoiceMap.put(charge.Contact__c, new JBP_Invoice__c(
                        JBP_Customer_Account__c = charge.Contact__c,
                        JBP_Total_Invoice_Amount__c = 0,
                        JBP_Invoice_Status__c = 'Pending',
                        JBP_Batch_Run_Id__c = String.valueOf(System.now())
                    ));
                }
                JBP_Invoice__c invoice = invoiceMap.get(charge.Contact__c);
                invoice.JBP_Total_Invoice_Amount__c += charge.JBP_Total_Charge__c;
                invoice.JBP_Number_of_Charges__c = (invoice.JBP_Number_of_Charges__c == null) ? 1 : invoice.JBP_Number_of_Charges__c + 1;
                charge.JBP_Invoice__c = invoice.Id;
                charge.JBP_Locked__c = TRUE;
                chargesToUpdate.add(charge);
            }
            // Insert invoices
            if (!invoiceMap.isEmpty()) {
                insert invoiceMap.values();
            }
            // Update service charges
            if (!chargesToUpdate.isEmpty()) {
                update chargesToUpdate;
            }
            totalProcessedRecords += chargesToUpdate.size();
        } catch (Exception e) {
            errorMessages.add('Error during execution: ' + e.getMessage());
        }
    }
    global void finish(Database.BatchableContext BC) {
        // Log batch run
        JBP_Batch_Run_Log__c log = new JBP_Batch_Run_Log__c(
            JBP_Batch_Type__c = 'Weekly',
            JBP_Execution_Date__c = System.now(),
            JBP_Number_of_Records_Processed__c = totalProcessedRecords,
            JBP_Status__c = errorMessages.isEmpty() ? 'Success' : 'Partial Failure',
            JBP_Error_Message__c = errorMessages.isEmpty() ? null : String.join(errorMessages, '; ')
        );
        insert log;
        System.debug('Batch completed with status: ' + log.JBP_Status__c);
    }
}