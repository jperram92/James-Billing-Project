/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-10-2024
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class SchedulingController {

    @AuraEnabled
    public static void addService(JBP_Service__c newService) {
        if (newService == null) {
            throw new AuraHandledException('Service details cannot be null.');
        }
        if (newService.JBP_Service_Start_Time__c >= newService.JBP_Service_End_Time__c) {
            throw new AuraHandledException('Start Time must be earlier than End Time.');
        }
        try {
            insert newService;
        } catch (DmlException e) {
            throw new AuraHandledException('Failed to add service: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<JBP_Service__c> getServicesByDate(Date serviceDate) {
        if (serviceDate == null) {
            throw new AuraHandledException('Service date cannot be null.');
        }

        return [
            SELECT Id, Name, JBP_Service_Start_Time__c, JBP_Service_Status__c, JBP_Service_End_Time__c, JBP_Service_Date__c
            FROM JBP_Service__c
            WHERE JBP_Service_Date__c = :serviceDate
        ];
    }

    @AuraEnabled
    public static void updateServices(List<JBP_Service__c> services) {
        if (services == null || services.isEmpty()) {
            throw new AuraHandledException('No services provided for update.');
        }

        try {
            update services;
        } catch (DmlException e) {
            throw new AuraHandledException('Failed to update services: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteServices(List<Id> serviceIds) {
        if (serviceIds == null || serviceIds.isEmpty()) {
            throw new AuraHandledException('No services to delete.');
        }

        try {
            delete [SELECT Id FROM JBP_Service__c WHERE Id IN :serviceIds];
        } catch (DmlException e) {
            throw new AuraHandledException('Failed to delete services: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityProducts(Id serviceId) {
        if (serviceId == null) {
            throw new AuraHandledException('Service ID cannot be null.');
        }

        try {
            return [
                SELECT Id, Name, Quantity, UnitPrice, OpportunityId, Product2Id, Product2.Name
                FROM OpportunityLineItem
                WHERE OpportunityId IN (
                    SELECT Opportunity__c
                    FROM JBP_Service_Schedule__c
                    WHERE JBP_Service__c = :serviceId
                )
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Failed to fetch Opportunity Products: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void addServiceSchedule(Map<String, Object> scheduleData) {
        if (scheduleData == null || scheduleData.isEmpty()) {
            throw new AuraHandledException('Schedule data cannot be null.');
        }

        String scheduleName = (String) scheduleData.get('scheduleName');
        Date scheduleDate = (Date) scheduleData.get('scheduleDate');
        Time scheduleStartTime = (Time) scheduleData.get('scheduleStartTime');
        Time scheduleEndTime = (Time) scheduleData.get('scheduleEndTime');
        String opportunityProductId = (String) scheduleData.get('opportunityProduct');
        String serviceType = (String) scheduleData.get('serviceType');

        if (String.isBlank(scheduleName) || scheduleDate == null || scheduleStartTime == null || scheduleEndTime == null) {
            throw new AuraHandledException('All required fields must be populated.');
        }
        if (scheduleStartTime >= scheduleEndTime) {
            throw new AuraHandledException('Start Time must be earlier than End Time.');
        }

        try {
            // Create the new Service Schedule record
            JBP_Service_Schedule__c newSchedule = new JBP_Service_Schedule__c(
                Name = scheduleName,
                JBP_Service_Date__c = scheduleDate,
                JBP_Service_Start_Time__c = scheduleStartTime,
                JBP_Service_End_Time__c = scheduleEndTime,
                Opportunity_Product__c = opportunityProductId,
                JBP_Service_Type__c = serviceType
            );

            insert newSchedule;
        } catch (DmlException e) {
            throw new AuraHandledException('Failed to add service schedule: ' + e.getMessage());
        }
    }
}
