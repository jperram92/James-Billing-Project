/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-22-2024
 * @last modified by  : jamesperram@gmail.com
**/
trigger ValidateFileAttachment on JPB_Pre_Check_Form__c (before insert, before update) {
    for (JPB_Pre_Check_Form__c form : Trigger.new) {
        // Query to count attached files/documents using ContentDocumentLink
        Integer attachedFiles = [
            SELECT COUNT()
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :form.Id
        ];

        // Add validation error if no files are attached
        if (attachedFiles == 0) {
            form.addError('At least one document must be attached before submission.');
        }
    }
}
