import { LightningElement, api, track } from 'lwc';

export default class TicTacToeBoard extends LightningElement {
    @track boardWithKeys = [];

    @api
    set board(value) {
        if (value && Array.isArray(value)) {
            console.log('Updating boardWithKeys with new board:', value); // Debugging
            this.boardWithKeys = this.addKeysToBoard(value);
        } else {
            console.error('Invalid board value:', value); // Debugging
            this.boardWithKeys = [];
        }
    }

    get board() {
        return this.boardWithKeys.map(row => row.cells.map(cell => cell.value));
    }

    handleCellClick(event) {
        const { row, col } = event.detail;
        if (row !== undefined && col !== undefined) {
            this.dispatchEvent(new CustomEvent('cellclick', { detail: { row, col } }));
        } else {
            console.error('Invalid row or col in handleCellClick:', { row, col });
        }
    }

    addKeysToBoard(board) {
        try {
            return board.map((row, rowIndex) => ({
                rowKey: `row-${rowIndex}`,
                cells: row.map((cell, colIndex) => {
                    console.log(`Setting value for cell [${rowIndex}, ${colIndex}]: ${cell}`);
                    return {
                        cellKey: `cell-${rowIndex}-${colIndex}`,
                        value: cell // Pass cell value dynamically
                    };
                })
            }));
        } catch (error) {
            console.error('Error in addKeysToBoard:', error); // Log mapping errors
            return [];
        }
    }
}
