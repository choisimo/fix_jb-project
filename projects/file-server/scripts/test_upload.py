#!/usr/bin/env python3
"""
Simple test script to demonstrate uploading files to the file server.
"""

import argparse
import json
import os
import requests
from pathlib import Path


def upload_file(file_path, server_url, api_key=None):
    """Upload a file to the file server"""
    url = f"{server_url}/upload/"
    
    headers = {}
    if api_key:
        headers["X-Auth-Token"] = api_key
    
    with open(file_path, "rb") as f:
        files = {"file": (os.path.basename(file_path), f)}
        params = {"analyze": "true"}  # Set to "true" to request AI analysis
        
        print(f"Uploading {file_path} to {url}...")
        response = requests.post(url, files=files, params=params, headers=headers)
        
    try:
        response.raise_for_status()
        result = response.json()
        print(f"Upload successful!\nFile ID: {result['file_id']}")
        print(f"File URL: {result['file_url']}")
        if result.get("thumbnail_url"):
            print(f"Thumbnail URL: {result['thumbnail_url']}")
        if result.get("analysis_task_id"):
            print(f"Analysis Task ID: {result['analysis_task_id']}")
            print(f"Check analysis status at: {server_url}/status/{result['analysis_task_id']}")
        return result
    except Exception as e:
        print(f"Upload failed: {e}")
        print(response.text)
        return None


def main():
    parser = argparse.ArgumentParser(description="Test file upload to JB-Project File Server")
    parser.add_argument("file", help="File to upload")
    parser.add_argument("--server", default="http://localhost:12020", help="Server URL")
    parser.add_argument("--key", default=None, help="API key")
    
    args = parser.parse_args()
    
    if not os.path.isfile(args.file):
        print(f"Error: File {args.file} not found")
        return 1
    
    upload_file(args.file, args.server, args.key)
    return 0


if __name__ == "__main__":
    exit(main())
