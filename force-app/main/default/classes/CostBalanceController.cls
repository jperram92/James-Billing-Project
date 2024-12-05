/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-04-2024
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class CostBalanceController {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getOpportunityProductBalances(Id opportunityId) {
        List<OpportunityLineItem> opportunityProducts = [
            SELECT Id, UnitPrice, Quantity, JBP_Quantity_Consumed__c, Product2.Name
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
        ];

        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for (OpportunityLineItem product : opportunityProducts) {
            Decimal salesPrice = product.UnitPrice != null ? product.UnitPrice : 0;
            Decimal allocatedQty = product.Quantity != null ? product.Quantity : 0;
            Decimal consumedQty = product.JBP_Quantity_Consumed__c != null ? product.JBP_Quantity_Consumed__c : 0;

            Decimal totalAllocated = salesPrice * allocatedQty;
            Decimal totalSpent = salesPrice * consumedQty;
            Decimal balance = totalAllocated - totalSpent;

            result.add(new Map<String, Object>{
                'productName' => product.Product2.Name,
                'unitPrice' => salesPrice,
                'allocatedQty' => allocatedQty,
                'consumedQty' => consumedQty,
                'totalAllocated' => totalAllocated,
                'totalSpent' => totalSpent,
                'balance' => balance
            });
        }

        return result;
    }
}
