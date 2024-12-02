/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-02-2024
 * @last modified by  : jamesperram@gmail.com
**/
public class ChargeExportUtility {
    public static String generateInvoiceCSV(Date startDate, Date endDate) {
        // Fetch Related Service Charges with Service Schedule and Invoice Details, excluding already exported records
        List<JBP_Service_Charge__c> serviceCharges = [
            SELECT JBP_Invoice__c, JBP_Charge_Date__c, Name, JBP_Quantity_To_Charge__c, JBP_Rate_To_Charge__c, JBP_Total_Charge__c,
                   JBP_Invoice__r.Name, JBP_Invoice__r.JBP_Customer_Account__c, JBP_Invoice__r.JBP_Total_Invoice_Amount__c, JBP_Invoice__r.JBP_Invoice_Number__c,
                   Service_Schedule__r.JBP_Service_Type__c, JBP_Service_Charge_Status__c
            FROM JBP_Service_Charge__c
            WHERE JBP_Charge_Date__c >= :startDate 
              AND JBP_Charge_Date__c <= :endDate
              AND JBP_Service_Charge_Status__c != 'Exported'
        ];
        System.debug('Service Charges fetched for CSV (non-exported only): ' + serviceCharges);

        // Generate CSV Content
        String csv = 'Invoice Number,Charge Date,Customer Name,Total Invoice Amount,Service Type,Quantity,Charge Per Unit,Total Per Line,Description\n';

        for (JBP_Service_Charge__c charge : serviceCharges) {
            // Construct Description using Name and JBP_Service_Type__c
            String serviceType = charge.Service_Schedule__r != null ? charge.Service_Schedule__r.JBP_Service_Type__c : 'N/A';
            String description = charge.Name + ' (' + serviceType + ')';

            // Add Row to CSV
            csv += String.join(new String[] {
                charge.JBP_Invoice__r != null ? charge.JBP_Invoice__r.JBP_Invoice_Number__c : 'N/A', // Invoice Number
                String.valueOf(charge.JBP_Charge_Date__c),
                charge.JBP_Invoice__r != null ? String.valueOf(charge.JBP_Invoice__r.JBP_Customer_Account__c) : 'N/A',
                charge.JBP_Invoice__r != null ? String.valueOf(charge.JBP_Invoice__r.JBP_Total_Invoice_Amount__c) : 'N/A',
                serviceType,
                String.valueOf(charge.JBP_Quantity_To_Charge__c),
                String.valueOf(charge.JBP_Rate_To_Charge__c),
                String.valueOf(charge.JBP_Total_Charge__c),
                description
            }, ',') + '\n';
        }

        System.debug('Generated CSV Content: ' + csv);
        return csv;
    }
}
