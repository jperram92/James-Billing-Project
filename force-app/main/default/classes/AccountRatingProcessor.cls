/**
 * @description       : Updated with Test Class
 * @author            : Keri Perram
 * @group             : 
 * @last modified on  : 12-06-2024
 * @last modified by  : jamesperram@gmail.com
**/
public class AccountRatingProcessor implements Queueable {
    public void execute(QueueableContext context) {
        List<Account> accountsToUpdate = new List<Account>();
        
        // Query the Accounts with related Opportunities (closed this year and open opportunities)
        List<Account> accounts = [SELECT Id, 
                                          (SELECT Id, Amount, CloseDate, StageName FROM Opportunities WHERE CloseDate = THIS_YEAR),
                                          (SELECT Id, Amount, CloseDate, StageName FROM Opportunities WHERE IsClosed = FALSE)
                                    FROM Account];
        
        // Loop through the accounts and calculate rating based on the opportunities
        for (Account acc : accounts) {
            Double totalClosedValue = 0;
            Integer openOpportunities = acc.Opportunities.size();
            Integer closedOpportunities = 0;
            
            // Aggregate closed opportunities for this year
            for (Opportunity opp : acc.Opportunities) {
                if (opp.CloseDate != null && opp.CloseDate.year() == System.today().year() && opp.StageName == 'Closed Won') {
                    totalClosedValue += opp.Amount;
                    closedOpportunities++;
                }
            }
            
            // Calculate the rating
            Double rating = totalClosedValue + (openOpportunities * 100) - (closedOpportunities * 50);
            
            // Update the account with a new rating value (assuming 'Rating__c' is a custom field on Account)
            acc.Rating__c = rating;
            accountsToUpdate.add(acc);
        }
        
        // Update the accounts
        update accountsToUpdate;
        
        // Optionally, you can implement a sorting function to get accounts in rank order based on rating
    }
}