/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-02-2024
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class ChargeExportController {
    @AuraEnabled
    public static String exportCharges(Date startDate, Date endDate) {
        System.debug('Export Charges triggered with Start Date: ' + startDate + ', End Date: ' + endDate);

        try {
            // Generate CSV Content
            String csvContent = ChargeExportUtility.generateInvoiceCSV(startDate, endDate);
            System.debug('CSV Content Generated Successfully.');

            // Fetch all service charges within the date range
            List<JBP_Service_Charge__c> serviceCharges = [
                SELECT Id, JBP_Invoice__c, JBP_Service_Charge_Status__c
                FROM JBP_Service_Charge__c
                WHERE JBP_Charge_Date__c >= :startDate
                  AND JBP_Charge_Date__c <= :endDate
                  AND JBP_Invoice__c != null
            ];

            if (serviceCharges.isEmpty()) {
                System.debug('No Service Charges found for the selected date range.');
                return 'No records found for the selected date range.';
            }

            // Prepare to update statuses for Service Charges and Invoices
            List<JBP_Service_Charge__c> serviceChargesToUpdate = new List<JBP_Service_Charge__c>();
            Set<Id> invoiceIds = new Set<Id>();

            for (JBP_Service_Charge__c charge : serviceCharges) {
                charge.JBP_Service_Charge_Status__c = 'Exported'; // Update Service Charge Status
                serviceChargesToUpdate.add(charge);

                if (charge.JBP_Invoice__c != null) {
                    invoiceIds.add(charge.JBP_Invoice__c);
                }
            }

            // Fetch and update related invoices
            List<JBP_Invoice__c> invoicesToUpdate = new List<JBP_Invoice__c>();
            if (!invoiceIds.isEmpty()) {
                List<JBP_Invoice__c> invoices = [
                    SELECT Id, JBP_Invoice_Status__c
                    FROM JBP_Invoice__c
                    WHERE Id IN :invoiceIds
                ];

                for (JBP_Invoice__c invoice : invoices) {
                    invoice.JBP_Invoice_Status__c = 'Exported'; // Update Invoice Status
                    invoicesToUpdate.add(invoice);
                }
            }

            // Perform DML Updates
            if (!serviceChargesToUpdate.isEmpty()) {
                update serviceChargesToUpdate;
                System.debug('Updated Service Charges: ' + serviceChargesToUpdate);
            }

            if (!invoicesToUpdate.isEmpty()) {
                update invoicesToUpdate;
                System.debug('Updated Invoices: ' + invoicesToUpdate);
            }

            // Return the generated CSV content
            return csvContent;

        } catch (Exception e) {
            System.debug('Error during export process: ' + e.getMessage());
            throw new AuraHandledException('An unexpected error occurred during the export process. Please try again.');
        }
    }
}
