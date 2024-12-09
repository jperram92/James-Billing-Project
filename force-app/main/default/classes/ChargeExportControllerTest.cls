/**
 * @description       : Test class for ChargeExportController
 * @author            : jamesperram@gmail.com
 * @last modified on  : 12-05-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class ChargeExportControllerTest {
    @isTest
    static void testExportCharges() {
        // Create test Invoice
        JBP_Invoice__c testInvoice = new JBP_Invoice__c(
            Name = 'Test Invoice',
            JBP_Invoice_Status__c = 'Pending' // Valid picklist value
        );
        insert testInvoice;

        // Create test Service Charges
        JBP_Service_Charge__c testCharge1 = new JBP_Service_Charge__c(
            Name = 'Service Charge 1',
            JBP_Charge_Date__c = Date.today().addDays(-5),
            JBP_Service_Charge_Status__c = 'Created', // Valid picklist value
            JBP_Invoice__c = testInvoice.Id
        );

        JBP_Service_Charge__c testCharge2 = new JBP_Service_Charge__c(
            Name = 'Service Charge 2',
            JBP_Charge_Date__c = Date.today().addDays(-3),
            JBP_Service_Charge_Status__c = 'Created', // Valid picklist value
            JBP_Invoice__c = testInvoice.Id
        );

        insert new List<JBP_Service_Charge__c>{testCharge1, testCharge2};

        // Execute the method
        String csvContent = ChargeExportController.exportCharges(Date.today().addDays(-10), Date.today());

        // Validate CSV content
        System.assertNotEquals('', csvContent, 'CSV content should not be empty.');

        // Validate service charges were updated
        List<JBP_Service_Charge__c> updatedCharges = [
            SELECT JBP_Service_Charge_Status__c
            FROM JBP_Service_Charge__c
            WHERE Id IN (:testCharge1.Id, :testCharge2.Id)
        ];
        System.assertEquals('Exported', updatedCharges[0].JBP_Service_Charge_Status__c);
        System.assertEquals('Exported', updatedCharges[1].JBP_Service_Charge_Status__c);

        // Validate invoice was updated
        JBP_Invoice__c updatedInvoice = [
            SELECT JBP_Invoice_Status__c
            FROM JBP_Invoice__c
            WHERE Id = :testInvoice.Id
        ];
        System.assertEquals('Exported', updatedInvoice.JBP_Invoice_Status__c);
    }

    @isTest
    static void testNoServiceCharges() {
        // Create test Invoice
        JBP_Invoice__c testInvoice = new JBP_Invoice__c(
            Name = 'Test Invoice',
            JBP_Invoice_Status__c = 'Pending' // Valid picklist value
        );
        insert testInvoice;

        // Create test Service Charge outside the date range
        JBP_Service_Charge__c testCharge = new JBP_Service_Charge__c(
            Name = 'Service Charge Outside Range',
            JBP_Charge_Date__c = Date.today().addDays(-15), // Outside the export date range
            JBP_Service_Charge_Status__c = 'Created', // Valid picklist value
            JBP_Invoice__c = testInvoice.Id
        );
        insert testCharge;

        // Execute exportCharges
        String result = ChargeExportController.exportCharges(Date.today().addDays(-10), Date.today());

        // Validate result
        System.assertEquals(
            'No records found for the selected date range.',
            result,
            'Method should return a message when no matching service charges are found.'
        );

        // Ensure service charge status is unchanged
        JBP_Service_Charge__c unchangedCharge = [
            SELECT JBP_Service_Charge_Status__c
            FROM JBP_Service_Charge__c
            WHERE Id = :testCharge.Id
        ];
        System.assertEquals('Created', unchangedCharge.JBP_Service_Charge_Status__c, 'Service charge status should remain unchanged.');
    }

    @isTest
    static void testInvalidDates() {
        // Create test Invoice
        JBP_Invoice__c testInvoice = new JBP_Invoice__c(
            Name = 'Test Invoice',
            JBP_Invoice_Status__c = 'Pending' // Valid picklist value
        );
        insert testInvoice;

        // Create test Service Charge
        JBP_Service_Charge__c testCharge = new JBP_Service_Charge__c(
            Name = 'Service Charge',
            JBP_Charge_Date__c = Date.today(),
            JBP_Service_Charge_Status__c = 'Created', // Valid picklist value
            JBP_Invoice__c = testInvoice.Id
        );
        insert testCharge;

        // Execute exportCharges with invalid dates
        try {
            String result = ChargeExportController.exportCharges(Date.today().addDays(1), Date.today().addDays(-1));
            System.assert(false, 'Method should have thrown an exception for invalid date ranges.');
        } catch (AuraHandledException e) {
            System.assertEquals(
                'Start date must be before or equal to the end date.',
                e.getMessage(),
                'Method should throw a user-friendly error for invalid date ranges.'
            );
        }

        // Ensure service charge status is unchanged
        JBP_Service_Charge__c unchangedCharge = [
            SELECT JBP_Service_Charge_Status__c
            FROM JBP_Service_Charge__c
            WHERE Id = :testCharge.Id
        ];
        System.assertEquals('Created', unchangedCharge.JBP_Service_Charge_Status__c, 'Charge status should remain unchanged.');
    }
}