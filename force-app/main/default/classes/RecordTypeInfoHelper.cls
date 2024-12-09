/**
 * This class is designed to fetch metadata about a specific record type
 * for the Contact object. 
 * 
 * Practical Story:
 * -----------------
 * Imagine a scenario where your organization uses the Contact object
 * to differentiate between various types of contacts like Partner Contacts,
 * Vendor Contacts, and Customer Contacts. A Salesforce Admin needs a tool 
 * to verify if the correct record type is applied to records or to automate
 * metadata retrieval for dynamic user interfaces.
 *
 * This class provides a method to fetch details about a specific record type 
 * by DeveloperName and can be extended for further metadata exploration.
 */
public with sharing class RecordTypeInfoHelper {
    
    /**
     * Fetches RecordType metadata for a given SObjectType and DeveloperName.
     * 
     * @param sObjectType The API name of the object (e.g., 'Contact').
     * @param developerName The DeveloperName of the desired record type.
     * @return Schema.RecordTypeInfo metadata object for the specified record type.
     */
    public static Schema.RecordTypeInfo getRecordTypeInfo(String sObjectType, String developerName) {
        // Get DescribeSObjectResult for the provided object
        Schema.DescribeSObjectResult result = Schema.getGlobalDescribe().get(sObjectType).getDescribe();

        // Fetch the map of RecordTypeInfo by Id
        Map<Id, Schema.RecordTypeInfo> mapRecTypes = result.getRecordTypeInfosById();
        
        // Query the RecordType Id for the given DeveloperName
        Id recordTypeId = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = :sObjectType AND DeveloperName = :developerName
            LIMIT 1
        ].Id;
        
        // Return the RecordTypeInfo object
        return mapRecTypes.get(recordTypeId);
    }
    
    /**
     * A utility method to display metadata details in logs for debugging.
     */
    public static void logRecordTypeInfo(String sObjectType, String developerName) {
        Schema.RecordTypeInfo recordTypeInfo = getRecordTypeInfo(sObjectType, developerName);
        
        if (recordTypeInfo != null) {
            System.debug('RecordType Info:');
            System.debug(' - Label: ' + recordTypeInfo.getName());
            System.debug(' - DeveloperName: ' + recordTypeInfo.getDeveloperName());
            System.debug(' - Is Active: ' + recordTypeInfo.isActive());
        } else {
            System.debug('No RecordType found for DeveloperName: ' + developerName);
        }
    }
}

// Practical Use Case:
// A Salesforce Admin wants to verify metadata about the 'PartnerContact' RecordType for Contacts.
// This script fetches and logs the RecordType metadata to assist in debugging or configuration validation.

//String sObjectType = 'Contact';
//String developerName = 'PartnerContact';

// Log RecordType metadata details for 'PartnerContact'
//RecordTypeInfoHelper.logRecordTypeInfo(sObjectType, developerName);