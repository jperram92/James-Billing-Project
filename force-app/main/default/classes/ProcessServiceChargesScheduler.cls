/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-01-2024
 * @last modified by  : jamesperram@gmail.com
**/
global class ProcessServiceChargesScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        if (JobController.isJobEnabled()) {
            // Query service records and their related service schedule records
            List<JBP_Service_Schedule__c> serviceSchedules = [
                SELECT Id, JBP_Service__c 
                FROM JBP_Service_Schedule__c 
                WHERE JBP_Service__r.JBP_Service_Status__c = 'Completed'
            ];

            List<Id> serviceScheduleIds = new List<Id>();
            for (JBP_Service_Schedule__c schedule : serviceSchedules) {
                serviceScheduleIds.add(schedule.Id);
            }

            if (!serviceScheduleIds.isEmpty()) {
                // Pass the list of IDs to the batch class
                ProcessServiceChargesBatch job = new ProcessServiceChargesBatch(serviceScheduleIds);
                Database.executeBatch(job, 50);
            } else {
                System.debug('No completed service schedules to process.');
            }
        } else {
            System.debug('Job is disabled.');
        }
    }
}