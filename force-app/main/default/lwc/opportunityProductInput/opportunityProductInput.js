import { LightningElement, api, track } from 'lwc';
import getOpportunityDetails from '@salesforce/apex/OpportunityProductController.getOpportunityDetails';
import getAvailableProducts from '@salesforce/apex/OpportunityProductController.getAvailableProducts';
import getPricebooks from '@salesforce/apex/OpportunityProductController.getPricebooks';
import createOpportunityProducts from '@salesforce/apex/OpportunityProductController.createOpportunityProducts';

export default class OpportunityProductInput extends LightningElement {
    @api recordId; // Current Opportunity ID
    @track opportunityName = '';
    @track customerName = '';
    @track contactName = 'N/A';
    @track opportunityPricebook = 'N/A';
    @track preCheckFormPricebook = 'N/A';
    @track pricebookOptions = [];
    @track selectedPricebook = '';
    @track productData = [];
    @track currentPageProducts = [];
    @track selectedProducts = [];
    @track errorMessage = ''; // Error message for UI display
    @track successMessage = ''; // Success message for UI display
    @track totalProductsAdded = 0; // Total number of products added
    @track totalValueAdded = 0; // Total value of products added
    @track searchKey = ''; // Search input value
    @track currentPage = 1; // Current page number
    @track totalPages = 1; // Total pages
    pageSize = 5; // Number of products per page

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
                this.errorMessage = ''; // Clear any previous error

                // Initialize pagination
                this.totalPages = Math.ceil(this.productData.length / this.pageSize);
                this.updateCurrentPageProducts();
            })
            .catch((error) => {
                this.errorMessage = 'Error loading Products: ' + (error.body?.message || error.message);
            });
    }

    updateCurrentPageProducts() {
        console.log('Updating Current Page Products');
        console.log(`Current Page: ${this.currentPage}, Total Pages: ${this.totalPages}`);
        
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;

        const filteredProducts = this.productData.filter((product) =>
            product.productName.toLowerCase().includes(this.searchKey.toLowerCase())
        );

        this.totalPages = Math.ceil(filteredProducts.length / this.pageSize);
        console.log(`Filtered Products: ${filteredProducts.length}, Total Pages: ${this.totalPages}`);

        this.currentPageProducts = filteredProducts.slice(start, end);

        // Ensure currentPage is within valid range
        if (this.currentPage > this.totalPages) {
            this.currentPage = this.totalPages;
        } else if (this.currentPage < 1) {
            this.currentPage = 1;
        }
        console.log(`Final Current Page: ${this.currentPage}`);
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
        console.log(`Navigating to the next page. Current page: ${this.currentPage}`);
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        } else {
            this.currentPage = 1; // Loop back to the first page
        }
        this.updateCurrentPageProducts();
    }

    createOpportunityProducts() {
        const opportunityProducts = this.selectedProducts.map((product) => ({
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
                this.errorMessage = ''; // Clear any previous errors
                this.successMessage = 'Products added successfully!';
                this.totalProductsAdded = result.successfulCount || 0;
                this.totalValueAdded = result.totalValue || 0;
            })
            .catch((error) => {
                this.errorMessage = 'Error creating Opportunity Products: ' + (error.body?.message || error.message);
            });
    }
}
