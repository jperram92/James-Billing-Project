/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-04-2024
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class OpportunityServiceAdjusterController {
    
    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> fetchOpportunityProducts(Id opportunityId) {
        try {
            if (String.isBlank(opportunityId)) {
                throw new AuraHandledException('Opportunity ID cannot be blank.');
            }

            // Query the Opportunity Products (or any other related data)
            return [
                SELECT Id, OpportunityId, Product2Id, Product2.Name, Quantity, UnitPrice, TotalPrice, 
                       JBP_Service_Offering_Start_Time__c, JBP_Service_Offering_End_Time__c
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching Opportunity Products: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static OpportunityLineItem updateOpportunityProduct(OpportunityLineItem updatedProduct) {
        try {
            if (updatedProduct == null || String.isBlank(updatedProduct.Id)) {
                throw new AuraHandledException('Invalid Opportunity Product data.');
            }

            update updatedProduct;
            return [
                SELECT Id, OpportunityId, Product2.Name, Quantity, UnitPrice, TotalPrice
                FROM OpportunityLineItem
                WHERE Id = :updatedProduct.Id
            ];
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating Opportunity Product: ' + e.getMessage());
        }
    }
}
