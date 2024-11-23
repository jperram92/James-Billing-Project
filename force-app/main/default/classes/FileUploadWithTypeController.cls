/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-23-2024
 * @last modified by  : jamesperram@gmail.com
**/

/*
 * This class handles file uploads to Salesforce and associates them with a specific record.
 * 
 * 1. Accepts inputs: recordId (the record to link the file to), documentType (e.g., "Invoice"), 
 *    base64FileContent (encoded file content), and fileName (e.g., "Contract.pdf").
 * 2. Decodes the base64-encoded file content into a readable format (Blob).
 * 3. Creates a ContentVersion record to upload the file to Salesforce.
 * 4. Retrieves the unique ContentDocumentId, which represents the file in Salesforce.
 * 5. Creates a ContentDocumentLink to associate the file with the specified record (recordId).
 *    - ShareType is set to 'V' (Viewer access), and Visibility is set to 'AllUsers.'
 * 6. Returns the ContentDocumentId for future reference.
 * 7. Includes error handling to ensure clear messages are returned if something goes wrong.
 * 
 * Purpose: This process securely uploads a file, tags it with a document type, links it to a 
 *          specific record, and ensures it's accessible to appropriate users.
 */

public class FileUploadWithTypeController {
    @AuraEnabled
    public static String uploadFile(String recordId, String documentType, String base64FileContent, String fileName) {
        try {
            // Decode base64 content to a Blob
            Blob fileBlob = EncodingUtil.base64Decode(base64FileContent);

            // Create and insert a ContentVersion object
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = fileBlob;
            contentVersion.Description = 'Document Type: ' + documentType;
            insert contentVersion;

            // Retrieve the ContentDocumentId from the inserted ContentVersion
            ContentVersion insertedContentVersion = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :contentVersion.Id
            ];

            // Create a ContentDocumentLink to associate the file with the record
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = insertedContentVersion.ContentDocumentId;
            link.LinkedEntityId = recordId;
            link.ShareType = 'V'; // Viewer access
            link.Visibility = 'AllUsers';
            insert link;

            return insertedContentVersion.ContentDocumentId;
        } catch (Exception e) {
            throw new AuraHandledException('Error uploading file: ' + e.getMessage());
        }
    }
}