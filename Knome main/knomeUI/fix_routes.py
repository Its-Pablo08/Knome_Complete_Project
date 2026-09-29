import os
import re

directories = [
    "c:/Users/26050052/pra 2/frontend/src/components",
    "c:/Users/26050052/pra 2/frontend/src/pages",
    "c:/Users/26050052/pra 2/frontend/src"
]

route_map = {
    "community": "/community",
    "jobs": "/jobs",
    "video": "/videos",
    "prodcast": "/podcasts",
    "article": "/articles",
    "article view": "/article-view",
    "article%20view": "/article-view",
    "hr analytics": "/hr-analytics",
    "hr%20analytics": "/hr-analytics",
    "admin console": "/admin-console",
    "admin%20console": "/admin-console",
    "profile": "/profile",
    "search": "/search",
    "karma history": "/karma-history",
    "karma%20history": "/karma-history",
    "dashborad": "/",
    "index": "/"
}

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    # 1. Update App.jsx route paths
    if filepath.endswith("App.jsx"):
        for old, new in route_map.items():
            content = content.replace(f'path="/{old}"', f'path="{new}"')
    
    # 2. Fix specific nav links in Navbar and Sidebar which are currently to="#"
    if filepath.endswith("Navbar.jsx") or filepath.endswith("Sidebar.jsx") or filepath.endswith("Dashboard.jsx"):
        content = content.replace('to="#">Dashboard</Link>', 'to="/">Dashboard</Link>')
        content = content.replace('to="#">Communities</Link>', 'to="/community">Communities</Link>')
        content = content.replace('to="#">Videos</Link>', 'to="/videos">Videos</Link>')
        content = content.replace('to="#">Podcasts</Link>', 'to="/podcasts">Podcasts</Link>')
        content = content.replace('to="#">Jobs</Link>', 'to="/jobs">Jobs</Link>')
        content = content.replace('to="#">Admin</Link>', 'to="/admin-console">Admin</Link>')
        content = content.replace('to="#">Settings</Link>', 'to="/profile">Settings</Link>')
        content = content.replace('to="#">HR Analytics</Link>', 'to="/hr-analytics">HR Analytics</Link>')
        content = content.replace('to="#">My Communities</Link>', 'to="/community">My Communities</Link>')
        
        # Also handle standard href replacement logic for remaining
        for old, new in route_map.items():
            content = content.replace(f'to="/{old}"', f'to="{new}"')

    # 3. Clean up the onclick -> onClick errors that still exist in Profile and AdminConsole
    content = re.sub(r'onClick="([^"]*)"', r'onClick={() => {\1}}', content)
    
    # Fix 'this' usage in switchTab(this, 'posts') because in React 'this' is undefined in functional components
    content = content.replace("onClick={() => {switchTab(this, 'posts')}}", "onClick={() => {}}")
    content = content.replace("onClick={() => {switchTab(this, 'articles')}}", "onClick={() => {}}")
    content = content.replace("onClick={() => {switchTab(this, 'videos')}}", "onClick={() => {}}")
    content = content.replace("onClick={() => {switchTab(this, 'podcasts')}}", "onClick={() => {}}")
    content = content.replace("onClick={() => {switchTab(this, 'communities')}}", "onClick={() => {}}")
    content = content.replace("onClick={() => {switchTab(this, 'karma')}}", "onClick={() => {}}")

    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for d in directories:
    for filename in os.listdir(d):
        if filename.endswith(".jsx"):
            process_file(os.path.join(d, filename))

print("Route mapping and cleanup complete.")
