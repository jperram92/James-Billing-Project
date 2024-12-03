import { LightningElement, track } from 'lwc';

export default class TicTacToe extends LightningElement {
    @track board = [
        ['', '', ''],
        ['', '', ''],
        ['', '', '']
    ];
    @track currentPlayer = 'X';
    @track statusMessage = 'Player X\'s turn';

    handleCellClick(event) {
        const { row, col } = event.detail;

        // Update the board manually for debugging
        if (!this.board[row][col]) {
            this.board[row][col] = this.currentPlayer;

            // Force reactivity by recreating the board array
            this.board = [...this.board];

            if (this.checkWin()) {
                this.statusMessage = `Player ${this.currentPlayer} wins!`;
            } else if (this.checkDraw()) {
                this.statusMessage = 'It\'s a draw!';
            } else {
                this.currentPlayer = this.currentPlayer === 'X' ? 'O' : 'X';
                this.statusMessage = `Player ${this.currentPlayer}'s turn`;
            }
        }
    }

    checkWin() {
        const winPatterns = [
            [this.board[0][0], this.board[0][1], this.board[0][2]],
            [this.board[1][0], this.board[1][1], this.board[1][2]],
            [this.board[2][0], this.board[2][1], this.board[2][2]],
            [this.board[0][0], this.board[1][0], this.board[2][0]],
            [this.board[0][1], this.board[1][1], this.board[2][1]],
            [this.board[0][2], this.board[1][2], this.board[2][2]],
            [this.board[0][0], this.board[1][1], this.board[2][2]],
            [this.board[0][2], this.board[1][1], this.board[2][0]],
        ];

        return winPatterns.some(pattern =>
            pattern.every(cell => cell === this.currentPlayer)
        );
    }

    checkDraw() {
        return this.board.every(row => row.every(cell => cell !== ''));
    }

    resetGame() {
        this.board = [
            ['', '', ''],
            ['', '', ''],
            ['', '', '']
        ];
        this.currentPlayer = 'X';
        this.statusMessage = 'Player X\'s turn';
    }
}
