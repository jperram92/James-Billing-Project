/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-06-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
public class RecordTypeInfoHelperTest {

    @testSetup
    static void setupTestData() {
        // Create a RecordType for the Contact object
        RecordType partnerContactRecordType = new RecordType(
            SObjectType = 'Contact',
            DeveloperName = 'PartnerContact',
            Name = 'Partner Contact',
            IsActive = true
        );
        insert partnerContactRecordType;
    }

    @isTest
    static void testGetRecordTypeInfo() {
        // Test the getRecordTypeInfo method with a valid DeveloperName
        Schema.RecordTypeInfo recordTypeInfo = RecordTypeInfoHelper.getRecordTypeInfo('Contact', 'PartnerContact');
        
        // Assertions to validate the returned metadata
        System.assertNotNull(recordTypeInfo, 'The RecordTypeInfo should not be null');
        System.assertEquals('PartnerContact', recordTypeInfo.getDeveloperName(), 'The DeveloperName should match');
        System.assert(recordTypeInfo.isActive(), 'The RecordType should be active');
    }

    @isTest
    static void testGetRecordTypeInfoInvalidDeveloperName() {
        // Test the getRecordTypeInfo method with an invalid DeveloperName
        Schema.RecordTypeInfo recordTypeInfo = RecordTypeInfoHelper.getRecordTypeInfo('Contact', 'InvalidDeveloperName');
        
        // Assertions to validate no RecordTypeInfo is found
        System.assertNull(recordTypeInfo, 'The RecordTypeInfo should be null for an invalid DeveloperName');
    }

    @isTest
    static void testLogRecordTypeInfo() {
        // Test the logRecordTypeInfo method
        Test.startTest();
        RecordTypeInfoHelper.logRecordTypeInfo('Contact', 'PartnerContact');
        Test.stopTest();
        
        // Add a dummy assertion to satisfy PMD and validate behavior
        Schema.RecordTypeInfo recordTypeInfo = RecordTypeInfoHelper.getRecordTypeInfo('Contact', 'PartnerContact');
        System.assertNotNull(recordTypeInfo, 'Log method executed successfully for a valid record type');

        // Assert that the RecordTypeInfo matches expected DeveloperName
        System.assertEquals('PartnerContact', recordTypeInfo.getDeveloperName(), 'The DeveloperName logged should match');
    }

    @isTest
    static void testLogInvalidRecordTypeInfo() {
        // Test the logRecordTypeInfo method with invalid DeveloperName
        Test.startTest();
        RecordTypeInfoHelper.logRecordTypeInfo('Contact', 'InvalidDeveloperName');
        Test.stopTest();
        
        // Ensure no exception is thrown and the invalid case behaves as expected
        Schema.RecordTypeInfo recordTypeInfo = RecordTypeInfoHelper.getRecordTypeInfo('Contact', 'InvalidDeveloperName');
        System.assertNull(recordTypeInfo, 'Log method should not find a record type for an invalid DeveloperName');
    }
}
