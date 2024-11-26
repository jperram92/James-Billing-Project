/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-26-2024
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class PreCheckFormController {
    public String signatureData { get; set; }
    private JPB_Pre_Check_Form__c preCheckForm;

    public PreCheckFormController(ApexPages.StandardController stdController) {
        preCheckForm = (JPB_Pre_Check_Form__c) stdController.getRecord();
    }

    public PageReference save() {
        try {
            if (String.isNotBlank(signatureData)) {
                // Save signature as an attachment
                Attachment signatureAttachment = new Attachment(
                    ParentId = preCheckForm.Id,
                    Name = 'Customer_Signature.png',
                    Body = EncodingUtil.base64Decode(signatureData.substringAfter(',')),
                    ContentType = 'image/png'
                );
                insert signatureAttachment;
            }

            // Check if the Signature Timestamp field exists before updating
            if (Schema.sObjectType.JPB_Pre_Check_Form__c.fields.getMap().containsKey('Signature_Timestamp__c')) {
                preCheckForm.put('Signature_Timestamp__c', System.now()); // Use generic put() for dynamic fields
            }

            // Update record without bypassing validation rules
            update preCheckForm;

        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving signature: ' + ex.getMessage()));
        }

        // Redirect or provide a confirmation message
        return ApexPages.currentPage();
    }
}
