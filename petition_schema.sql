-- Petition Signatures Schema
-- This script creates the database schema for storing petition signatures

-- Create the petition_signatures table
CREATE TABLE IF NOT EXISTS petition_signatures (
    id SERIAL PRIMARY KEY,
    handle VARCHAR(255) NOT NULL UNIQUE,
    message TEXT DEFAULT '',
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on handle for faster duplicate checking
CREATE INDEX IF NOT EXISTS idx_petition_signatures_handle ON petition_signatures(handle);

-- Create index on timestamp for ordered retrieval
CREATE INDEX IF NOT EXISTS idx_petition_signatures_timestamp ON petition_signatures(timestamp DESC);

-- Function to check signature count and prevent exceeding 1000
CREATE OR REPLACE FUNCTION check_signature_limit()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if we already have 1000 signatures
    IF (SELECT COUNT(*) FROM petition_signatures) >= 1000 THEN
        RAISE EXCEPTION 'Maximum signature limit of 1000 has been reached';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to enforce the 1000 signature limit
DROP TRIGGER IF EXISTS signature_limit_trigger ON petition_signatures;
CREATE TRIGGER signature_limit_trigger
    BEFORE INSERT ON petition_signatures
    FOR EACH ROW
    EXECUTE FUNCTION check_signature_limit();

-- Function to check for duplicate signatures
CREATE OR REPLACE FUNCTION check_duplicate_signature()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if handle already exists (case-insensitive)
    IF EXISTS (SELECT 1 FROM petition_signatures WHERE LOWER(handle) = LOWER(NEW.handle)) THEN
        RAISE EXCEPTION 'Handle % has already signed the petition', NEW.handle;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to prevent duplicate signatures
DROP TRIGGER IF EXISTS duplicate_signature_trigger ON petition_signatures;
CREATE TRIGGER duplicate_signature_trigger
    BEFORE INSERT ON petition_signatures
    FOR EACH ROW
    EXECUTE FUNCTION check_duplicate_signature();

-- Enable Row Level Security (RLS) for better security
ALTER TABLE petition_signatures ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow public read access" ON petition_signatures;
DROP POLICY IF EXISTS "Allow public insert access" ON petition_signatures;

-- Create policy to allow anyone to read signatures
CREATE POLICY "Allow public read access" ON petition_signatures
    FOR SELECT USING (true);

-- Create policy to allow anyone to insert signatures (with our constraints)
CREATE POLICY "Allow public insert access" ON petition_signatures
    FOR INSERT WITH CHECK (true);

-- Create a view for recent signatures (last 5)
CREATE OR REPLACE VIEW recent_signatures AS
SELECT 
    id,
    handle,
    message,
    timestamp,
    created_at
FROM petition_signatures
ORDER BY timestamp DESC
LIMIT 5;

-- Create a function to get signature count
CREATE OR REPLACE FUNCTION get_signature_count()
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM petition_signatures);
END;
$$ LANGUAGE plpgsql;

-- Create a function to safely add a signature
CREATE OR REPLACE FUNCTION add_signature(
    p_handle VARCHAR(255),
    p_message TEXT DEFAULT ''
)
RETURNS JSON AS $$
DECLARE
    new_signature_id INTEGER;
    result JSON;
BEGIN
    -- Insert the new signature
    INSERT INTO petition_signatures (handle, message)
    VALUES (p_handle, p_message)
    RETURNING id INTO new_signature_id;
    
    -- Return success response with signature details
    SELECT json_build_object(
        'success', true,
        'id', new_signature_id,
        'handle', p_handle,
        'message', p_message,
        'total_signatures', get_signature_count()
    ) INTO result;
    
    RETURN result;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Return error response
        SELECT json_build_object(
            'success', false,
            'error', SQLERRM,
            'total_signatures', get_signature_count()
        ) INTO result;
        
        RETURN result;
END;
$$ LANGUAGE plpgsql;
