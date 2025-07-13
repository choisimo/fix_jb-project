#!/bin/bash

set -e

echo "🗂️ Setting up file storage for JB Report Platform..."

# Default paths
DEFAULT_STORAGE_PATH="/var/jbreport/uploads"
DEFAULT_BACKUP_PATH="/var/jbreport/backups"

# Check if running as root for production setup
if [ "$EUID" -ne 0 ] && [ "$1" == "prod" ]; then 
   echo "❌ Production setup requires root privileges. Please run with sudo."
   exit 1
fi

# Create storage directories
setup_directories() {
    local storage_path=${FILE_STORAGE_PATH:-$DEFAULT_STORAGE_PATH}
    local backup_path=${FILE_BACKUP_PATH:-$DEFAULT_BACKUP_PATH}
    
    echo "📁 Creating storage directories..."
    
    # Main storage
    mkdir -p "$storage_path"
    
    # Year/month subdirectories for current and next month
    current_month=$(date +%Y/%m)
    next_month=$(date -d "next month" +%Y/%m)
    
    mkdir -p "$storage_path/$current_month"
    mkdir -p "$storage_path/$next_month"
    
    # Backup directory
    mkdir -p "$backup_path"
    
    echo "✅ Directories created:"
    echo "   - Storage: $storage_path"
    echo "   - Backup: $backup_path"
}

# Set permissions
set_permissions() {
    local storage_path=${FILE_STORAGE_PATH:-$DEFAULT_STORAGE_PATH}
    
    if [ "$1" == "prod" ]; then
        echo "🔒 Setting production permissions..."
        
        # Create jbreport user if not exists
        if ! id "jbreport" &>/dev/null; then
            useradd -r -s /bin/false jbreport
            echo "✅ Created jbreport user"
        fi
        
        # Set ownership and permissions
        chown -R jbreport:jbreport "$storage_path"
        chmod -R 755 "$storage_path"
        
        # Set sticky bit on upload directory
        chmod +t "$storage_path"
        
    else
        echo "🔓 Setting development permissions..."
        chmod -R 755 "$storage_path"
    fi
}

# Setup log rotation
setup_log_rotation() {
    if [ "$1" == "prod" ]; then
        echo "📋 Setting up log rotation..."
        
        cat > /etc/logrotate.d/jbreport-uploads << EOF
$DEFAULT_STORAGE_PATH/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0644 jbreport jbreport
}
EOF
        
        echo "✅ Log rotation configured"
    fi
}

# Create test files for development
create_test_files() {
    if [ "$1" != "prod" ]; then
        echo "🧪 Creating test files for development..."
        
        local storage_path=${FILE_STORAGE_PATH:-"./data/uploads"}
        local test_report_id=1
        local test_month=$(date +%Y/%m)
        
        mkdir -p "$storage_path/$test_month/$test_report_id"
        
        # Create a test image
        convert -size 100x100 xc:blue "$storage_path/$test_month/$test_report_id/test_image.jpg" 2>/dev/null || \
            echo "Test image" > "$storage_path/$test_month/$test_report_id/test_file.txt"
        
        echo "✅ Test files created"
    fi
}

# Verify setup
verify_setup() {
    local storage_path=${FILE_STORAGE_PATH:-$DEFAULT_STORAGE_PATH}
    
    echo "🔍 Verifying setup..."
    
    # Check directory exists
    if [ ! -d "$storage_path" ]; then
        echo "❌ Storage directory not found: $storage_path"
        exit 1
    fi
    
    # Check write permissions
    if [ -w "$storage_path" ]; then
        echo "✅ Write permissions OK"
    else
        echo "❌ No write permissions on $storage_path"
        exit 1
    fi
    
    # Check disk space
    available_space=$(df -BG "$storage_path" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 10 ]; then
        echo "⚠️  Warning: Low disk space (${available_space}GB available)"
    else
        echo "✅ Disk space OK (${available_space}GB available)"
    fi
}

# Main execution
MODE=${1:-dev}

echo "Mode: $MODE"
echo ""

setup_directories
set_permissions "$MODE"
setup_log_rotation "$MODE"
create_test_files "$MODE"
verify_setup

echo ""
echo "✅ File storage setup completed successfully!"
echo ""
echo "📝 Configuration to add to your .env file:"
echo "   FILE_STORAGE_PATH=${FILE_STORAGE_PATH:-$DEFAULT_STORAGE_PATH}"
echo "   FILE_BACKUP_PATH=${FILE_BACKUP_PATH:-$DEFAULT_BACKUP_PATH}"
