/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-26-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class CreateOpportunityFromPreCheckTest {

    @testSetup
    static void setupTestData() {
        // Create Products
        Product2 product1 = new Product2(Name = 'Mock Product 1', IsActive = true);
        Product2 product2 = new Product2(Name = 'Mock Product 2', IsActive = true);
        insert new List<Product2>{product1, product2};

        // Create a Mock Pricebook
        Pricebook2 mockPricebook = new Pricebook2(Name = 'Mock Pricebook', IsActive = true);
        insert mockPricebook;

        // Create Pricebook Entries
        PricebookEntry entry1 = new PricebookEntry(Product2Id = product1.Id, Pricebook2Id = mockPricebook.Id, UnitPrice = 100, IsActive = true);
        PricebookEntry entry2 = new PricebookEntry(Product2Id = product2.Id, Pricebook2Id = mockPricebook.Id, UnitPrice = 200, IsActive = true);
        insert new List<PricebookEntry>{entry1, entry2};

        // Create Mock JPB_Pre_Check_Form Records
        List<JPB_Pre_Check_Form__c> preCheckForms = new List<JPB_Pre_Check_Form__c>{
            new JPB_Pre_Check_Form__c(Name = 'Pre-Check Form 1', JBP_Status__c = 'Pending', Product__c = product1.Id, JBP_Charge_Units__c = 2),
            new JPB_Pre_Check_Form__c(Name = 'Pre-Check Form 2', JBP_Status__c = 'Pending', Product__c = product2.Id, JBP_Charge_Units__c = 3)
        };
        insert preCheckForms;
    }

    @isTest
    static void testTriggerValidData() {
        // Fetch Pre-Check Forms
        List<JPB_Pre_Check_Form__c> preCheckForms = [SELECT Id, JBP_Status__c FROM JPB_Pre_Check_Form__c];
        System.assert(!preCheckForms.isEmpty(), 'Pre-Check Forms should exist');

        // Update Pre-Check Forms to Approved
        for (JPB_Pre_Check_Form__c preCheck : preCheckForms) {
            preCheck.JBP_Status__c = 'Approved';
        }
        update preCheckForms;

        // Verify that Opportunities are created
        List<Opportunity> opportunities = [SELECT Id, Name, StageName, CloseDate FROM Opportunity];
        System.assertEquals(preCheckForms.size(), opportunities.size(), 'Opportunities should match the number of Pre-Check Forms');

        // Verify that Opportunity Line Items are created
        List<OpportunityLineItem> lineItems = [SELECT Id, OpportunityId, PricebookEntryId FROM OpportunityLineItem];
        System.assertEquals(preCheckForms.size(), lineItems.size(), 'Line Items should match the number of Pre-Check Forms');
    }
}
