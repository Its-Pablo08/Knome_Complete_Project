import os
import re

source_html = "c:/Users/26050052/pra 2/dashborad.html"
dest_dir = "c:/Users/26050052/pra 2/frontend/src"

def extract_section(content, start_marker, end_marker):
    start = content.find(start_marker)
    if start == -1: return ""
    end = content.find(end_marker, start)
    if end == -1: return ""
    return content[start:end]

def html_to_jsx(html):
    # Convert class to className
    jsx = html.replace('class=', 'className=')
    # Close img and input tags properly
    jsx = re.sub(r'(<img[^>]*?)(?<!/)>', r'\1 />', jsx)
    jsx = re.sub(r'(<input[^>]*?)(?<!/)>', r'\1 />', jsx)
    # Fix onclick to onClick
    jsx = jsx.replace('onclick=', 'onClick=')
    # Remove script tags or other non-JSX friendly inline event handlers
    jsx = re.sub(r'onClick="window\.location\.href=\'[^\']*\'"', '', jsx)
    jsx = jsx.replace('onclick="toggleTheme()"', 'onClick={toggleTheme}')
    # Fix style attribute syntax
    # e.g., style="font-variation-settings: 'FILL' 1;" -> style={{fontVariationSettings: "'FILL' 1"}}
    # e.g., style="transform: translateY(0px); transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);"
    def style_replacer(match):
        style_str = match.group(1)
        # simplistic conversion for known styles
        if "transform" in style_str and "translateY" in style_str:
            return 'style={{transform: "translateY(0px)", transition: "transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)"}}'
        elif "font-variation-settings" in style_str:
            return 'style={{fontVariationSettings: "\\\'FILL\\\' 1"}}'
        elif "display: none;" in style_str:
            return 'style={{display: "none"}}'
        return 'style={{}}'
        
    jsx = re.sub(r'style="([^"]*)"', style_replacer, jsx)
    # Fix hrefs to use React Router Link later, but for now just leave as # or /
    jsx = re.sub(r'href="[^"]*\.html"', 'href="#"', jsx)
    # fix html comments to jsx comments
    jsx = re.sub(r'<!--(.*?)-->', r'{/* \1 */}', jsx)
    
    return jsx

with open(source_html, 'r', encoding='utf-8') as f:
    content = f.read()

navbar_html = extract_section(content, '<!-- TopNavBar -->', '<!-- SideNavBar -->')
# Stop navbar before the container div wrapper
navbar_html = navbar_html[:navbar_html.rfind('<div class="max-w-container-max')]

sidebar_html = extract_section(content, '<!-- SideNavBar -->', '<!-- Main Feed -->')
main_html = extract_section(content, '<!-- Main Feed -->', '<!-- Right Rail Widgets -->')
rail_html = extract_section(content, '<!-- Right Rail Widgets -->', '<!-- Footer -->')

os.makedirs(os.path.join(dest_dir, 'components'), exist_ok=True)
os.makedirs(os.path.join(dest_dir, 'pages'), exist_ok=True)

# Generate Navbar.jsx
navbar_jsx = html_to_jsx(navbar_html)
with open(os.path.join(dest_dir, 'components', 'Navbar.jsx'), 'w', encoding='utf-8') as f:
    f.write(f'''import React, {{ useEffect, useState }} from 'react';
import {{ Link }} from 'react-router-dom';

export default function Navbar() {{
    const [isDark, setIsDark] = useState(false);

    useEffect(() => {{
        setIsDark(document.documentElement.classList.contains('dark'));
    }}, []);

    const toggleTheme = () => {{
        if (isDark) {{
            document.documentElement.classList.remove('dark');
            document.documentElement.classList.add('light');
            localStorage.setItem('theme', 'light');
            setIsDark(false);
        }} else {{
            document.documentElement.classList.add('dark');
            document.documentElement.classList.remove('light');
            localStorage.setItem('theme', 'dark');
            setIsDark(true);
        }}
    }};

    return (
        <>
        {navbar_jsx}
        </>
    );
}}
''')

# Generate Sidebar.jsx
sidebar_jsx = html_to_jsx(sidebar_html)
with open(os.path.join(dest_dir, 'components', 'Sidebar.jsx'), 'w', encoding='utf-8') as f:
    f.write(f'''import React from 'react';
import {{ Link }} from 'react-router-dom';

export default function Sidebar() {{
    return (
        <>
        {sidebar_jsx}
        </>
    );
}}
''')

# Generate Layout.jsx
with open(os.path.join(dest_dir, 'components', 'Layout.jsx'), 'w', encoding='utf-8') as f:
    f.write('''import React from 'react';
import Navbar from './Navbar';
import Sidebar from './Sidebar';

export default function Layout({ children }) {
    return (
        <div className="min-h-screen bg-background text-on-surface">
            <Navbar />
            <div className="max-w-container-max mx-auto px-margin-page pt-24 pb-stack-lg flex gap-gutter">
                <Sidebar />
                <div className="flex-1 flex gap-stack-lg min-w-0">
                    {children}
                </div>
            </div>
        </div>
    );
}
''')

# Generate Dashboard.jsx
dashboard_jsx = html_to_jsx(main_html)
right_rail_jsx = html_to_jsx(rail_html)
with open(os.path.join(dest_dir, 'pages', 'Dashboard.jsx'), 'w', encoding='utf-8') as f:
    f.write(f'''import React from 'react';

export default function Dashboard() {{
    return (
        <>
            {dashboard_jsx}
            {right_rail_jsx}
        </>
    );
}}
''')

print("JSX Components generated successfully.")
