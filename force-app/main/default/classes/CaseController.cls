/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-19-2024
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class CaseController {
    public Contact selectedContact { get; set; }
    public String openCases { get; set; }
    public Case caseRecord { get; set; }  // Exposing Case to Visualforce page

    // Constructor to initialize Case record from Standard Controller
    public CaseController(ApexPages.StandardController controller) {
        this.caseRecord = (Case)controller.getRecord();  // Get the Case record passed by the controller
    }

    // Fetch Contact Information and Open Cases
    public void fetchContactInfo() {
        if (caseRecord.ContactId != null) {
            // Fetch the Contact Information using the ContactId from the Case
            selectedContact = [SELECT Name, Email, Phone FROM Contact WHERE Id = :caseRecord.ContactId LIMIT 1];
            
            // Fetch the number of open cases for the contact
            openCases = String.valueOf([SELECT COUNT() FROM Case WHERE ContactId = :caseRecord.ContactId AND Status != 'Closed']);
        }
    }

    // Reset method to clear form fields
    public void reset() {
        // Resetting the form and clearing fields
        this.caseRecord = new Case();  // Reset Case record
        selectedContact = null;         // Clear selected contact information
        openCases = null;               // Clear open cases count
    }
}