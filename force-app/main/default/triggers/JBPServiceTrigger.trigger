/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-01-2024
 * @last modified by  : jamesperram@gmail.com
**/
trigger JBPServiceTrigger on JBP_Service__c (after update) {
    List<Id> serviceIds = new List<Id>();

    for (JBP_Service__c service : Trigger.new) {
        if (service.JBP_Service_Status__c == 'Completed' && 
            Trigger.oldMap.get(service.Id).JBP_Service_Status__c != 'Completed') {
            serviceIds.add(service.Id);
        }
    }

    if (!serviceIds.isEmpty()) {
        ProcessServiceChargesBatch job = new ProcessServiceChargesBatch(serviceIds);
        Database.executeBatch(job, 50);
    }
}
