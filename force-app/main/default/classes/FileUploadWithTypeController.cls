/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-22-2024
 * @last modified by  : jamesperram@gmail.com
**/
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
