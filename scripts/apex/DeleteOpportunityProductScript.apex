/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-04-2024
 * @last modified by  : jamesperram@gmail.com
**/
// Replace this with the Opportunity Id you want to target
Id OpportunityId = '006NS00000PCUwnYAH'; 

try {
    // Query all Opportunity Products (OpportunityLineItem) associated with the Opportunity
    List<OpportunityLineItem> oppLineItems = [
        SELECT Id 
        FROM OpportunityLineItem 
        WHERE OpportunityId = :OpportunityId
    ];
    
    // Check if there are any Opportunity Products to delete
    if (!oppLineItems.isEmpty()) {
        // Delete all associated OpportunityLineItems
        delete oppLineItems;
        System.debug('Successfully deleted all Opportunity Products associated with the Opportunity.');
    } else {
        System.debug('No Opportunity Products found for the specified Opportunity.');
    }
} catch (Exception e) {
    System.debug('Error occurred: ' + e.getMessage());
}
