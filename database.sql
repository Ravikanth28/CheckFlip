-- Create todos table for Nhost GraphQL integration
-- Run this SQL in Nhost Dashboard → Database → SQL

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create todos table
CREATE TABLE IF NOT EXISTS todos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- After running this SQL:
-- 1. Open Hasura console (available in Nhost dashboard)
-- 2. Track the 'todos' table so it becomes available in GraphQL schema
-- 3. Configure permissions in Hasura Console → Permissions:
--    - For development: allow 'authenticated' role to read/write todos
--    - For production: set row-level permissions based on user_id or session claims
