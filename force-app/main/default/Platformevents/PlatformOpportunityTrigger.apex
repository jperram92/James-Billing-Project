/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-05-2024
 * @last modified by  : jamesperram@gmail.com
**/
trigger PlatformOpportunityTrigger on Opportunity (after update) {
    for (Opportunity opp : Trigger.new) {
        // Publish event only when the stage changes to "Closed Won"
        if (opp.StageName == 'Closed Won' && Trigger.oldMap.get(opp.Id).StageName != 'Closed Won') {
            Order_Notification__e orderEvent = new Order_Notification__e(
                OpportunityId__c = opp.Id,
                CustomerName__c = opp.Account.Name,
                OrderDetails__c = 'Order for ' + opp.Name
            );
            EventBus.publish(orderEvent);
        }
    }
}
