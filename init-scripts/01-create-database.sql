-- Create database if not exists
CREATE DATABASE IF NOT EXISTS jbreport_prod;

-- Create user if not exists
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'jbreport') THEN
      CREATE ROLE jbreport LOGIN PASSWORD 'changeme';
   END IF;
END
$do$;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE jbreport_prod TO jbreport;

-- Switch to jbreport_prod database
\c jbreport_prod;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO jbreport;
