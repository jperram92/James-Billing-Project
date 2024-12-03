from simple_salesforce import Salesforce
import json

# Step 1: Authenticate with Salesforce
sf = Salesforce(username='jamesperramdeveloper@gmail.com',
                password='Hrcv2rje4!!!',
                security_token='4rhCkYPCGrgNRiWPIb1hOc6hT')

# Step 2: Load JSON files
def load_json(file_path):
    with open(file_path, 'r') as file:
        return json.load(file)

products = load_json('Product.json')
pricebooks = load_json('Pricebook.json')
pbe_entries = load_json('PriceBookEntries.json')

# Step 3: Standard Pricebook ID
standard_pricebook_id = "01sNS000002S2fGYAS"  # Existing Standard Pricebook ID

# Step 4: Check Existing Products
existing_products = sf.query("SELECT Id, ProductCode FROM Product2")['records']
existing_product_map = {p['ProductCode']: p['Id'] for p in existing_products}

# Step 5: Insert Products (Bulkified)
new_products = [
    product for product in products if product["ProductCode"] not in existing_product_map
]

if new_products:
    results = sf.bulk.Product2.insert(new_products)
    for result, product in zip(results, new_products):
        if result['success']:
            existing_product_map[product["ProductCode"]] = result['id']
            print(f"Inserted Product: {product['Name']} with ID: {result['id']}")
else:
    print("No new products to insert.")

# Step 6: Check Existing Pricebooks
existing_pricebooks = sf.query("SELECT Id, Name FROM Pricebook2")['records']
existing_pricebook_map = {pb['Name']: pb['Id'] for pb in existing_pricebooks}

# Step 7: Insert Pricebooks (Bulkified)
new_pricebooks = [
    pricebook for pricebook in pricebooks if pricebook["Name"] not in existing_pricebook_map
]

if new_pricebooks:
    results = sf.bulk.Pricebook2.insert(new_pricebooks)
    for result, pricebook in zip(results, new_pricebooks):
        if result['success']:
            existing_pricebook_map[pricebook["Name"]] = result['id']
            print(f"Inserted Pricebook: {pricebook['Name']} with ID: {result['id']}")
else:
    print("No new pricebooks to insert.")

# Step 8: Check Existing Standard Pricebook Entries
existing_standard_entries = sf.query(f"SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = '{standard_pricebook_id}'")['records']
existing_standard_product_ids = {entry['Product2Id'] for entry in existing_standard_entries}

# Step 9: Insert Standard Pricebook Entries (Bulkified)
new_standard_entries = [
    {
        "Pricebook2Id": standard_pricebook_id,
        "Product2Id": existing_product_map[product["ProductCode"]],
        "UnitPrice": 100.0,
        "IsActive": True
    }
    for product in products if existing_product_map[product["ProductCode"]] not in existing_standard_product_ids
]

if new_standard_entries:
    results = sf.bulk.PricebookEntry.insert(new_standard_entries)
    for result in results:
        if result['success']:
            print(f"Inserted Standard Pricebook Entry: {result['id']}")
else:
    print("No new standard pricebook entries to insert.")

# Step 10: Check Existing Custom Pricebook Entries
existing_custom_entries = sf.query("SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry")['records']
existing_custom_entry_map = {(entry['Product2Id'], entry['Pricebook2Id']) for entry in existing_custom_entries}

# Step 11: Insert Custom Pricebook Entries (Bulkified)
new_custom_entries = [
    {
        "Pricebook2Id": existing_pricebook_map[pbe["PricebookName"]],
        "Product2Id": existing_product_map[pbe["ProductCode"]],
        "UnitPrice": pbe["UnitPrice"],
        "IsActive": pbe["IsActive"]
    }
    for pbe in pbe_entries if (existing_product_map[pbe["ProductCode"]], existing_pricebook_map[pbe["PricebookName"]]) not in existing_custom_entry_map
]

if new_custom_entries:
    results = sf.bulk.PricebookEntry.insert(new_custom_entries)
    for result in results:
        if result['success']:
            print(f"Inserted Custom Pricebook Entry: {result['id']}")
else:
    print("No new custom pricebook entries to insert.")

print("Bulk Automation Completed!")
