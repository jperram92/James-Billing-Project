/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-01-2024
 * @last modified by  : jamesperram@gmail.com
**/
trigger JBPServiceErrorHandlingTrigger on JBP_Service__c (after update) {
    if (Trigger.isUpdate) {
        List<Task> tasksToInsert = new List<Task>();
        List<JBP_Service__c> servicesToUpdate = new List<JBP_Service__c>();
        
        for (JBP_Service__c service : Trigger.new) {
            JBP_Service__c oldService = Trigger.oldMap.get(service.Id);
            
            // Check if the service status changed to "Completed"
            if (service.JBP_Service_Status__c == 'Completed' && oldService.JBP_Service_Status__c != 'Completed') {
                // Perform validation
                String errorMessage = JBPServiceHelper.validateService(service);
                if (errorMessage != null) {
                    // Clone the record to make updates
                    JBP_Service__c serviceToUpdate = service.clone(false, true, false);
                    serviceToUpdate.Id = service.Id; // Set the Id to ensure proper update
                    serviceToUpdate.JBP_Billing_Status__c = 'Failed';
                    serviceToUpdate.JBP_Billing_Comments__c = errorMessage;
                    serviceToUpdate.JBP_Service_Status__c = 'Completed - No Charge Error'; // Set the new picklist value

                    servicesToUpdate.add(serviceToUpdate);

                    // Create a task for the owner
                    Task task = new Task(
                        OwnerId = service.OwnerId,
                        Subject = 'Billing Issue Detected',
                        Status = 'Not Started',
                        Priority = 'High',
                        WhatId = service.Id,
                        Description = errorMessage
                    );
                    tasksToInsert.add(task);
                }
            }
        }

        // Perform DML operations
        if (!servicesToUpdate.isEmpty()) {
            update servicesToUpdate; // Update cloned records
        }
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert; // Insert tasks
        }
    }
}
