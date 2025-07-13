#!/bin/bash

set -e

echo "🧪 Testing JB Report Platform File Operations..."

BASE_URL=${API_BASE_URL:-http://localhost:8080}
TEST_IMAGE="test-image.jpg"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Create test image
create_test_image() {
    echo "Creating test image..."
    # Create a 1x1 pixel JPEG using base64
    echo "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEB" | base64 -d > "$TEST_IMAGE"
}

# Login and get token
login() {
    echo "Logging in..."
    
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
        -H "Content-Type: application/json" \
        -d '{
            "email": "test@example.com",
            "password": "password123"
        }')
    
    TOKEN=$(echo "$RESPONSE" | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)
    
    if [ -z "$TOKEN" ]; then
        echo -e "${RED}❌ Login failed${NC}"
        echo "Response: $RESPONSE"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Login successful${NC}"
}

# Create report with file upload
test_file_upload() {
    echo ""
    echo "Testing file upload..."
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/v1/reports" \
        -H "Authorization: Bearer $TOKEN" \
        -F "title=Test Report with Image" \
        -F "description=Testing file upload functionality" \
        -F "category=OTHER" \
        -F "latitude=37.5665" \
        -F "longitude=126.9780" \
        -F "address=Seoul, South Korea" \
        -F "files=@$TEST_IMAGE")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    BODY=$(echo "$RESPONSE" | head -n -1)
    
    if [ "$HTTP_CODE" == "201" ] || [ "$HTTP_CODE" == "200" ]; then
        echo -e "${GREEN}✅ File upload successful${NC}"
        
        # Extract report ID and file URL
        REPORT_ID=$(echo "$BODY" | grep -o '"id":[0-9]*' | cut -d':' -f2)
        FILE_URL=$(echo "$BODY" | grep -o '"fileUrls":\["[^"]*' | cut -d'"' -f4)
        
        echo "   Report ID: $REPORT_ID"
        echo "   File URL: $FILE_URL"
        
        return 0
    else
        echo -e "${RED}❌ File upload failed (HTTP $HTTP_CODE)${NC}"
        echo "Response: $BODY"
        return 1
    fi
}

# Test file download
test_file_download() {
    if [ -z "$FILE_URL" ]; then
        echo "Skipping download test - no file URL"
        return 1
    fi
    
    echo ""
    echo "Testing file download..."
    
    # Extract filename from URL
    FILENAME=$(basename "$FILE_URL")
    
    HTTP_CODE=$(curl -s -o "downloaded-$FILENAME" -w "%{http_code}" \
        -H "Authorization: Bearer $TOKEN" \
        "$BASE_URL$FILE_URL")
    
    if [ "$HTTP_CODE" == "200" ]; then
        echo -e "${GREEN}✅ File download successful${NC}"
        
        # Check file size
        if [ -f "downloaded-$FILENAME" ]; then
            SIZE=$(stat -c%s "downloaded-$FILENAME" 2>/dev/null || stat -f%z "downloaded-$FILENAME" 2>/dev/null)
            echo "   Downloaded file size: $SIZE bytes"
            rm "downloaded-$FILENAME"
        fi
        
        return 0
    else
        echo -e "${RED}❌ File download failed (HTTP $HTTP_CODE)${NC}"
        return 1
    fi
}

# Test file info endpoint
test_file_info() {
    if [ -z "$FILE_URL" ]; then
        echo "Skipping file info test - no file URL"
        return 1
    fi
    
    echo ""
    echo "Testing file info endpoint..."
    
    # Convert /files/ to /files/info/
    INFO_URL=$(echo "$FILE_URL" | sed 's|/files/|/files/info/|')
    
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer $TOKEN" \
        "$BASE_URL$INFO_URL")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    BODY=$(echo "$RESPONSE" | head -n -1)
    
    if [ "$HTTP_CODE" == "200" ]; then
        echo -e "${GREEN}✅ File info retrieved successfully${NC}"
        echo "   Info: $BODY"
        return 0
    else
        echo -e "${RED}❌ File info failed (HTTP $HTTP_CODE)${NC}"
        return 1
    fi
}

# Performance test
test_performance() {
    echo ""
    echo "Testing file upload performance..."
    
    TOTAL_TIME=0
    SUCCESS_COUNT=0
    
    for i in {1..5}; do
        START_TIME=$(date +%s%N)
        
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/v1/reports" \
            -H "Authorization: Bearer $TOKEN" \
            -F "title=Performance Test $i" \
            -F "description=Testing upload performance" \
            -F "category=OTHER" \
            -F "latitude=37.5665" \
            -F "longitude=126.9780" \
            -F "files=@$TEST_IMAGE")
        
        END_TIME=$(date +%s%N)
        ELAPSED=$((($END_TIME - $START_TIME) / 1000000))
        
        if [ "$HTTP_CODE" == "201" ] || [ "$HTTP_CODE" == "200" ]; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            TOTAL_TIME=$((TOTAL_TIME + ELAPSED))
            echo "   Upload $i: ${ELAPSED}ms ✅"
        else
            echo "   Upload $i: Failed ❌"
        fi
    done
    
    if [ $SUCCESS_COUNT -gt 0 ]; then
        AVG_TIME=$((TOTAL_TIME / SUCCESS_COUNT))
        echo -e "${GREEN}✅ Performance test completed${NC}"
        echo "   Success rate: $SUCCESS_COUNT/5"
        echo "   Average time: ${AVG_TIME}ms"
    else
        echo -e "${RED}❌ All uploads failed${NC}"
    fi
}

# Main test execution
main() {
    echo "Target API: $BASE_URL"
    echo ""
    
    # Create test image
    create_test_image
    
    # Run tests
    login
    
    if test_file_upload; then
        test_file_download
        test_file_info
    fi
    
    test_performance
    
    # Cleanup
    rm -f "$TEST_IMAGE"
    
    echo ""
    echo "🏁 File operation tests completed!"
}

# Run main function
main
