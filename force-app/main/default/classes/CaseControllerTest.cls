/**
 * @description       : Test class for CaseController
 * @author            : jamesperram@gmail.com
 * @last modified on  : 12-05-2024
 * @last modified by  : jamesperram@gmail.com
 **/
@isTest
public class CaseControllerTest {
    @isTest
    static void testCaseController() {
        // Step 1: Create Test Data
        Contact testContact = new Contact(
            FirstName = 'John', 
            LastName = 'Doe', 
            Email = 'john.doe@example.com', 
            Phone = '1234567890'
        );
        insert testContact;

        Case testCase = new Case(
            ContactId = testContact.Id,
            Subject = 'Test Case',
            Status = 'Open'
        );
        insert testCase;

        // Step 2: Initialize the CaseController
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        CaseController caseController = new CaseController(stdController);

        // Validate that the Case is initialized correctly
        System.assertEquals(testCase.Id, caseController.caseRecord.Id, 'Case record ID should match the test Case ID');

        // Step 3: Test fetchContactInfo Method
        caseController.fetchContactInfo();

        // Validate that the Contact information is fetched correctly
        System.assertEquals(testContact.Id, caseController.selectedContact.Id, 'Selected Contact ID should match the test Contact ID');

        // Validate the count of open cases
        System.assertEquals('1', caseController.openCases, 'Open Cases count should be 1');

        // Step 4: Test reset Method
        caseController.reset();

        // Validate that the fields are cleared
        System.assertEquals(null, caseController.caseRecord.Subject, 'Case record subject should be reset to null');
        System.assertEquals(null, caseController.selectedContact, 'Selected Contact should be cleared');
        System.assertEquals(null, caseController.openCases, 'Open Cases count should be cleared');
    }

    @isTest
    static void testFetchContactInfoWithNullContact() {
        // Step 1: Create a Case without ContactId
        Case testCase = new Case(
            Subject = 'Test Case Without Contact',
            Status = 'Open'
        );
        insert testCase;

        // Step 2: Initialize the CaseController
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        CaseController caseController = new CaseController(stdController);

        // Step 3: Test fetchContactInfo Method
        caseController.fetchContactInfo();

        // Validate that no Contact or Open Cases are fetched
        System.assertEquals(null, caseController.selectedContact, 'Selected Contact should be null for Case without ContactId');
        System.assertEquals(null, caseController.openCases, 'Open Cases count should be null for Case without ContactId');
    }

    @isTest
    static void testResetMethod() {
        // Step 1: Create a Case with a ContactId
        Contact testContact = new Contact(
            FirstName = 'Jane', 
            LastName = 'Doe', 
            Email = 'jane.doe@example.com', 
            Phone = '9876543210'
        );
        insert testContact;

        Case testCase = new Case(
            ContactId = testContact.Id,
            Subject = 'Test Case to Reset',
            Status = 'New'
        );
        insert testCase;

        // Step 2: Initialize the CaseController
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        CaseController caseController = new CaseController(stdController);

        // Step 3: Reset the Controller
        caseController.reset();

        // Validate that fields are cleared
        System.assertEquals(null, caseController.caseRecord.Subject, 'Case record subject should be null after reset');
        System.assertEquals(null, caseController.selectedContact, 'Selected Contact should be cleared after reset');
        System.assertEquals(null, caseController.openCases, 'Open Cases count should be cleared after reset');
    }
}
