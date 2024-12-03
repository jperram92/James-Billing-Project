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

# Step 4: Insert Products
product_map = {}
for product in products:
    result = sf.Product2.create(product)
    product_map[product["ProductCode"]] = result['id']
    print(f"Inserted Product: {product['Name']} with ID: {result['id']}")

# Step 5: Insert Pricebooks
pricebook_map = {}
for pricebook in pricebooks:
    result = sf.Pricebook2.create(pricebook)
    pricebook_map[pricebook["Name"]] = result['id']
    print(f"Inserted Pricebook: {pricebook['Name']} with ID: {result['id']}")

# Step 6: Insert Standard Pricebook Entries
for product_code, product_id in product_map.items():
    standard_pricebook_entry = {
        "Pricebook2Id": standard_pricebook_id,
        "Product2Id": product_id,
        "UnitPrice": 100.0,  # Define a default standard price
        "IsActive": True
    }
    sf.PricebookEntry.create(standard_pricebook_entry)
    print(f"Inserted Standard Pricebook Entry for ProductCode: {product_code}")

# Step 7: Insert Custom Pricebook Entries
for pbe in pbe_entries:
    product_id = product_map[pbe["ProductCode"]]
    pricebook_id = pricebook_map[pbe["PricebookName"]]
    pbe_record = {
        "Pricebook2Id": pricebook_id,
        "Product2Id": product_id,
        "UnitPrice": pbe["UnitPrice"],
        "IsActive": pbe["IsActive"]
    }
    sf.PricebookEntry.create(pbe_record)
    print(f"Inserted Custom Pricebook Entry for ProductCode: {pbe['ProductCode']} in Pricebook: {pbe['PricebookName']}")

print("Automation Completed!")
