/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-05-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class ChargeExportUtilityTest {
    @isTest
    static void testGenerateInvoiceCSV() {
        // Step 1: Create test data
        JBP_Invoice__c testInvoice = new JBP_Invoice__c(
            Name = 'Test Invoice',
            JBP_Customer_Account__c = 'Test Customer',
            JBP_Total_Invoice_Amount__c = 1500.00,
            JBP_Invoice_Status__c = 'Pending'
        );
        insert testInvoice;

        // Create a service charge related to the invoice
        JBP_Service_Charge__c testCharge = new JBP_Service_Charge__c(
            Name = 'Test Service Charge',
            JBP_Charge_Date__c = Date.today().addDays(-1),
            JBP_Quantity_To_Charge__c = 2,
            JBP_Service_Charge_Status__c = 'Created',
            JBP_Invoice__c = testInvoice.Id
        );
        insert testCharge;

        // Fetch values for calculated fields after insertion (if needed)
        JBP_Service_Charge__c insertedCharge = [
            SELECT JBP_Rate_To_Charge__c, JBP_Total_Charge__c
            FROM JBP_Service_Charge__c
            WHERE Id = :testCharge.Id
        ];

        // Step 2: Call the method
        String csvContent = ChargeExportUtility.generateInvoiceCSV(Date.today().addDays(-5), Date.today());

        // Step 3: Validate the CSV content
        System.assertNotEquals('', csvContent, 'CSV content should not be empty.');
        System.assert(csvContent.contains(testInvoice.Name), 'CSV should contain the invoice name.');
        System.assert(csvContent.contains('Test Customer'), 'CSV should contain the customer name.');
        System.assert(csvContent.contains('Test Service Charge'), 'CSV should contain the service charge name.');

        // Validate that the service charge status remains unchanged
        JBP_Service_Charge__c unchangedCharge = [
            SELECT JBP_Service_Charge_Status__c
            FROM JBP_Service_Charge__c
            WHERE Id = :testCharge.Id
        ];
        System.assertEquals('Created', unchangedCharge.JBP_Service_Charge_Status__c, 'The service charge status should remain as Created.');
    }
}