/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-09-2024
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

        return [SELECT Id, Name, JBP_Service_Start_Time__c, JBP_Service_Status__c, JBP_Service_End_Time__c, JBP_Service_Date__c
                FROM JBP_Service__c
                WHERE JBP_Service_Date__c = :serviceDate];
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
}
