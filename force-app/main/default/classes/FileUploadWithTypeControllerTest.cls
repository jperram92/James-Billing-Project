/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-22-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class FileUploadWithTypeControllerTest {
    @isTest
    static void testUploadFile() {
        // Create a test Contact record
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;

        // Test parameters
        String recordId = testContact.Id;
        String documentType = 'Test Document Type';
        String base64FileContent = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        String fileName = 'TestFile.txt';

        // Execute the method
        System.Test.startTest();
        try {
            String documentId = FileUploadWithTypeController.uploadFile(recordId, documentType, base64FileContent, fileName);
            System.assertNotEquals(null, documentId, 'Document ID should not be null.');

            // Validate the inserted record
            Document__c createdDocument = [SELECT Id, Name, Document_Type__c, Contact__c FROM Document__c WHERE Id = :documentId];
            System.assertEquals(fileName, createdDocument.Name, 'File name should match.');
            System.assertEquals(documentType, createdDocument.Document_Type__c, 'Document type should match.');
            System.assertEquals(recordId, createdDocument.Contact__c, 'Contact reference should match.');
        } catch (Exception e) {
            System.debug('Error occurred: ' + e.getMessage());
            System.assert(false, 'Unexpected exception occurred: ' + e.getMessage());
        }
        System.Test.stopTest();
    }
}