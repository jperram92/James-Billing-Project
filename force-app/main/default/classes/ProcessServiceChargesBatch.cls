/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-01-2024
 * @last modified by  : jamesperram@gmail.com
**/
global class ProcessServiceChargesBatch implements Database.Batchable<SObject>, Database.Stateful {
    private List<Id> serviceIds;

    global ProcessServiceChargesBatch(List<Id> serviceIds) {
        this.serviceIds = serviceIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id,
                   Name,
                   (SELECT Id, 
                           JBP_Service_Date__c, 
                           Opportunity_Product__r.Product2.Name, 
                           Opportunity_Product__r.Opportunity.Pre_Check_Form__r.Contact__r.Name, 
                           JBP_Service_Quantity_Allocated__c, 
                           Opportunity_Product__r.JBP_Service_Offering_Start_Time__c, 
                           Opportunity_Product__r.JBP_Service_Offering_End_Time__c
                    FROM Service_Schedule__r) // Pulling the associated records from the Service Schedule which owns the downstream billing
            FROM JBP_Service__c
            WHERE Id IN :serviceIds //Use this for finding the Service ID"s linked to the service schedules for the batch
        ]);
    }

    //Mapping used to own how the service charges are generated.
    global void execute(Database.BatchableContext BC, List<JBP_Service__c> services) {
        List<JBP_Service_Charge__c> chargesToInsert = new List<JBP_Service_Charge__c>();
        Map<Id, String> serviceCommentsMap = new Map<Id, String>();
        Map<Id, String> serviceStatusMap = new Map<Id, String>();

        //This loop iterates through each JBP_Service__c record in the batch, initializing a blank comments string for tracking any 
        //issues or observations for the service and a createdRecord flag to determine if a charge record is 
        //successfully created for the service.
        for (JBP_Service__c service : services) {
            String comments = ''; // Replacing StringBuilder with a plain String
            Boolean createdRecord = false;

            if (service.Service_Schedule__r != null && !service.Service_Schedule__r.isEmpty()) {
                for (JBP_Service_Schedule__c schedule : service.Service_Schedule__r) {
                    if (isValidSchedule(schedule)) {
                        JBP_Service_Charge__c charge = new JBP_Service_Charge__c();
                        charge.Name = schedule.JBP_Service_Date__c.format() + ' - ' + 
                                      schedule.Opportunity_Product__r.Product2.Name + ' - ' + 
                                      schedule.Opportunity_Product__r.Opportunity.Pre_Check_Form__r.Contact__r.Name;
                        charge.Service_Schedule__c = schedule.Id;
                        charge.JBP_Charge_Originated_From__c = 'Service Schedule';
                        charge.JBP_Quantity_To_Charge__c = schedule.JBP_Service_Quantity_Allocated__c;
                        charge.Contact__c = schedule.Opportunity_Product__r.Opportunity.Pre_Check_Form__r.Contact__r.Id;
                        charge.Product__c = schedule.Opportunity_Product__r.Product2.Id;

                        chargesToInsert.add(charge);

                        // Append details to comments
                        comments += 'Created Service Charge: ' + charge.Name +
                                    ' | ID: ' + charge.Service_Schedule__c + '\n';
                        createdRecord = true;
                    }
                }
            }

            // Update service status and comments based on creation
            if (createdRecord) {
                serviceStatusMap.put(service.Id, 'Completed');
            } else {
                serviceStatusMap.put(service.Id, 'Failed');
            }
            serviceCommentsMap.put(service.Id, String.isEmpty(comments) ? 'No valid schedules found.' : comments);
        }

        // Insert charges if there are any
        if (!chargesToInsert.isEmpty()) {
            insert chargesToInsert;
        }

        // Update the services with the new status and comments
        List<JBP_Service__c> servicesToUpdate = new List<JBP_Service__c>();
        for (JBP_Service__c service : services) {
            if (serviceStatusMap.containsKey(service.Id)) {
                service.JBP_Billing_Status__c = serviceStatusMap.get(service.Id);
            }
            if (serviceCommentsMap.containsKey(service.Id)) {
                service.JBP_Billing_Comments__c = serviceCommentsMap.get(service.Id);
            }
            servicesToUpdate.add(service);
        }

        if (!servicesToUpdate.isEmpty()) {
            update servicesToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Job Completed.');
    }

    private Boolean isValidSchedule(JBP_Service_Schedule__c schedule) {
        // Validation Logic
        if (schedule.JBP_Service_Quantity_Allocated__c <= 0) {
            return false;
        }
        Date serviceDate = schedule.JBP_Service_Date__c;
        Date oppStartDate = schedule.Opportunity_Product__r.JBP_Service_Offering_Start_Time__c;
        Date oppEndDate = schedule.Opportunity_Product__r.JBP_Service_Offering_End_Time__c;

        return (serviceDate >= oppStartDate && serviceDate <= oppEndDate);
    }
}
