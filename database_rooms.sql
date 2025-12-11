-- Create rooms table for multiplayer game rooms
CREATE TABLE rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id TEXT UNIQUE NOT NULL,
  creator_id uuid REFERENCES auth.users(id),
  opponent_id uuid REFERENCES auth.users(id),
  status TEXT NOT NULL DEFAULT 'waiting',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster room_id lookups
CREATE INDEX idx_rooms_room_id ON rooms(room_id);
CREATE INDEX idx_rooms_status ON rooms(status);

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_rooms_updated_at
BEFORE UPDATE ON rooms
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Instructions:
-- 1. Go to Nhost Dashboard → SQL Editor
-- 2. Paste and run this SQL
-- 3. Go to Hasura Console → Data → rooms table → Permissions
-- 4. Set permissions:
--    - Insert: Custom check: {"creator_id":{"_eq":"X-Hasura-User-Id"}}
--    - Select: Custom check: {"_or":[{"creator_id":{"_eq":"X-Hasura-User-Id"}},{"opponent_id":{"_eq":"X-Hasura-User-Id"}}]}
--    - Update: Custom check: {"status":{"_eq":"waiting"}}
--    - Delete: Custom check: {"creator_id":{"_eq":"X-Hasura-User-Id"}}
