import json
import re
import os

# Clean the raw tasks.json content
raw_content = """   1 | {
   2 |   "master": {
   3 |     "tasks": [
   4 |       {
   5 |         "id": 1,
   6 |         "title": "Setup Project Infrastructure and Core Services",
...
1943 | }
"""

# Remove line numbers and pipes
cleaned_lines = []
for line in raw_content.split('\n'):
    # Remove leading digits, spaces, and pipe
    clean_line = re.sub(r'^\s*\d+\s*\|\s*', '', line)
    cleaned_lines.append(clean_line)
    
cleaned_json = '\n'.join(cleaned_lines)

# Parse JSON
tasks_data = json.loads(cleaned_json)

# Create issues directory
os.makedirs("issues", exist_ok=True)

# Process each context
for context, data in tasks_data.items():
    context_dir = f"issues/{context}"
    os.makedirs(context_dir, exist_ok=True)
    
    for task in data.get('tasks', []):
        task_id = task['id']
        filename = f"{context_dir}/task_{task_id}.md"
        
        # Build markdown content
        content = f"# [{context}] Task ID: {task_id} - {task['title']}\n\n"
        content += f"**Description**:\n{task['description']}\n\n"
        content += f"**Details**:\n{task.get('details', '')}\n\n"
        content += f"**Test Strategy**:\n{task.get('testStrategy', '')}\n\n"
        content += f"**Priority**: {task.get('priority', '')}\n"
        content += f"**Dependencies**: {', '.join(map(str, task.get('dependencies', [])))}\n"
        content += f"**Status**: {task.get('status', '')}\n"
        
        if 'completedAt' in task:
            content += f"**Completed At**: {task['completedAt']}\n"
            
        if 'notes' in task:
            content += f"**Notes**: {task['notes']}\n"
            
        # Handle subtasks
        subtasks = task.get('subtasks', [])
        if subtasks:
            content += "\n**Subtasks**:\n"
            for st in subtasks:
                content += f"- [{st.get('status', 'pending')}] {st.get('title', '')}: {st.get('description', '')}\n"
        else:
            content += "\n**Subtasks**: None\n"
            
        # Write to file
        with open(filename, 'w') as f:
            f.write(content)
            
print(f"Generated {sum(len(data['tasks']) for data in tasks_data.values())} issue files in issues/")