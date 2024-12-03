/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 12-03-2024
 * @last modified by  : jamesperram@gmail.com
**/
public class ProductPricebookSetup {

    public static void generateRandomProductsAndEntries() {
        // Step 1: Create a new custom Pricebook
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Custom Random Pricebook',
            IsActive = true
        );
        insert customPricebook;
        System.debug('Created Pricebook: ' + customPricebook.Id);

        // Step 2: Generate 50 random Products
        List<Product2> productList = new List<Product2>();
        for (Integer i = 1; i <= 50; i++) {
            Product2 prod = new Product2(
                Name = 'Product ' + i,
                ProductCode = 'PROD_' + i,
                Description = 'This is Product ' + i,
                IsActive = true,
                Family = 'Random'
            );
            productList.add(prod);
        }
        insert productList;
        System.debug('Inserted ' + productList.size() + ' Products.');

        // Step 3: Create Standard Pricebook Entries
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        List<PricebookEntry> standardEntries = new List<PricebookEntry>();

        for (Product2 prod : productList) {
            PricebookEntry entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = prod.Id,
                UnitPrice = Math.random() * 100 + 1, // Random price between 1 and 100
                IsActive = true
            );
            standardEntries.add(entry);
        }
        insert standardEntries;
        System.debug('Created ' + standardEntries.size() + ' Standard Pricebook Entries.');

        // Step 4: Create Custom Pricebook Entries for the new Pricebook
        List<PricebookEntry> customEntries = new List<PricebookEntry>();

        for (Product2 prod : productList) {
            PricebookEntry entry = new PricebookEntry(
                Pricebook2Id = customPricebook.Id,
                Product2Id = prod.Id,
                UnitPrice = Math.random() * 100 + 1, // Random price between 1 and 100
                IsActive = true
            );
            customEntries.add(entry);
        }
        insert customEntries;
        System.debug('Created ' + customEntries.size() + ' Custom Pricebook Entries for Pricebook: ' + customPricebook.Name);
    }
}

// Execute Anonymous
//ProductPricebookSetup.generateRandomProductsAndEntries();