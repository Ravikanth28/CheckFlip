-- Create game_moves table for tracking all moves in online games
CREATE TABLE game_moves (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id TEXT REFERENCES rooms(room_id) NOT NULL,
  move_number INT NOT NULL,
  player_color TEXT NOT NULL, -- 'red' or 'black'
  move_type TEXT NOT NULL, -- 'move', 'capture', 'reinforce', 'reveal'
  from_row INT,
  from_col INT,
  to_row INT,
  to_col INT,
  piece_type TEXT,
  captured_piece TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_game_moves_room_id ON game_moves(room_id);
CREATE INDEX idx_game_moves_move_number ON game_moves(room_id, move_number);

-- Create game_states table for current game state
CREATE TABLE game_states (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id TEXT REFERENCES rooms(room_id) UNIQUE NOT NULL,
  board_size INT NOT NULL DEFAULT 4,
  current_turn TEXT NOT NULL DEFAULT 'red', -- 'red' or 'black'
  game_status TEXT NOT NULL DEFAULT 'setup', -- 'setup', 'playing', 'finished'
  winner TEXT,
  last_move_number INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for room_id lookups
CREATE INDEX idx_game_states_room_id ON game_states(room_id);

-- Instructions:
-- 1. Go to Nhost Dashboard → Hasura Console → Data → SQL
-- 2. Run this SQL
-- 3. Track both tables (game_moves and game_states)
-- 4. Set permissions for user role:
--    - game_moves: insert (own moves), select (all moves in their room)
--    - game_states: insert, select, update (for their room)
