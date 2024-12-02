/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-02-2024
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class ManualInvoiceBatchController {
    @AuraEnabled
    public static String triggerInvoiceBatch(Date startDate, Date endDate) {
        try {
            GenerateInvoicesBatch batch = new GenerateInvoicesBatch(startDate, endDate);
            Database.executeBatch(batch, 50);
            return 'Batch triggered successfully!';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}