/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-06-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class AccountRatingProcessorTest {
    @isTest
    static void testAccountRatingCalculation() {
        // Create test data
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account(Name = 'Test Account ' + i);
            testAccounts.add(acc);
        }
        insert testAccounts;

        List<Opportunity> testOpportunities = new List<Opportunity>();
        Date currentDate = Date.today();
        for (Account acc : testAccounts) {
            // Closed Won Opportunities for this year
            for (Integer j = 0; j < 2; j++) {
                Opportunity opp = new Opportunity(
                    Name = 'Closed Won Opp ' + j,
                    StageName = 'Closed Won',
                    CloseDate = currentDate,
                    Amount = 1000 * (j + 1),
                    AccountId = acc.Id
                );
                testOpportunities.add(opp);
            }
            // Open Opportunities
            for (Integer k = 0; k < 3; k++) {
                Opportunity opp = new Opportunity(
                    Name = 'Open Opp ' + k,
                    StageName = 'Prospecting',
                    CloseDate = currentDate.addMonths(1),
                    Amount = 500 * (k + 1),
                    AccountId = acc.Id
                );
                testOpportunities.add(opp);
            }
        }
        insert testOpportunities;

        // Start test context
        Test.startTest();
        // Enqueue the Queueable job
        System.enqueueJob(new AccountRatingProcessor());
        // End test context
        Test.stopTest();

        // Retrieve updated accounts
        List<Account> updatedAccounts = [SELECT Id, Rating__c FROM Account WHERE Id IN :testAccounts];

        // Assert the ratings
        for (Account acc : updatedAccounts) {
            // Calculate expected rating
            Double expectedClosedValue = 3000.0; // Sum of Closed Won Opps: 1000 + 2000
            Integer openOpportunities = 3;
            Integer closedOpportunities = 2;
            Double expectedRating = expectedClosedValue + (openOpportunities * 100) - (closedOpportunities * 50);

            // Assert the Rating__c field
            System.assertEquals(expectedRating, acc.Rating__c, 'Account rating did not match expected value.');
        }
    }
}
