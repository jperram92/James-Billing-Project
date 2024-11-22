/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-22-2024
 * @last modified by  : jamesperram@gmail.com
**/
@IsTest
public class ValidateFileAttachmentTest {
    @IsTest
    static void testAttachmentValidation() {
        // Step 1: Create a test JPB_Pre_Check_Form__c record without attachments
        JPB_Pre_Check_Form__c testForm = new JPB_Pre_Check_Form__c(Name = 'Test Form');
        
        Test.startTest();
        try {
            insert testForm;
            System.assert(false, 'The trigger should have prevented insertion without attachments.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('At least one document must be attached'),
                'Error message should indicate missing attachments.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testWithAttachment() {
        // Step 2: Create a test JPB_Pre_Check_Form__c record
        JPB_Pre_Check_Form__c testForm = new JPB_Pre_Check_Form__c(Name = 'Test Form');
        insert testForm;

        // Step 3: Attach a document to the form using ContentDocumentLink
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Sample content'),
            FirstPublishLocationId = testForm.Id
        );
        insert contentVersion;

        // Step 4: Update the form, ensuring no errors occur
        testForm.Name = 'Updated Test Form';
        
        Test.startTest();
        update testForm; // This should succeed because a document is attached
        Test.stopTest();

        // Step 5: Validate the attachment
        Integer attachedFiles = [
            SELECT COUNT()
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :testForm.Id
        ];
        System.assertEquals(1, attachedFiles, 'There should be exactly one attached file.');
    }
}