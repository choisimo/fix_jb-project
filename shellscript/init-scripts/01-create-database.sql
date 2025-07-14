-- Create database jbreport as well as jbreport_prod 
SELECT 'CREATE DATABASE jbreport' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'jbreport')\gexec
SELECT 'CREATE DATABASE jbreport_prod' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'jbreport_prod')\gexec

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
