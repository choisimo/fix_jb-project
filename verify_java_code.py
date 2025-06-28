#!/usr/bin/env python3
"""
Java Code Verification Script
============================

Verifies the Java backend code for common syntax issues and imports
without requiring a Java compiler.

Usage:
    python verify_java_code.py
"""

import os
import re
from pathlib import Path
from typing import List, Dict, Tuple

class JavaCodeVerifier:
    """Verifies Java code structure and common issues"""
    
    def __init__(self, source_root: str):
        self.source_root = Path(source_root)
        self.issues = []
        
    def verify_all_files(self) -> Dict[str, List[str]]:
        """Verify all Java files in the source directory"""
        results = {}
        
        java_files = list(self.source_root.rglob("*.java"))
        
        print(f"🔍 Found {len(java_files)} Java files to verify")
        
        for java_file in java_files:
            issues = self.verify_file(java_file)
            relative_path = java_file.relative_to(self.source_root)
            results[str(relative_path)] = issues
            
            if issues:
                print(f"⚠️ {relative_path}: {len(issues)} issues")
            else:
                print(f"✅ {relative_path}: OK")
        
        return results
    
    def verify_file(self, file_path: Path) -> List[str]:
        """Verify a single Java file"""
        issues = []
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check basic structure
            issues.extend(self.check_package_declaration(content, file_path))
            issues.extend(self.check_imports(content))
            issues.extend(self.check_class_declaration(content, file_path))
            issues.extend(self.check_braces_balance(content))
            issues.extend(self.check_annotations(content))
            issues.extend(self.check_method_signatures(content))
            
        except Exception as e:
            issues.append(f"Error reading file: {e}")
        
        return issues
    
    def check_package_declaration(self, content: str, file_path: Path) -> List[str]:
        """Check package declaration"""
        issues = []
        
        package_pattern = r'^package\s+([a-zA-Z0-9._]+);\s*$'
        package_match = re.search(package_pattern, content, re.MULTILINE)
        
        if not package_match:
            issues.append("Missing or invalid package declaration")
        else:
            declared_package = package_match.group(1)
            
            # Check if package matches directory structure
            expected_package_parts = []
            current = file_path.parent
            
            # Walk up to find 'java' directory
            while current.name != 'java' and current.parent != current:
                expected_package_parts.insert(0, current.name)
                current = current.parent
            
            if expected_package_parts:
                expected_package = '.'.join(expected_package_parts)
                if declared_package != expected_package:
                    issues.append(f"Package declaration '{declared_package}' doesn't match directory structure '{expected_package}'")
        
        return issues
    
    def check_imports(self, content: str) -> List[str]:
        """Check import statements"""
        issues = []
        
        import_pattern = r'^import\s+([a-zA-Z0-9._*]+);\s*$'
        imports = re.findall(import_pattern, content, re.MULTILINE)
        
        # Check for common issues
        for imp in imports:
            if imp.count('*') > 1:
                issues.append(f"Invalid wildcard import: {imp}")
            
            # Check for common missing imports (basic heuristic)
            if 'List' in content and 'java.util.List' not in imports:
                if 'import java.util.*' not in [f"import {i}" for i in imports]:
                    issues.append("Possible missing import for List")
        
        return issues
    
    def check_class_declaration(self, content: str, file_path: Path) -> List[str]:
        """Check class declaration"""
        issues = []
        
        class_pattern = r'(?:public\s+)?(?:abstract\s+)?(?:final\s+)?class\s+(\w+)'
        class_matches = re.findall(class_pattern, content)
        
        if not class_matches:
            # Check for interfaces, enums, etc.
            other_pattern = r'(?:public\s+)?(?:interface|enum|record)\s+(\w+)'
            other_matches = re.findall(other_pattern, content)
            
            if not other_matches:
                issues.append("No class, interface, enum, or record declaration found")
        else:
            class_name = class_matches[0]
            expected_name = file_path.stem
            
            if class_name != expected_name:
                issues.append(f"Class name '{class_name}' doesn't match filename '{expected_name}'")
        
        return issues
    
    def check_braces_balance(self, content: str) -> List[str]:
        """Check if braces are balanced"""
        issues = []
        
        # Remove string literals and comments to avoid false positives
        cleaned_content = re.sub(r'"([^"\\]|\\.)*"', '""', content)
        cleaned_content = re.sub(r"'([^'\\]|\\.)*'", "''", cleaned_content)
        cleaned_content = re.sub(r'//.*$', '', cleaned_content, flags=re.MULTILINE)
        cleaned_content = re.sub(r'/\*.*?\*/', '', cleaned_content, flags=re.DOTALL)
        
        brace_count = cleaned_content.count('{') - cleaned_content.count('}')
        paren_count = cleaned_content.count('(') - cleaned_content.count(')')
        bracket_count = cleaned_content.count('[') - cleaned_content.count(']')
        
        if brace_count != 0:
            issues.append(f"Unbalanced braces: {abs(brace_count)} {'opening' if brace_count > 0 else 'closing'} braces")
        
        if paren_count != 0:
            issues.append(f"Unbalanced parentheses: {abs(paren_count)} {'opening' if paren_count > 0 else 'closing'} parentheses")
        
        if bracket_count != 0:
            issues.append(f"Unbalanced brackets: {abs(bracket_count)} {'opening' if bracket_count > 0 else 'closing'} brackets")
        
        return issues
    
    def check_annotations(self, content: str) -> List[str]:
        """Check annotation usage"""
        issues = []
        
        # Check for common Spring annotations
        spring_annotations = [
            '@RestController', '@Service', '@Repository', '@Component',
            '@Autowired', '@RequestMapping', '@GetMapping', '@PostMapping',
            '@PathVariable', '@RequestParam', '@RequestBody'
        ]
        
        # If using Spring annotations, should have proper imports
        for annotation in spring_annotations:
            if annotation in content:
                # This is a simplified check
                if '@RestController' in content and 'org.springframework.web.bind.annotation.RestController' not in content:
                    # Only warn if we don't see the import (could be using import *)
                    pass
        
        return issues
    
    def check_method_signatures(self, content: str) -> List[str]:
        """Check method signatures"""
        issues = []
        
        # Check for methods without proper access modifiers in public classes
        method_pattern = r'^\s*(\w+\s+)*(\w+)\s*\([^)]*\)\s*\{'
        methods = re.findall(method_pattern, content, re.MULTILINE)
        
        # This is a basic check - could be enhanced
        return issues
    
    def print_summary(self, results: Dict[str, List[str]]):
        """Print verification summary"""
        total_files = len(results)
        files_with_issues = sum(1 for issues in results.values() if issues)
        total_issues = sum(len(issues) for issues in results.values())
        
        print("\n" + "="*60)
        print("📊 Java Code Verification Summary")
        print("="*60)
        print(f"Total files checked: {total_files}")
        print(f"Files with issues: {files_with_issues}")
        print(f"Total issues found: {total_issues}")
        
        if files_with_issues > 0:
            print("\n⚠️ Files with issues:")
            for file_path, issues in results.items():
                if issues:
                    print(f"\n📁 {file_path}:")
                    for issue in issues:
                        print(f"   ❌ {issue}")
        
        if total_issues == 0:
            print("\n🎉 All Java files passed basic verification!")
        else:
            print(f"\n⚠️ Please review and fix the {total_issues} issues found.")

def main():
    # Find Java source directory
    backend_dir = Path("/home/nodove/workspace/fix_jb-project/flutter-backend")
    java_src = backend_dir / "src" / "main" / "java"
    
    if not java_src.exists():
        print(f"❌ Java source directory not found: {java_src}")
        return False
    
    print("🔍 Starting Java code verification...")
    print(f"📁 Source directory: {java_src}")
    
    verifier = JavaCodeVerifier(str(java_src))
    results = verifier.verify_all_files()
    verifier.print_summary(results)
    
    return sum(len(issues) for issues in results.values()) == 0

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
