/**
 * @description       : Fetch Opportunity details, products, and create Opportunity products
 * @group             : 
 * @last modified on  : 12-04-2024
 * @last modified by  : jamesperram@gmail.com
 **/
public with sharing class OpportunityProductController {
    
    @AuraEnabled
    public static Opportunity getOpportunityDetails(Id opportunityId) {
        try {
            // Validate input
            if (String.isBlank(opportunityId)) {
                throw new AuraHandledException('Invalid Opportunity ID.');
            }

            // Fetch Opportunity details, including the related Account and linked Pre_Check_Form__c
            Opportunity opp = [
                SELECT Id, 
                       Name, 
                       Account.Name, 
                       Pre_Check_Form__r.Contact__c, 
                       Pre_Check_Form__r.Contact__r.Name
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1
            ];
            
            if (opp == null) {
                throw new AuraHandledException('No Opportunity found for the given ID.');
            }

            System.debug('Fetched Opportunity Details: ' + opp);
            return opp;
        } catch (AuraHandledException e) {
            throw e; // Rethrow known errors
        } catch (Exception e) {
            System.debug('Error fetching Opportunity details: ' + e.getMessage());
            throw new AuraHandledException('Error fetching Opportunity details: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<PricebookEntry> getAvailableProducts(Id opportunityId) {
        try {
            // Validate input
            if (String.isBlank(opportunityId)) {
                throw new AuraHandledException('Invalid Opportunity ID.');
            }

            // Fetch the Pricebook assigned to the Opportunity
            Opportunity opp = [
                SELECT Pricebook2Id 
                FROM Opportunity 
                WHERE Id = :opportunityId 
                LIMIT 1
            ];
            
            if (opp == null) {
                throw new AuraHandledException('No Opportunity found for the given ID.');
            }

            if (opp.Pricebook2Id == null) {
                throw new AuraHandledException('No Pricebook assigned to this Opportunity.');
            }

            // Fetch active products from the Opportunity's Pricebook
            List<PricebookEntry> products = [
                SELECT Id, Product2Id, Product2.Name, Product2.ProductCode, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id = :opp.Pricebook2Id AND IsActive = TRUE
            ];

            if (products.isEmpty()) {
                throw new AuraHandledException('No products available in the selected Pricebook.');
            }

            System.debug('Fetched Products from Pricebook: ' + products);
            return products;
        } catch (AuraHandledException e) {
            throw e; // Rethrow known errors
        } catch (Exception e) {
            System.debug('Error fetching Products: ' + e.getMessage());
            throw new AuraHandledException('Error fetching Products: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Pricebook2> getPricebooks() {
        try {
            // Fetch all active Pricebooks
            List<Pricebook2> pricebooks = [SELECT Id, Name FROM Pricebook2 WHERE IsActive = TRUE];
            
            if (pricebooks.isEmpty()) {
                throw new AuraHandledException('No active Pricebooks found.');
            }

            System.debug('Fetched Active Pricebooks: ' + pricebooks);
            return pricebooks;
        } catch (AuraHandledException e) {
            throw e; // Rethrow known errors
        } catch (Exception e) {
            System.debug('Error fetching Pricebooks: ' + e.getMessage());
            throw new AuraHandledException('Error fetching Pricebooks: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void createOpportunityProducts(List<OpportunityLineItem> opportunityProducts) {
        try {
            // Validate input
            if (opportunityProducts == null || opportunityProducts.isEmpty()) {
                throw new AuraHandledException('No products selected for creation.');
            }

            System.debug('Creating Opportunity Products: ' + opportunityProducts);

            // Insert new Opportunity Products
            insert opportunityProducts;

            System.debug('Opportunity Products created successfully.');
        } catch (DmlException e) {
            System.debug('Error in createOpportunityProducts: ' + e.getMessage());
            throw new AuraHandledException('Error creating Opportunity Products: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            System.debug('Error in createOpportunityProducts: ' + e.getMessage());
            throw new AuraHandledException('Error creating Opportunity Products: ' + e.getMessage());
        }
    }
}
