/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-05-2024
 * @last modified by  : jamesperram@gmail.com
**/
public class PublishPlatformEvent {
    @InvocableMethod
    public static void publishEvent(List<OpportunityEventDetails> detailsList) {
        List<Order_Notification__e> eventsToPublish = new List<Order_Notification__e>();

        for (OpportunityEventDetails details : detailsList) {
            // Simulate failure if StageName is null
            if (String.isBlank(details.stageName)) {
                System.debug('Simulating failure due to missing StageName.');
                throw new CustomException('Simulated failure: StageName cannot be null.');
            }

            eventsToPublish.add(new Order_Notification__e(
                OpportunityId__c = details.opportunityId,
                StageName__c = details.stageName
            ));
        }

        // Publish events
        EventBus.publish(eventsToPublish);
    }

    public class OpportunityEventDetails {
        @InvocableVariable
        public String opportunityId;

        @InvocableVariable
        public String stageName;
    }

    // Custom Exception for simulation
    public class CustomException extends Exception {}
}