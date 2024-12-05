import { LightningElement, api, track } from 'lwc';
import fetchOpportunityProducts from '@salesforce/apex/OpportunityServiceAdjusterController.fetchOpportunityProducts';
import updateOpportunityProduct from '@salesforce/apex/OpportunityServiceAdjusterController.updateOpportunityProduct';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AdjustOpportunityProducts extends LightningElement {
    @api recordId;
    @track products = [];
    @track isLoading = false;
    @track selectedProduct = null;

    // Fetch products on load
    connectedCallback() {
        this.loadProducts();
    }

    // Fetch Opportunity Products
    loadProducts() {
        this.isLoading = true;
        fetchOpportunityProducts({ opportunityId: this.recordId })
            .then((data) => {
                this.products = data;
                this.isLoading = false;
            })
            .catch((error) => {
                this.showToast('Error', error.body?.message || error.message, 'error');
                this.isLoading = false;
            });
    }

    // Edit product
    handleEditProduct(event) {
        const productId = event.target.dataset.id;
        this.selectedProduct = JSON.parse(
            JSON.stringify(this.products.find((product) => product.Id === productId))
        );
    }

    // Save product changes
    handleSaveProduct() {
        this.isLoading = true;

        // Input validation
        if (!this.selectedProduct.Quantity || this.selectedProduct.Quantity <= 0) {
            this.showToast('Error', 'Quantity must be greater than 0.', 'error');
            this.isLoading = false;
            return;
        }

        if (!this.selectedProduct.UnitPrice || this.selectedProduct.UnitPrice < 0) {
            this.showToast('Error', 'Unit Price must be positive.', 'error');
            this.isLoading = false;
            return;
        }

        updateOpportunityProduct({ updatedProduct: this.selectedProduct })
            .then(() => {
                this.showToast('Success', 'Product updated successfully!', 'success');
                this.selectedProduct = null;
                this.loadProducts();
            })
            .catch((error) => {
                this.showToast('Error', error.body?.message || error.message, 'error');
                this.isLoading = false;
            });
    }

    // Handle input changes
    handleInputChange(event) {
        const field = event.target.dataset.field;
        this.selectedProduct[field] = event.target.value;
    }

    // Close modal
    handleCloseModal() {
        this.selectedProduct = null;
    }

    // Show Toast Notification
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(evt);
    }
}
