import os
import re

directories = [
    "c:/Users/26050052/pra 2/frontend/src/components",
    "c:/Users/26050052/pra 2/frontend/src/pages"
]

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # If it's not a React component, skip
    if not filepath.endswith('.jsx'):
        return

    # Check if we need to add import { Link }
    if '<a ' in content and 'import { Link }' not in content:
        # Add import after React import
        content = re.sub(r"(import React.*?;\n)", r"\1import { Link } from 'react-router-dom';\n", content)

    # Replace <a ... href="..."> with <Link ... to="...">
    # Handle both single quotes and double quotes for href, and spaces.
    content = re.sub(r'<a\s+([^>]*?)href=([\'"])(.*?)\2([^>]*?)>', r'<Link \1to="\3"\4>', content)
    content = content.replace('</a>', '</Link>')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Processed {filepath}")

for d in directories:
    for filename in os.listdir(d):
        if filename.endswith(".jsx"):
            process_file(os.path.join(d, filename))

print("Link replacement completed.")
