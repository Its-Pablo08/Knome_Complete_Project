import os
import re
from bs4 import BeautifulSoup

source_dir = "c:/Users/26050052/pra 2"
dest_dir = "c:/Users/26050052/pra 2/frontend/src/pages"

os.makedirs(dest_dir, exist_ok=True)

# List of pages to convert
pages = {
    "community.html": "Communities",
    "jobs.html": "Jobs",
    "video.html": "Videos",
    "prodcast.html": "Podcasts",
    "article.html": "Articles",
    "article view.html": "ArticleView",
    "hr analytics.html": "HRAnalytics",
    "admin console.html": "AdminConsole",
    "profile.html": "Profile",
    "search.html": "Search",
    "karma history.html": "KarmaHistory",
}

def style_replacer(match):
    style_str = match.group(1)
    if "transform" in style_str and "translateY" in style_str:
        return 'style={{transform: "translateY(0px)", transition: "transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)"}}'
    elif "font-variation-settings" in style_str:
        return 'style={{fontVariationSettings: "\\\'FILL\\\' 1"}}'
    elif "display: none;" in style_str:
        return 'style={{display: "none"}}'
    elif "width" in style_str:
        # e.g., width: 75% -> style={{width: "75%"}}
        parts = style_str.split(";")
        obj = []
        for p in parts:
            if not p.strip(): continue
            k, v = p.split(":")
            # Convert kebab-case to camelCase
            k = re.sub(r'-([a-z])', lambda m: m.group(1).upper(), k.strip())
            obj.append(f'{k}: "{v.strip()}"')
        return 'style={{' + ', '.join(obj) + '}}'
    return 'style={{}}'

def html_to_jsx(html):
    jsx = html.replace('class=', 'className=')
    jsx = re.sub(r'(<img[^>]*?)(?<!/)>', r'\1 />', jsx)
    jsx = re.sub(r'(<input[^>]*?)(?<!/)>', r'\1 />', jsx)
    jsx = re.sub(r'(<hr[^>]*?)(?<!/)>', r'\1 />', jsx)
    jsx = re.sub(r'(<br[^>]*?)(?<!/)>', r'\1 />', jsx)
    
    # Event handlers
    jsx = jsx.replace('onclick=', 'onClick=')
    jsx = jsx.replace('onchange=', 'onChange=')
    jsx = jsx.replace('onsubmit=', 'onSubmit=')
    jsx = jsx.replace('onkeypress=', 'onKeyDown=')
    
    # Strip dangerous inline handlers
    jsx = re.sub(r'onClick="window\.location\.href=[^"]*"', '', jsx)
    jsx = re.sub(r'onKeyDown="[^"]*"', '', jsx)
    jsx = jsx.replace('onClick="toggleTheme()"', 'onClick={toggleTheme}')
    
    # Styles
    jsx = re.sub(r'style="([^"]*)"', style_replacer, jsx)
    
    # Links
    jsx = re.sub(r'href="([^"]*)\.html"', r'href="/\1"', jsx)
    jsx = jsx.replace('href="/dashborad"', 'href="/"')
    
    # Comments
    jsx = re.sub(r'<!--(.*?)-->', r'{/* \1 */}', jsx)
    
    return jsx

routes = []
imports = []

for filename, component_name in pages.items():
    filepath = os.path.join(source_dir, filename)
    if not os.path.exists(filepath):
        print(f"Skipping {filename}, not found.")
        continue
        
    with open(filepath, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f, 'html.parser')
        
    main = soup.find('main')
    right_rail = None
    
    if main:
        # Check if there is an <aside> after <main> (right rail)
        next_sibling = main.find_next_sibling()
        while next_sibling:
            if next_sibling.name == 'aside':
                right_rail = next_sibling
                break
            next_sibling = next_sibling.find_next_sibling()
            
    content = ""
    if main:
        content += str(main)
    if right_rail:
        content += str(right_rail)
        
    if not content:
        print(f"Could not find <main> in {filename}")
        continue
        
    jsx_content = html_to_jsx(content)
    
    route_path = f"/{filename.replace('.html', '').replace(' ', '%20')}"
    imports.append(f"import {component_name} from './pages/{component_name}';")
    routes.append(f'<Route path="{route_path}" element={{<{component_name} />}} />')
    
    file_out = os.path.join(dest_dir, f"{component_name}.jsx")
    with open(file_out, 'w', encoding='utf-8') as f:
        f.write(f"import React from 'react';\nimport {{ Link }} from 'react-router-dom';\n\nexport default function {component_name}() {{\n    return (\n        <>\n{jsx_content}\n        </>\n    );\n}}\n")
    print(f"Generated {component_name}.jsx")

print("\n--- Route Info for App.jsx ---")
print("\n".join(imports))
print("\n".join(routes))
