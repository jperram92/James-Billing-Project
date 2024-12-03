import { LightningElement, api } from 'lwc';

export default class TicTacToeCell extends LightningElement {
    @api value;
    @api row;
    @api col;

    handleClick() {
        try {
            if (this.row === undefined || this.col === undefined) {
                throw new Error('Row or column is undefined in TicTacToeCell');
            }
            console.log('Cell clicked:', { row: this.row, col: this.col }); // Debugging cell click
            this.dispatchEvent(new CustomEvent('click', {
                detail: { row: this.row, col: this.col }
            }));
        } catch (error) {
            console.error('Error in handleClick:', error); // Log any errors
        }
    }
}
