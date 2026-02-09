from flask import Flask, render_template, jsonify, request
import chess
import math

app = Flask(__name__)
games = {}

# ---------------- IA ---------------- #

class ChessAI:
    PIECE_VALUES = {
        chess.PAWN: 100,
        chess.KNIGHT: 320,
        chess.BISHOP: 330,
        chess.ROOK: 500,
        chess.QUEEN: 900,
        chess.KING: 20000
    }

    def __init__(self, difficulty):
        self.difficulty = difficulty
        self.depth = {
            'beginner': 1,
            'intermediate': 2,
            'advanced': 3,
            'professional': 5
        }.get(difficulty, 2)

    def evaluate(self, board: chess.Board):
        # jaque mate
        if board.is_checkmate():
            return -math.inf if board.turn == chess.BLACK else math.inf

        if board.is_stalemate() or board.is_insufficient_material():
            return 0

        score = 0

        # material
        for square in chess.SQUARES:
            piece = board.piece_at(square)
            if piece:
                value = self.PIECE_VALUES[piece.piece_type]
                score += value if piece.color == chess.BLACK else -value

        # jaque
        if board.is_check():
            score += 50 if board.turn == chess.WHITE else -50

        # rey expuesto
        score -= self.exposed_king_penalty(board, chess.WHITE)
        score += self.exposed_king_penalty(board, chess.BLACK)

        return score

    def exposed_king_penalty(self, board, color):
        king_square = board.king(color)
        if king_square is None:
            return 0
        attackers = board.attackers(not color, king_square)
        return len(attackers) * 40

    def move_ordering(self, board):
        moves = list(board.legal_moves)

        def score_move(move):
            score = 0
            if board.is_capture(move):
                captured = board.piece_at(move.to_square)
                if captured:
                    score += self.PIECE_VALUES[captured.piece_type] * 10
            if board.gives_check(move):
                score += 500
            return score

        moves.sort(key=score_move, reverse=True)
        return moves

    def minimax(self, board, depth, alpha, beta, maximizing):
        if depth == 0 or board.is_game_over():
            return self.evaluate(board)

        if maximizing:
            max_eval = -math.inf
            for move in self.move_ordering(board):
                board.push(move)
                eval = self.minimax(board, depth - 1, alpha, beta, False)
                board.pop()
                max_eval = max(max_eval, eval)
                alpha = max(alpha, eval)
                if beta <= alpha:
                    break
            return max_eval
        else:
            min_eval = math.inf
            for move in self.move_ordering(board):
                board.push(move)
                eval = self.minimax(board, depth - 1, alpha, beta, True)
                board.pop()
                min_eval = min(min_eval, eval)
                beta = min(beta, eval)
                if beta <= alpha:
                    break
            return min_eval

    def best_move(self, board):
        best = None
        best_value = -math.inf

        for move in self.move_ordering(board):
            board.push(move)
            value = self.minimax(board, self.depth - 1, -math.inf, math.inf, False)
            board.pop()

            if value > best_value:
                best_value = value
                best = move

        return best

# ---------------- RUTAS ---------------- #

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/new_game', methods=['POST'])
def new_game():
    data = request.json
    board = chess.Board()
    games[data['game_id']] = {
        'board': board,
        'ai': ChessAI(data['difficulty'])
    }
    return jsonify({'fen': board.fen()})

@app.route('/get_legal_moves', methods=['POST'])
def legal_moves():
    data = request.json
    board = games[data['game_id']]['board']
    square = chess.parse_square(data['square'])
    moves = [m.uci() for m in board.legal_moves if m.from_square == square]
    return jsonify({'moves': moves})

@app.route('/move', methods=['POST'])
def move():
    data = request.json
    board = games[data['game_id']]['board']
    ai = games[data['game_id']]['ai']

    try:
        move = chess.Move.from_uci(data['move'])
        if move not in board.legal_moves:
            return jsonify({'success': False})

        board.push(move)

        if not board.is_game_over():
            ai_move = ai.best_move(board)
            if ai_move:
                board.push(ai_move)

        return jsonify({
            'success': True,
            'fen': board.fen(),
            'game_over': board.is_game_over(),
            'result': board.result() if board.is_game_over() else None
        })
    except:
        return jsonify({'success': False})

if __name__ == '__main__':
    app.run(debug=True)
