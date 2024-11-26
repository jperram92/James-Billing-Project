/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-26-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class PreCheckFormControllerTest {
    @isTest
    static void testSaveWithSignature() {
        // Create a mock record for JPB_Pre_Check_Form__c
        JPB_Pre_Check_Form__c preCheckForm = new JPB_Pre_Check_Form__c(
            Name = 'Test Pre-Check Form'
        );
        insert preCheckForm;

        // Create a standard controller for the test
        ApexPages.StandardController stdController = new ApexPages.StandardController(preCheckForm);
        PreCheckFormController controller = new PreCheckFormController(stdController);

        // Mock signature data (Base64 encoded PNG image string)
        String mockSignatureData = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAU...'; // Truncated example
        controller.signatureData = mockSignatureData;

        // Call the save method
        Test.startTest();
        PageReference result = controller.save();
        Test.stopTest();

        // Validate that the Attachment was created
        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :preCheckForm.Id];
        System.assertEquals(1, attachments.size(), 'An attachment should be created');
        System.assertEquals('Customer_Signature.png', attachments[0].Name, 'Attachment name should match');

        // Validate that the Signature_Timestamp__c field was updated
        JPB_Pre_Check_Form__c updatedPreCheckForm = [SELECT Signature_Timestamp__c FROM JPB_Pre_Check_Form__c WHERE Id = :preCheckForm.Id];
        System.assertNotEquals(null, updatedPreCheckForm.Signature_Timestamp__c, 'Signature_Timestamp__c should be updated');
    }

    @isTest
    static void testSaveWithoutSignature() {
        // Create a mock record for JPB_Pre_Check_Form__c
        JPB_Pre_Check_Form__c preCheckForm = new JPB_Pre_Check_Form__c(
            Name = 'Test Pre-Check Form'
        );
        insert preCheckForm;

        // Create a standard controller for the test
        ApexPages.StandardController stdController = new ApexPages.StandardController(preCheckForm);
        PreCheckFormController controller = new PreCheckFormController(stdController);

        // Call the save method without signature data
        Test.startTest();
        PageReference result = controller.save();
        Test.stopTest();

        // Validate that no Attachment was created
        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :preCheckForm.Id];
        System.assertEquals(0, attachments.size(), 'No attachment should be created');

        // Validate that the Signature_Timestamp__c field was updated
        JPB_Pre_Check_Form__c updatedPreCheckForm = [SELECT Signature_Timestamp__c FROM JPB_Pre_Check_Form__c WHERE Id = :preCheckForm.Id];
        System.assertNotEquals(null, updatedPreCheckForm.Signature_Timestamp__c, 'Signature_Timestamp__c should be updated');
    }

    @isTest
    static void testSaveWithException() {
        // Create a mock record for JPB_Pre_Check_Form__c
        JPB_Pre_Check_Form__c preCheckForm = new JPB_Pre_Check_Form__c(
            Name = 'Test Pre-Check Form'
        );
        insert preCheckForm;

        // Create a standard controller for the test
        ApexPages.StandardController stdController = new ApexPages.StandardController(preCheckForm);
        PreCheckFormController controller = new PreCheckFormController(stdController);

        // Assign invalid signature data to trigger an exception
        controller.signatureData = 'invalid-base64-data';

        // Call the save method and catch the exception
        Test.startTest();
        PageReference result = controller.save();
        Test.stopTest();

        // Validate that an error message was added
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size(), 'An error message should be added');
        System.assert(messages[0].getSummary().contains('Error saving signature'), 'Error message should match');
    }
}
