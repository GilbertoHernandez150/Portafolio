let GAME_ID = null;
let selectedSquare = null;
let gameActive = false;
let currentDifficulty = 'intermediate';
let waitingAI = false;

const PIECES = {
  P:'♙', N:'♘', B:'♗', R:'♖', Q:'♕', K:'♔',
  p:'♟', n:'♞', b:'♝', r:'♜', q:'♛', k:'♚'
};

document.addEventListener('DOMContentLoaded', () => {

  document.querySelectorAll('.difficulty-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.difficulty-btn')
        .forEach(b => b.classList.remove('active'));

      btn.classList.add('active');
      currentDifficulty = btn.dataset.difficulty;
    });
  });

  document.getElementById('start-game-btn').addEventListener('click', startGame);
  document.getElementById('restart-btn').addEventListener('click', startGame);
  document.getElementById('new-game-btn').addEventListener('click', () => location.reload());
});



// INICIAR PARTIDA
async function startGame() {
  GAME_ID = 'game_' + Date.now();
  selectedSquare = null;
  gameActive = false;
  waitingAI = false;

  const res = await fetch('/new_game', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      game_id: GAME_ID,
      difficulty: currentDifficulty
    })
  });

  const data = await res.json();

  document.getElementById('welcome-screen').classList.add('hidden');
  document.getElementById('game-screen').classList.remove('hidden');

  document.getElementById('current-difficulty').innerText =
    currentDifficulty.charAt(0).toUpperCase() + currentDifficulty.slice(1);

  renderBoard(data.fen);
  gameActive = true;
}



// RENDER TABLERO
function renderBoard(fen) {
  const board = document.getElementById('chess-board');
  board.innerHTML = '';
  clearMarks();

  const rows = fen.split(' ')[0].split('/');
  let index = 0;

  rows.forEach(row => {
    for (let char of row) {
      if (isNaN(char)) {
        createSquare(board, index++, char);
      } else {
        for (let i = 0; i < parseInt(char); i++) {
          createSquare(board, index++, null);
        }
      }
    }
  });
}



// CREAR CASILLA
function createSquare(board, index, piece) {
  const square = document.createElement('div');
  const isDark = (Math.floor(index / 8) + index) % 2;
  square.className = `square ${isDark ? 'dark' : 'light'}`;

  const file = String.fromCharCode(97 + (index % 8));
  const rank = 8 - Math.floor(index / 8);
  const name = file + rank;

  square.dataset.square = name;

  if (piece) {
    square.innerHTML = `<span class="piece">${PIECES[piece]}</span>`;
  }

  square.addEventListener('click', () => handleSquareClick(name));
  board.appendChild(square);
}



// CLICK EN CASILLA
async function handleSquareClick(square) {
  if (!gameActive || waitingAI) return;

  if (selectedSquare === square) {
    selectedSquare = null;
    clearMarks();
    return;
  }

  if (selectedSquare) {
    let move = selectedSquare + square;

    // 🔧 PROMOCIÓN CORRECTA (SOLO PEÓN BLANCO)
    const fromEl = document.querySelector(
      `[data-square="${selectedSquare}"] .piece`
    );

    const isWhitePawn =
      fromEl && fromEl.textContent === PIECES.P;

    if (isWhitePawn && square[1] === '8') {
      const promo = prompt('Promoción (q, r, b, n):', 'q');
      if (promo) move += promo;
    }

    selectedSquare = null;
    clearMarks();
    await makeMove(move);
  } else {
    selectedSquare = square;
    clearMarks();
    await showLegalMoves(square);
  }
}



// MOSTRAR MOVIDAS LEGALES
async function showLegalMoves(square) {
  const res = await fetch('/get_legal_moves', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ game_id: GAME_ID, square })
  });

  const data = await res.json();

  data.moves.forEach(m => {
    const target = m.slice(2, 4);
    const el = document.querySelector(`[data-square="${target}"]`);
    if (el) el.classList.add('legal-move');
  });
}



// HACER MOVIMIENTO
async function makeMove(move) {
  waitingAI = true;

  try {
    const res = await fetch('/move', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ game_id: GAME_ID, move })
    });

    const data = await res.json();

    if (!data.success) return;

    renderBoard(data.fen);

    if (data.game_over === true) {
      gameActive = false;

      let msg = 'TABLAS';
      if (data.result === '1-0') msg = 'GANASTE';
      if (data.result === '0-1') msg = 'PERDISTE';

      setTimeout(() => alert(msg), 200);
    }

  } catch (err) {
    console.error('Error en makeMove:', err);
  } finally {
    waitingAI = false;
  }
}



// LIMPIAR MARCAS
function clearMarks() {
  document.querySelectorAll('.square')
    .forEach(sq => sq.classList.remove('legal-move'));
}
