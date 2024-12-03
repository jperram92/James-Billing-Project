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

# Step 5: Insert Products
product_map = {}
for product in products:
    if product["ProductCode"] in existing_product_map:
        product_map[product["ProductCode"]] = existing_product_map[product["ProductCode"]]
        print(f"Skipped Product: {product['Name']} (already exists)")
    else:
        result = sf.Product2.create(product)
        product_map[product["ProductCode"]] = result['id']
        print(f"Inserted Product: {product['Name']} with ID: {result['id']}")

# Step 6: Check Existing Pricebooks
existing_pricebooks = sf.query("SELECT Id, Name FROM Pricebook2")['records']
existing_pricebook_map = {pb['Name']: pb['Id'] for pb in existing_pricebooks}

# Step 7: Insert Pricebooks
pricebook_map = {}
for pricebook in pricebooks:
    if pricebook["Name"] in existing_pricebook_map:
        pricebook_map[pricebook["Name"]] = existing_pricebook_map[pricebook["Name"]]
        print(f"Skipped Pricebook: {pricebook['Name']} (already exists)")
    else:
        result = sf.Pricebook2.create(pricebook)
        pricebook_map[pricebook["Name"]] = result['id']
        print(f"Inserted Pricebook: {pricebook['Name']} with ID: {result['id']}")

# Step 8: Check Existing Standard Pricebook Entries
existing_standard_entries = sf.query(f"SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = '{standard_pricebook_id}'")['records']
existing_standard_product_ids = {entry['Product2Id'] for entry in existing_standard_entries}

# Step 9: Insert Standard Pricebook Entries
for product_code, product_id in product_map.items():
    if product_id in existing_standard_product_ids:
        print(f"Skipped Standard Pricebook Entry for ProductCode: {product_code} (already exists)")
    else:
        standard_pricebook_entry = {
            "Pricebook2Id": standard_pricebook_id,
            "Product2Id": product_id,
            "UnitPrice": 100.0,  # Default standard price
            "IsActive": True
        }
        sf.PricebookEntry.create(standard_pricebook_entry)
        print(f"Inserted Standard Pricebook Entry for ProductCode: {product_code}")

# Step 10: Check Existing Custom Pricebook Entries
existing_custom_entries = sf.query("SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry")['records']
existing_custom_entry_map = {(entry['Product2Id'], entry['Pricebook2Id']) for entry in existing_custom_entries}

# Step 11: Insert Custom Pricebook Entries
for pbe in pbe_entries:
    product_id = product_map[pbe["ProductCode"]]
    pricebook_id = pricebook_map[pbe["PricebookName"]]
    if (product_id, pricebook_id) in existing_custom_entry_map:
        print(f"Skipped Custom Pricebook Entry for ProductCode: {pbe['ProductCode']} in Pricebook: {pbe['PricebookName']} (already exists)")
    else:
        pbe_record = {
            "Pricebook2Id": pricebook_id,
            "Product2Id": product_id,
            "UnitPrice": pbe["UnitPrice"],
            "IsActive": pbe["IsActive"]
        }
        sf.PricebookEntry.create(pbe_record)
        print(f"Inserted Custom Pricebook Entry for ProductCode: {pbe['ProductCode']} in Pricebook: {pbe['PricebookName']}")

print("Automation Completed!")
