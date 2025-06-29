#!/usr/bin/env python3
"""
End-to-End Integration Test for Roboflow AI Analysis
====================================================

This script tests the complete integration flow:
1. Python → Spring Boot Backend → Roboflow API → Backend → Flutter

Usage:
    python integration_test.py [--backend-url http://localhost:8080]

Requirements:
    - Spring Boot backend running
    - Valid Roboflow API configuration
    - Test images available
"""

import os
import sys
import json
import time
import requests
import argparse
from pathlib import Path
from typing import Dict, Any, List
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class IntegrationTester:
    """End-to-end integration tester for Roboflow AI system"""
    
    def __init__(self, backend_url: str = "http://localhost:8000"):
        self.backend_url = backend_url.rstrip('/')
        self.api_base = f"{self.backend_url}/api/v1/ai"
        
    def test_backend_health(self) -> bool:
        """Test if backend server is running"""
        try:
            response = requests.get(f"{self.api_base}/health", timeout=10)
            
            if response.status_code == 200:
                logger.info("✅ Backend health check passed")
                return True
            else:
                logger.error(f"❌ Backend health check failed: {response.status_code}")
                return False
                
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Backend connection failed: {e}")
            return False
    
    def test_roboflow_config(self) -> bool:
        """Test Roboflow configuration status"""
        try:
            response = requests.get(f"{self.api_base}/config", timeout=10)
            
            if response.status_code == 200:
                config = response.json()
                logger.info("📋 Roboflow Configuration Status:")
                for key, value in config.items():
                    logger.info(f"   {key}: {value}")
                
                return config.get('ready', False)
            else:
                logger.error(f"❌ Config check failed: {response.status_code}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Config check error: {e}")
            return False
    
    def test_supported_classes(self) -> bool:
        """Test supported AI classes endpoint"""
        try:
            response = requests.get(f"{self.api_base}/classes", timeout=10)
            
            if response.status_code == 200:
                classes = response.json()
                logger.info("🏷️ Supported AI Classes:")
                
                if isinstance(classes, list):
                    for cls in classes[:5]:  # Show first 5
                        logger.info(f"   {cls.get('english', 'N/A')} → {cls.get('korean', 'N/A')}")
                    
                    if len(classes) > 5:
                        logger.info(f"   ... and {len(classes) - 5} more classes")
                    
                    return True
                else:
                    logger.warning("⚠️ Unexpected classes response format")
                    return False
            else:
                logger.error(f"❌ Classes endpoint failed: {response.status_code}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Classes endpoint error: {e}")
            return False
    
    def test_image_analysis(self, image_path: str) -> Dict[str, Any]:
        """Test single image analysis"""
        try:
            if not os.path.exists(image_path):
                logger.error(f"❌ Test image not found: {image_path}")
                return {"success": False, "error": "Image file not found"}
            
            logger.info(f"🖼️ Testing image analysis: {image_path}")
            
            with open(image_path, 'rb') as img_file:
                files = {'image': img_file}
                data = {
                    'confidence': 50,
                    'overlap': 30
                }
                
                files = {'file': img_file}
                data = {'category': 'test_category'} # 임시 카테고리
                
                start_time = time.time()
                response = requests.post(
                    f"{self.backend_url}/api/v2/detect",
                    files=files,
                    data=data,
                    timeout=60
                )
                
                processing_time = (time.time() - start_time) * 1000
                
            if response.status_code == 202: # Accepted
                result = response.json()
                request_id = result.get("request_id")
                logger.info(f"✅ Image analysis request accepted. Request ID: {request_id}")
                logger.info(f"   Processing time: {processing_time:.2f}ms")
                return {"success": True, "result": result}
                
            else:
                logger.error(f"❌ Image analysis failed: {response.status_code}")
                logger.error(f"   Response: {response.text}")
                return {"success": False, "error": response.text}
                
        except Exception as e:
            logger.error(f"❌ Image analysis error: {e}")
            return {"success": False, "error": str(e)}
    
    def test_batch_analysis(self, image_paths: List[str]) -> Dict[str, Any]:
        """Test batch image analysis"""
        try:
            if not image_paths:
                logger.warning("⚠️ No images provided for batch test")
                return {"success": False, "error": "No images provided"}
            
            # Filter existing files
            valid_paths = [p for p in image_paths if os.path.exists(p)]
            if not valid_paths:
                logger.error("❌ No valid image files found for batch test")
                return {"success": False, "error": "No valid images found"}
            
            logger.info(f"📦 Testing batch analysis: {len(valid_paths)} images")
            
            # Prepare files
            files = []
            for i, path in enumerate(valid_paths[:5]):  # Limit to 5 images
                files.append(('images', open(path, 'rb')))
            
            try:
                data = {
                    'confidence': 50,
                    'overlap': 30
                }
                
                start_time = time.time()
                response = requests.post(
                    f"{self.api_base}/analyze-batch",
                    files=files,
                    data=data,
                    timeout=120
                )
                
                processing_time = (time.time() - start_time) * 1000
                
            finally:
                # Close all file handles
                for _, file_handle in files:
                    file_handle.close()
            
            if response.status_code == 200:
                results = response.json()
                
                logger.info("✅ Batch analysis successful:")
                logger.info(f"   Processing time: {processing_time:.2f}ms")
                logger.info(f"   Total results: {len(results) if isinstance(results, list) else 'N/A'}")
                
                if isinstance(results, list):
                    successful = sum(1 for r in results if r.get('success', False))
                    logger.info(f"   Successful analyses: {successful}/{len(results)}")
                
                return {"success": True, "results": results}
                
            else:
                logger.error(f"❌ Batch analysis failed: {response.status_code}")
                return {"success": False, "error": response.text}
                
        except Exception as e:
            logger.error(f"❌ Batch analysis error: {e}")
            return {"success": False, "error": str(e)}
    
    def test_async_analysis(self, image_path: str) -> Dict[str, Any]:
        """Test asynchronous image analysis"""
        try:
            if not os.path.exists(image_path):
                logger.error(f"❌ Test image not found: {image_path}")
                return {"success": False, "error": "Image file not found"}
            
            logger.info(f"⏱️ Testing async analysis: {image_path}")
            
            with open(image_path, 'rb') as img_file:
                files = {'image': img_file}
                data = {
                    'confidence': 50,
                    'overlap': 30
                }
                
                # Start async analysis
                response = requests.post(
                    f"{self.api_base}/analyze-async",
                    files=files,
                    data=data,
                    timeout=30
                )
            
            if response.status_code in [200, 202]:  # Success or Accepted
                job_id = response.text.strip('"')
                logger.info(f"🔄 Async job started: {job_id}")
                
                # Poll for results
                max_attempts = 30
                for attempt in range(max_attempts):
                    time.sleep(2)  # Wait 2 seconds
                    
                    status_response = requests.get(
                        f"{self.api_base}/status/{job_id}",
                        timeout=10
                    )
                    
                    if status_response.status_code == 200:
                        result = status_response.json()
                        logger.info(f"✅ Async analysis completed (attempt {attempt + 1})")
                        logger.info(f"   Success: {result.get('success', False)}")
                        logger.info(f"   Detections: {len(result.get('detections', []))}")
                        
                        return {"success": True, "result": result, "job_id": job_id}
                    
                    elif status_response.status_code == 404:
                        logger.info(f"⏳ Job still processing (attempt {attempt + 1})")
                        continue
                    
                    else:
                        logger.error(f"❌ Status check failed: {status_response.status_code}")
                        break
                
                logger.error("❌ Async analysis timed out")
                return {"success": False, "error": "Analysis timed out"}
                
            else:
                logger.error(f"❌ Async analysis start failed: {response.status_code}")
                return {"success": False, "error": response.text}
                
        except Exception as e:
            logger.error(f"❌ Async analysis error: {e}")
            return {"success": False, "error": str(e)}
    
    def find_test_images(self) -> List[str]:
        """Find available test images"""
        test_dirs = [
            "test_images",
            "samples",
            "images",
            ".",
        ]
        
        image_extensions = {".jpg", ".jpeg", ".png", ".bmp"}
        found_images = []
        
        for test_dir in test_dirs:
            if os.path.exists(test_dir):
                for file_path in Path(test_dir).rglob("*"):
                    if file_path.is_file() and file_path.suffix.lower() in image_extensions:
                        found_images.append(str(file_path))
        
        return found_images[:10]  # Limit to 10 images
    
    def run_comprehensive_test(self) -> Dict[str, bool]:
        """Run all integration tests"""
        logger.info("🚀 Starting comprehensive integration test")
        logger.info("=" * 60)
        
        results = {}
        
        # Test 1: Backend health
        results['backend_health'] = self.test_backend_health()
        
        # Test 2: Roboflow configuration
        results['roboflow_config'] = self.test_roboflow_config()
        
        # Test 3: Supported classes
        results['supported_classes'] = self.test_supported_classes()
        
        # Find test images
        test_images = self.find_test_images()
        if not test_images:
            logger.warning("⚠️ No test images found - skipping image analysis tests")
            results['image_analysis'] = False
            results['batch_analysis'] = False
            results['async_analysis'] = False
        else:
            logger.info(f"📁 Found {len(test_images)} test images")
            
            # Test 4: Single image analysis
            if test_images:
                single_result = self.test_image_analysis(test_images[0])
                results['image_analysis'] = single_result['success']
            
            # Test 5: Batch analysis
            if len(test_images) > 1:
                batch_result = self.test_batch_analysis(test_images[:3])
                results['batch_analysis'] = batch_result['success']
            else:
                results['batch_analysis'] = False
            
            # Test 6: Async analysis
            if test_images:
                async_result = self.test_async_analysis(test_images[0])
                results['async_analysis'] = async_result['success']
        
        # Summary
        logger.info("=" * 60)
        logger.info("📊 Integration Test Summary:")
        
        total_tests = len(results)
        passed_tests = sum(1 for success in results.values() if success)
        
        for test_name, success in results.items():
            status = "✅ PASSED" if success else "❌ FAILED"
            logger.info(f"   {test_name}: {status}")
        
        logger.info(f"\nOverall: {passed_tests}/{total_tests} tests passed")
        
        if passed_tests == total_tests:
            logger.info("🎉 All integration tests passed!")
        else:
            logger.warning(f"⚠️ {total_tests - passed_tests} tests failed")
        
        return results

def main():
    parser = argparse.ArgumentParser(description="Roboflow Integration Test")
    parser.add_argument(
        '--backend-url',
        default='http://localhost:8000',
        help='Backend server URL (default: http://localhost:8000)'
    )
    parser.add_argument(
        '--quick',
        action='store_true',
        help='Run quick tests only (skip image analysis)'
    )
    
    args = parser.parse_args()
    
    tester = IntegrationTester(args.backend_url)
    
    if args.quick:
        # Quick tests only
        logger.info("🏃 Running quick integration tests")
        results = {
            'backend_health': tester.test_backend_health(),
            'roboflow_config': tester.test_roboflow_config(),
            'supported_classes': tester.test_supported_classes()
        }
        
        passed = sum(1 for success in results.values() if success)
        total = len(results)
        
        logger.info(f"Quick test results: {passed}/{total} passed")
    else:
        # Full comprehensive test
        results = tester.run_comprehensive_test()
    
    # Exit with appropriate code
    all_passed = all(results.values())
    sys.exit(0 if all_passed else 1)

if __name__ == "__main__":
    main()
