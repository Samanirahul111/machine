/*
  # Maintenance Management System Schema

  1. New Tables
    - `equipment_categories`
      - `id` (uuid, primary key)
      - `name` (text) - Category name (e.g., "HVAC", "Electrical")
      - `created_at` (timestamptz)
    
    - `maintenance_teams`
      - `id` (uuid, primary key)
      - `name` (text) - Team name
      - `created_at` (timestamptz)
    
    - `equipment`
      - `id` (uuid, primary key)
      - `name` (text) - Equipment name
      - `category_id` (uuid, foreign key)
      - `team_id` (uuid, foreign key)
      - `created_at` (timestamptz)
    
    - `maintenance_requests`
      - `id` (uuid, primary key)
      - `title` (text) - Request title/subject
      - `equipment_id` (uuid, foreign key)
      - `request_type` (text) - 'corrective' or 'preventive'
      - `scheduled_date` (date) - Scheduled maintenance date
      - `priority` (text) - 'low', 'medium', 'high'
      - `description` (text) - Detailed description
      - `attachment_url` (text, optional) - File attachment URL
      - `status` (text) - Request status (default: 'new')
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Add policies for public access (for demo purposes)
    
  3. Sample Data
    - Insert sample categories, teams, and equipment for testing
*/

-- Create equipment_categories table
CREATE TABLE IF NOT EXISTS equipment_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create maintenance_teams table
CREATE TABLE IF NOT EXISTS maintenance_teams (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create equipment table
CREATE TABLE IF NOT EXISTS equipment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category_id uuid REFERENCES equipment_categories(id),
  team_id uuid REFERENCES maintenance_teams(id),
  created_at timestamptz DEFAULT now()
);

-- Create maintenance_requests table
CREATE TABLE IF NOT EXISTS maintenance_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  equipment_id uuid REFERENCES equipment(id),
  request_type text NOT NULL CHECK (request_type IN ('corrective', 'preventive')),
  scheduled_date date NOT NULL,
  priority text NOT NULL CHECK (priority IN ('low', 'medium', 'high')),
  description text NOT NULL,
  attachment_url text,
  status text DEFAULT 'new',
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE equipment_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_requests ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (for demo purposes)
CREATE POLICY "Allow public read access to equipment_categories"
  ON equipment_categories FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Allow public read access to maintenance_teams"
  ON maintenance_teams FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Allow public read access to equipment"
  ON equipment FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Allow public insert to maintenance_requests"
  ON maintenance_requests FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Allow public read access to maintenance_requests"
  ON maintenance_requests FOR SELECT
  TO anon
  USING (true);

-- Insert sample equipment categories
INSERT INTO equipment_categories (name) VALUES
  ('HVAC Systems'),
  ('Electrical Systems'),
  ('Plumbing'),
  ('Fire Safety'),
  ('Building Automation'),
  ('Elevators & Lifts')
ON CONFLICT DO NOTHING;

-- Insert sample maintenance teams
INSERT INTO maintenance_teams (name) VALUES
  ('HVAC Technicians'),
  ('Electrical Team'),
  ('Plumbing Services'),
  ('Fire Safety Team'),
  ('Automation Specialists'),
  ('Elevator Maintenance')
ON CONFLICT DO NOTHING;

-- Insert sample equipment
INSERT INTO equipment (name, category_id, team_id)
SELECT 
  'Chiller Unit - Building A',
  (SELECT id FROM equipment_categories WHERE name = 'HVAC Systems' LIMIT 1),
  (SELECT id FROM maintenance_teams WHERE name = 'HVAC Technicians' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM equipment WHERE name = 'Chiller Unit - Building A');

INSERT INTO equipment (name, category_id, team_id)
SELECT 
  'Air Handler - Floor 3',
  (SELECT id FROM equipment_categories WHERE name = 'HVAC Systems' LIMIT 1),
  (SELECT id FROM maintenance_teams WHERE name = 'HVAC Technicians' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM equipment WHERE name = 'Air Handler - Floor 3');

INSERT INTO equipment (name, category_id, team_id)
SELECT 
  'Main Power Panel - Basement',
  (SELECT id FROM equipment_categories WHERE name = 'Electrical Systems' LIMIT 1),
  (SELECT id FROM maintenance_teams WHERE name = 'Electrical Team' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM equipment WHERE name = 'Main Power Panel - Basement');

INSERT INTO equipment (name, category_id, team_id)
SELECT 
  'Emergency Generator',
  (SELECT id FROM equipment_categories WHERE name = 'Electrical Systems' LIMIT 1),
  (SELECT id FROM maintenance_teams WHERE name = 'Electrical Team' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM equipment WHERE name = 'Emergency Generator');

INSERT INTO equipment (name, category_id, team_id)
SELECT 
  'Water Pump Station',
  (SELECT id FROM equipment_categories WHERE name = 'Plumbing' LIMIT 1),
  (SELECT id FROM maintenance_teams WHERE name = 'Plumbing Services' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM equipment WHERE name = 'Water Pump Station');

INSERT INTO equipment (name, category_id, team_id)
SELECT 
  'Fire Alarm Control Panel',
  (SELECT id FROM equipment_categories WHERE name = 'Fire Safety' LIMIT 1),
  (SELECT id FROM maintenance_teams WHERE name = 'Fire Safety Team' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM equipment WHERE name = 'Fire Alarm Control Panel');

INSERT INTO equipment (name, category_id, team_id)
SELECT 
  'Sprinkler System - Zone 1',
  (SELECT id FROM equipment_categories WHERE name = 'Fire Safety' LIMIT 1),
  (SELECT id FROM maintenance_teams WHERE name = 'Fire Safety Team' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM equipment WHERE name = 'Sprinkler System - Zone 1');

INSERT INTO equipment (name, category_id, team_id)
SELECT 
  'BMS Controller',
  (SELECT id FROM equipment_categories WHERE name = 'Building Automation' LIMIT 1),
  (SELECT id FROM maintenance_teams WHERE name = 'Automation Specialists' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM equipment WHERE name = 'BMS Controller');

INSERT INTO equipment (name, category_id, team_id)
SELECT 
  'Passenger Elevator #1',
  (SELECT id FROM equipment_categories WHERE name = 'Elevators & Lifts' LIMIT 1),
  (SELECT id FROM maintenance_teams WHERE name = 'Elevator Maintenance' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM equipment WHERE name = 'Passenger Elevator #1');

INSERT INTO equipment (name, category_id, team_id)
SELECT 
  'Freight Elevator',
  (SELECT id FROM equipment_categories WHERE name = 'Elevators & Lifts' LIMIT 1),
  (SELECT id FROM maintenance_teams WHERE name = 'Elevator Maintenance' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM equipment WHERE name = 'Freight Elevator');