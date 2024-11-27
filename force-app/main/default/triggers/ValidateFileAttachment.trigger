/**
 * @description       : Validates that a JPB_Pre_Check_Form__c record has at least one attached document.
 * @author            : jamesperram@gmail.com
 * @last modified on  : 11-27-2024
 * @last modified by  : jamesperram@gmail.com
**/
trigger ValidateFileAttachment on JPB_Pre_Check_Form__c (before update) {
    // Collect the record IDs to validate attachments for
    Set<Id> formIds = new Set<Id>();
    for (JPB_Pre_Check_Form__c form : Trigger.new) {
        if (form.Id != null) {
            formIds.add(form.Id);
        }
    }

    if (!formIds.isEmpty()) {
        // Query ContentDocumentLinks for the forms
        Map<Id, Integer> formFileCounts = new Map<Id, Integer>();
        for (AggregateResult result : [
            SELECT LinkedEntityId, COUNT(Id) fileCount
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :formIds
            GROUP BY LinkedEntityId
        ]) {
            formFileCounts.put((Id) result.get('LinkedEntityId'), (Integer) result.get('fileCount'));
        }

        // Add validation errors for forms with no attached files
        for (JPB_Pre_Check_Form__c form : Trigger.new) {
            if (formFileCounts.get(form.Id) == null || formFileCounts.get(form.Id) == 0) {
                form.addError('At least one document must be attached before submission.');
            }
        }
    }
}
