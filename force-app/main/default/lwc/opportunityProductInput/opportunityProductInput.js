import { LightningElement, api, track } from 'lwc';
import getOpportunityDetails from '@salesforce/apex/OpportunityProductController.getOpportunityDetails';
import getAvailableProducts from '@salesforce/apex/OpportunityProductController.getAvailableProducts';
import getPricebooks from '@salesforce/apex/OpportunityProductController.getPricebooks';
import createOpportunityProducts from '@salesforce/apex/OpportunityProductController.createOpportunityProducts';

export default class OpportunityProductInput extends LightningElement {
    @api recordId;
    @track opportunityName = '';
    @track customerName = '';
    @track contactName = 'N/A';
    @track opportunityPricebook = 'N/A';
    @track preCheckFormPricebook = 'N/A';
    @track pricebookOptions = [];
    @track selectedPricebook = '';
    @track productData = [];
    @track currentPageProducts = [];
    @track selectedProductsMap = new Map(); // Track selected rows across pages
    @track errorMessage = '';
    @track successMessage = '';
    @track totalProductsAdded = 0;
    @track totalValueAdded = 0;
    @track searchKey = '';
    @track currentPage = 1;
    @track totalPages = 1;
    pageSize = 5;

    serviceStartTime = '';
    serviceEndTime = '';
    description = '';
    quantity = 1;
    discount = 0;

    columns = [
        { label: 'Product Name', fieldName: 'productName' },
        { label: 'Product Code', fieldName: 'productCode' },
        { label: 'Unit Price', fieldName: 'unitPrice', type: 'currency' }
    ];

    connectedCallback() {
        if (this.recordId) {
            this.fetchOpportunityDetails();
        } else {
            this.errorMessage = 'Error: No recordId available. Please add this component to an Opportunity record page.';
        }
    }

    fetchOpportunityDetails() {
        getOpportunityDetails({ opportunityId: this.recordId })
            .then((data) => {
                this.opportunityName = data.Name;
                this.customerName = data.Account ? data.Account.Name : 'No Account';
                this.contactName = data.Pre_Check_Form__r?.Contact__r?.Name || 'No Contact';
                this.opportunityPricebook = data.Pricebook2?.Name || 'No Pricebook';
                this.preCheckFormPricebook = data.Pre_Check_Form__r?.Price_Book__r?.Name || 'No Pricebook';

                if (data.Pricebook2Id) {
                    this.selectedPricebook = data.Pricebook2Id;
                    this.loadProducts();
                } else {
                    this.loadPricebooks();
                }
            })
            .catch((error) => {
                this.errorMessage = 'Error fetching Opportunity details: ' + (error.body?.message || error.message);
            });
    }

    loadPricebooks() {
        getPricebooks()
            .then((data) => {
                this.pricebookOptions = data.map((pricebook) => ({
                    label: pricebook.Name,
                    value: pricebook.Id
                }));
            })
            .catch((error) => {
                this.errorMessage = 'Error loading Pricebooks: ' + (error.body?.message || error.message);
            });
    }

    handlePricebookChange(event) {
        this.selectedPricebook = event.target.value;
        this.loadProducts();
    }

    loadProducts() {
        getAvailableProducts({ opportunityId: this.recordId })
            .then((data) => {
                this.productData = data.map((entry) => ({
                    id: entry.Id,
                    productId: entry.Product2Id,
                    productName: entry.Product2.Name,
                    productCode: entry.Product2.ProductCode,
                    unitPrice: entry.UnitPrice
                }));
                this.errorMessage = '';
                this.totalPages = Math.ceil(this.productData.length / this.pageSize);
                this.updateCurrentPageProducts();
            })
            .catch((error) => {
                this.errorMessage = 'Error loading Products: ' + (error.body?.message || error.message);
            });
    }

    updateCurrentPageProducts() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        const filteredProducts = this.productData.filter((product) =>
            product.productName.toLowerCase().includes(this.searchKey.toLowerCase())
        );
        this.totalPages = Math.ceil(filteredProducts.length / this.pageSize);
        this.currentPageProducts = filteredProducts.slice(start, end);

        // Update selected state for products in the current page
        this.currentPageProducts.forEach((product) => {
            product.isSelected = this.selectedProductsMap.has(product.id);
        });
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;

        // Add selected rows to the map
        selectedRows.forEach((row) => {
            this.selectedProductsMap.set(row.id, row);
        });

        // Remove rows that were deselected
        this.currentPageProducts.forEach((row) => {
            if (!selectedRows.find((selected) => selected.id === row.id)) {
                this.selectedProductsMap.delete(row.id);
            }
        });
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;

        if (field === 'searchKey') {
            this.currentPage = 1;
            this.updateCurrentPageProducts();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updateCurrentPageProducts();
        }
    }

    createOpportunityProducts() {
        const opportunityProducts = Array.from(this.selectedProductsMap.values()).map((product) => ({
            OpportunityId: this.recordId,
            PricebookEntryId: product.id,
            Quantity: this.quantity,
            UnitPrice: product.unitPrice * (1 - this.discount / 100),
            ServiceDate: this.serviceDate,
            Description: this.description,
            JBP_Service_Offering_Start_Time__c: this.serviceStartTime,
            JBP_Service_Offering_End_Time__c: this.serviceEndTime
        }));

        createOpportunityProducts({ opportunityProducts })
            .then((result) => {
                this.errorMessage = '';
                this.successMessage = 'Products added successfully!';
                this.totalProductsAdded = result.successfulCount || 0;
                this.totalValueAdded = result.totalValue || 0;
            })
            .catch((error) => {
                this.errorMessage = 'Error creating Opportunity Products: ' + (error.body?.message || error.message);
            });
    }

    get selectedRowIds() {
        return Array.from(this.selectedProductsMap.keys());
    }

    // Getter for Selected Products Summary
    get selectedProductsSummary() {
        return Array.from(this.selectedProductsMap.values());
    }
}
