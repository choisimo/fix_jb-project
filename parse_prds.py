import re
import os
from pathlib import Path

def parse_prd_file(file_path):
    """Parse a PRD file and extract structured content"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Remove line numbers and pipe characters
    content = re.sub(r'^\s*\d+\s+\|\s*', '', content, flags=re.MULTILINE)
    
    sections = {
        'title': '',
        'overview': '',
        'goals': [],
        'features': [],
        'tech_stack': '',
        'scenarios': []
    }
    
    # Extract title (first non-empty line)
    if match := re.search(r'^[#\s]*(.*?)\n', content):
        sections['title'] = match.group(1).strip()
    
    # Extract overview (text after title before first section)
    if match := re.search(r'(?s)(?<=\.\n\n)(.*?)(?=\n\d+\.)', content):
        sections['overview'] = match.group(1).strip()
    
    # Extract goals - with improved error handling
    goals_section = re.search(r'목표.*?\n(.*?)(?=\n\d+\.)', content, re.DOTALL | re.IGNORECASE)
    if goals_section:
        goals_text = goals_section.group(1)
        if matches := re.findall(r'\*\s*(.*?)\n', goals_text):
            sections['goals'] = [m.strip() for m in matches]
    
    # Extract features with error handling
    feature_section = re.search(r'기능 요구사항.*?\n(.*?)(?=\n\d+\.)', content, re.DOTALL | re.IGNORECASE)
    if feature_section:
        features = re.findall(r'\d+\.\d+\..*?(?=\n\d+\.\d+\.|\Z)', feature_section.group(1), re.DOTALL)
        sections['features'] = [f.strip() for f in features]
    
    # Extract technical stack with error handling
    if match := re.search(r'기술 스택.*?\n(.*?)(?=\n\d+\.)', content, re.DOTALL | re.IGNORECASE):
        sections['tech_stack'] = match.group(1).strip()
    
    # Extract user scenarios with error handling
    if matches := re.findall(r'시나리오 \d+:.*?(?=\n\*|$)', content, re.DOTALL | re.IGNORECASE):
        sections['scenarios'] = [m.strip() for m in matches]
    
    return sections

def generate_markdown_report(prd_data):
    """Generate Markdown report from parsed PRD data"""
    report = "# PRD Summary Report\n\n"
    toc = []
    
    for i, prd in enumerate(prd_data, 1):
        # Add to table of contents
        toc.append(f"{i}. [{prd['title']}](#{prd['title'].replace(' ', '-').lower()})")
        
        # PRD header
        report += f"## {i}. {prd['title']}\n\n"
        report += f"**Overview**\n{prd['overview']}\n\n"
        
        # Goals
        if prd['goals']:
            report += "**Goals**\n"
            for goal in prd['goals']:
                report += f"- {goal}\n"
            report += "\n"
        
        # Features
        if prd['features']:
            report += "**Key Features**\n"
            for feature in prd['features']:
                # Clean up feature text
                feature = re.sub(r'\n\s*', ' ', feature)
                report += f"- {feature}\n"
            report += "\n"
        
        # Technical Stack
        if prd['tech_stack']:
            report += "**Technical Stack**\n"
            report += f"{prd['tech_stack']}\n\n"
        
        # Scenarios
        if prd['scenarios']:
            report += "**User Scenarios**\n"
            for scenario in prd['scenarios']:
                # Clean up scenario text
                scenario = re.sub(r'\n\s*', ' ', scenario)
                report += f"- {scenario}\n"
            report += "\n"
        
        report += "---\n\n"
    
    # Add table of contents at beginning
    if toc:
        toc_section = "## Table of Contents\n" + "\n".join(toc) + "\n\n"
        report = report.replace("# PRD Summary Report\n\n", "# PRD Summary Report\n\n" + toc_section)
    
    return report

def main():
    script_dir = Path("scripts")
    prd_files = [
        "PRD.txt",
        "ai-agent-prd.txt",
        "ai-agent-router.txt",
        "alert-prd.txt"
    ]
    
    prd_data = []
    for file_name in prd_files:
        file_path = script_dir / file_name
        if file_path.exists():
            prd_data.append(parse_prd_file(file_path))
    
    report = generate_markdown_report(prd_data)
    
    with open("prd_summary_report.md", "w", encoding="utf-8") as f:
        f.write(report)
    
    print("Generated PRD summary report: prd_summary_report.md")

if __name__ == "__main__":
    main()