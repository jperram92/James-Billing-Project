/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-05-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class CostBalanceCalculatorTest {

    @isTest
    static void testCalculateBalanceWithMixedData() {
        Opportunity testOpportunity = createTestOpportunity();

        PricebookEntry hardcodedPBE = createHardcodedPricebookEntry();

        OpportunityLineItem product1 = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            UnitPrice = 150,
            Quantity = 7,
            JBP_Quantity_Consumed__c = 3,
            PricebookEntryId = hardcodedPBE.Id
        );
        OpportunityLineItem product2 = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            UnitPrice = 0, // Zero price is allowed
            Quantity = 1, // Minimum valid quantity
            JBP_Quantity_Consumed__c = 0,
            PricebookEntryId = hardcodedPBE.Id
        );
        OpportunityLineItem product3 = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            UnitPrice = 200,
            Quantity = 4,
            JBP_Quantity_Consumed__c = null, // Null consumed
            PricebookEntryId = hardcodedPBE.Id
        );

        insert new List<OpportunityLineItem>{product1, product2, product3};

        Map<Id, Decimal> balances = CostBalanceCalculator.calculateBalance(new List<OpportunityLineItem>{product1, product2, product3});

        // Validations
        System.assertEquals(600, balances.get(product1.Id), 'Balance for product1 should be 600.');
        System.assertEquals(0, balances.get(product2.Id), 'Balance for product2 should be 0.');
        System.assertEquals(800, balances.get(product3.Id), 'Balance for product3 should be 800.');
    }

    @isTest
    static void testCalculateTotalBalanceWithEdgeCases() {
        Opportunity testOpportunity = createTestOpportunity();

        PricebookEntry hardcodedPBE = createHardcodedPricebookEntry();

        OpportunityLineItem product1 = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            UnitPrice = 100,
            Quantity = 10,
            JBP_Quantity_Consumed__c = 5,
            PricebookEntryId = hardcodedPBE.Id
        );
        OpportunityLineItem product2 = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            UnitPrice = 0, // Zero price is allowed
            Quantity = 5,
            JBP_Quantity_Consumed__c = 2,
            PricebookEntryId = hardcodedPBE.Id
        );

        insert new List<OpportunityLineItem>{product1, product2};

        Decimal totalBalance = CostBalanceCalculator.calculateTotalBalance(new List<OpportunityLineItem>{product1, product2});

        // Validations
        System.assertEquals(500, totalBalance, 'Total balance should be 500.');
    }

    @isTest
    static void testCalculateWithEmptyProductLines() {
        Map<Id, Decimal> balances = CostBalanceCalculator.calculateBalance(new List<OpportunityLineItem>());
        Decimal totalBalance = CostBalanceCalculator.calculateTotalBalance(new List<OpportunityLineItem>());

        System.assertEquals(0, balances.size(), 'Balance map should be empty for an empty list.');
        System.assertEquals(0, totalBalance, 'Total balance should be 0 for an empty list.');
    }

    private static PricebookEntry createHardcodedPricebookEntry() {
        // HARDCODED Standard Pricebook ID
        Id standardPricebookId = '01sNS000002S2fGYAS';

        // Create a dummy product
        Product2 product = new Product2(
            Name = 'Dummy Product JPTEST',
            IsActive = true
        );
        insert product;

        // Directly create a Pricebook Entry
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;

        return pricebookEntry;
    }

    private static Opportunity createTestOpportunity() {
        Opportunity opportunity = new Opportunity(
            Name = 'Dummy Opportunity JPTEST',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opportunity;
        return opportunity;
    }
}
