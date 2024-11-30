/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-01-2024
 * @last modified by  : jamesperram@gmail.com
**/
trigger JBPServiceTrigger on JBP_Service__c (after update) {
    List<Id> serviceIds = new List<Id>();

    //This loop checks if the status of a JBP_Service__c record has changed to "Completed" in the current trigger context 
    //and adds its ID to a collection for further processing.
    for (JBP_Service__c service : Trigger.new) {
        if (service.JBP_Service_Status__c == 'Completed' && 
            Trigger.oldMap.get(service.Id).JBP_Service_Status__c != 'Completed') {
            serviceIds.add(service.Id);
        }
    }

    //This code block checks if there are any service IDs collected
    //and if so, it initializes a batch job (ProcessServiceChargesBatch) 
    //with those IDs and executes it in batches of 50 records.
    if (!serviceIds.isEmpty()) {
        ProcessServiceChargesBatch job = new ProcessServiceChargesBatch(serviceIds);
        Database.executeBatch(job, 50);
    }
}
