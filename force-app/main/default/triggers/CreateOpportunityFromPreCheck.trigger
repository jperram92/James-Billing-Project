/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-04-2024
 * @last modified by  : jamesperram@gmail.com
**/
trigger CreateOpportunityFromPreCheck on JPB_Pre_Check_Form__c (after update) {
    List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
    List<OpportunityLineItem> lineItemsToInsert = new List<OpportunityLineItem>();
    Map<Id, PricebookEntry> pricebookEntryMap = new Map<Id, PricebookEntry>();
    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
    List<ContentVersion> attachmentsToInsert = new List<ContentVersion>();
    
    // Debugging trigger entry
    System.debug('Trigger Execution Started');
    
    // Fetch all Pricebook Entries for referenced Price Book
    Set<Id> productIds = new Set<Id>();
    for (JPB_Pre_Check_Form__c preCheck : Trigger.new) {
        if (preCheck.JBP_Status__c == 'Approved') {
            productIds.add(preCheck.Product__c);
        }
    }
    
    System.debug('Product IDs: ' + productIds);
    
    if (!productIds.isEmpty()) {
        List<PricebookEntry> pricebookEntries = [
            SELECT Id, Product2Id, Pricebook2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :productIds
        ];
        for (PricebookEntry pbe : pricebookEntries) {
            pricebookEntryMap.put(pbe.Product2Id, pbe);
        }
    }
    
    System.debug('PricebookEntry Map: ' + pricebookEntryMap);

    // Create Opportunities
    for (JPB_Pre_Check_Form__c preCheck : Trigger.new) {
        if (preCheck.JBP_Status__c == 'Approved') {
            Opportunity opp = new Opportunity();
            opp.Name = preCheck.Name;
            opp.StageName = 'Prospecting';
            opp.CloseDate = Date.today().addDays(30);
            opp.Pre_Check_Form__c = preCheck.Id; // Link Pre-Check Form
            opportunitiesToInsert.add(opp);
        }
    }

    if (!opportunitiesToInsert.isEmpty()) {
        insert opportunitiesToInsert;
        System.debug('Opportunities Inserted: ' + opportunitiesToInsert);
    } else {
        System.debug('No Opportunities to Insert');
    }

    // Prepare Opportunity Line Items
    for (Opportunity opp : opportunitiesToInsert) {
        JPB_Pre_Check_Form__c relatedForm = Trigger.newMap.get(opp.Pre_Check_Form__c);
        opportunityMap.put(opp.Id, opp);
        if (relatedForm != null && pricebookEntryMap.containsKey(relatedForm.Product__c)) {
            PricebookEntry pbe = pricebookEntryMap.get(relatedForm.Product__c);
            OpportunityLineItem lineItem = new OpportunityLineItem();
            lineItem.OpportunityId = opp.Id;
            lineItem.PricebookEntryId = pbe.Id;
            lineItem.Quantity = relatedForm.JBP_Charge_Units__c;
            lineItem.TotalPrice = relatedForm.JBP_Total_Charge_c__c;
            lineItemsToInsert.add(lineItem);
        } else {
            System.debug('No Matching Pricebook Entry for Product: ' + relatedForm.Product__c);
        }
    }

    if (!lineItemsToInsert.isEmpty()) {
        insert lineItemsToInsert;
        System.debug('Opportunity Line Items Inserted: ' + lineItemsToInsert);
    } else {
        System.debug('No Opportunity Line Items to Insert');
    }

    // Create JSON backup and save as an attachment
    for (Opportunity opp : opportunitiesToInsert) {
        Map<String, Object> backupData = new Map<String, Object>();
        backupData.put('PreCheckForm', Trigger.newMap.get(opp.Pre_Check_Form__c));
        backupData.put('Opportunity', opp);
        backupData.put('OpportunityLineItems', lineItemsToInsert);

        String jsonBackup = JSON.serialize(backupData);

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = opp.Name + '_Backup';
        contentVersion.PathOnClient = opp.Name + '_Backup.json';
        contentVersion.VersionData = Blob.valueOf(jsonBackup);
        contentVersion.FirstPublishLocationId = opp.Id; // Attach to the Opportunity
        attachmentsToInsert.add(contentVersion);
    }

    if (!attachmentsToInsert.isEmpty()) {
        insert attachmentsToInsert;
        System.debug('Attachments Created: ' + attachmentsToInsert);
    } else {
        System.debug('No Attachments to Insert');
    }
}