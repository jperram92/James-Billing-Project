import { LightningElement, api, track } from 'lwc';
import uploadFile from '@salesforce/apex/FileUploadWithTypeController.uploadFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FileUploadWithType extends LightningElement {
    @api recordId; // Parent record ID
    @track selectedDocumentType; // Selected document type
    @track fileData; // File data (base64 and filename)

    @track documentTypeOptions = [
        { label: 'Proof of Identity', value: 'Proof of Identity' },
        { label: 'Government Letters', value: 'Government Letters' },
        { label: 'Consent Forms', value: 'Consent Forms' }
    ];

    get isUploadDisabled() {
        return !(this.selectedDocumentType && this.fileData);
    }

    handleDocumentTypeChange(event) {
        this.selectedDocumentType = event.detail.value;
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                this.fileData = {
                    base64: base64,
                    fileName: file.name
                };
            };
            reader.readAsDataURL(file);
        }
    }

    async handleUpload() {
        if (this.fileData && this.selectedDocumentType) {
            try {
                const documentId = await uploadFile({
                    recordId: this.recordId,
                    documentType: this.selectedDocumentType,
                    base64FileContent: this.fileData.base64,
                    fileName: this.fileData.fileName
                });

                this.showToast('Success', `File uploaded successfully. Document ID: ${documentId}`, 'success');
            } catch (error) {
                this.showToast('Error', error.body?.message || 'An error occurred.', 'error');
            }
        } else {
            this.showToast('Error', 'Please select a document type and upload a file.', 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
