/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-05-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class CreateOpportunityFromPreCheckTest {

    @testSetup
    static void setupTestData() {
        // HARDCODED Standard Pricebook ID
        Id standardPricebookId = '01sNS000002S2fGYAS';

        // Step 1: Create Products
        Product2 product1 = new Product2(
            Name = 'Mock Product 1',
            IsActive = true
        );
        Product2 product2 = new Product2(
            Name = 'Mock Product 2',
            IsActive = true
        );
        insert new List<Product2>{product1, product2};

        // Step 2: Create Hardcoded Pricebook Entries
        PricebookEntry entry1 = createHardcodedPricebookEntry(standardPricebookId, product1, 100);
        PricebookEntry entry2 = createHardcodedPricebookEntry(standardPricebookId, product2, 200);

        // Step 3: Create Mock Pre-Check Form Records
        List<JPB_Pre_Check_Form__c> preCheckForms = new List<JPB_Pre_Check_Form__c>{
            new JPB_Pre_Check_Form__c(
                Name = 'Pre-Check Form 1',
                JBP_Status__c = 'Draft',
                Product__c = product1.Id,
                JBP_Charge_Units__c = 2,
                JBP_Services_Interested__c = 'Home Care' // Add required field
            ),
            new JPB_Pre_Check_Form__c(
                Name = 'Pre-Check Form 2',
                JBP_Status__c = 'Draft',
                Product__c = product2.Id,
                JBP_Charge_Units__c = 3,
                JBP_Services_Interested__c = 'Home Care' // Add required field
            )
        };
        insert preCheckForms;

        // Step 4: Attach a fake CSV file to one of the Pre-Check Forms
        attachFakeCSV(preCheckForms[0].Id, 'Fake CSV Data,Column1,Column2\nValue1,Value2,Value3');
    }

    @isTest
    static void testTriggerValidData() {
        // Fetch Pre-Check Forms
        List<JPB_Pre_Check_Form__c> preCheckForms = [SELECT Id, JBP_Status__c FROM JPB_Pre_Check_Form__c];
        System.assert(!preCheckForms.isEmpty(), 'Pre-Check Forms should exist.');

        // Update Pre-Check Forms to Approved
        for (JPB_Pre_Check_Form__c preCheck : preCheckForms) {
            preCheck.JBP_Status__c = 'Approved';
        }
        update preCheckForms;

        // Verify that Opportunities are created
        List<Opportunity> opportunities = [SELECT Id, Name, StageName, CloseDate FROM Opportunity];
        System.assertEquals(preCheckForms.size(), opportunities.size(), 'Opportunities should match the number of Pre-Check Forms.');

        // Verify that Opportunity Line Items are created
        List<OpportunityLineItem> lineItems = [
            SELECT Id, OpportunityId, PricebookEntryId
            FROM OpportunityLineItem
        ];
        System.assertEquals(preCheckForms.size(), lineItems.size(), 'Line Items should match the number of Pre-Check Forms.');
    }

    private static PricebookEntry createHardcodedPricebookEntry(Id standardPricebookId, Product2 product, Decimal unitPrice) {
        // Create a Pricebook Entry
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert pricebookEntry;
        return pricebookEntry;
    }

    private static void attachFakeCSV(Id recordId, String csvContent) {
        // Create a ContentVersion record (represents the file in Salesforce)
        ContentVersion contentVersion = new ContentVersion(
            Title = 'FakeCSV.csv',
            PathOnClient = 'FakeCSV.csv',
            VersionData = Blob.valueOf(csvContent),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Link the ContentVersion to the Pre-Check Form record
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = recordId,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert contentDocumentLink;
    }
}
