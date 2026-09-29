import os
import re

admin_file = "c:/Users/26050052/pra 2/frontend/src/pages/AdminConsole.jsx"
with open(admin_file, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add useState
if "useState" not in content:
    content = content.replace("import React", "import React, { useState }")

# 2. Add state variable
content = content.replace("export default function AdminConsole() {", "export default function AdminConsole() {\n    const [activeTab, setActiveTab] = useState('users');")

# 3. Update tabs to use state
tabs_html = """
<div className="flex border-b border-border-subtle mb-stack-lg overflow-x-auto whitespace-nowrap scrollbar-hide">
<button onClick={() => setActiveTab('users')} className={`px-6 py-4 border-b-2 font-bold font-label-md text-label-md transition-all ${activeTab === 'users' ? 'border-electric-blue text-electric-blue' : 'border-transparent text-slate-gray hover:text-electric-blue'}`}>Users &amp; Roles</button>
<button onClick={() => setActiveTab('config')} className={`px-6 py-4 border-b-2 font-bold font-label-md text-label-md transition-all ${activeTab === 'config' ? 'border-electric-blue text-electric-blue' : 'border-transparent text-slate-gray hover:text-electric-blue'}`}>System Config</button>
<button onClick={() => setActiveTab('moderation')} className={`px-6 py-4 border-b-2 font-bold font-label-md text-label-md transition-all ${activeTab === 'moderation' ? 'border-electric-blue text-electric-blue' : 'border-transparent text-slate-gray hover:text-electric-blue'}`}>Moderation Queue</button>
</div>
"""

# Replace the existing tabs block (using regex to find it)
content = re.sub(r'<div className="flex border-b border-border-subtle mb-stack-lg overflow-x-auto whitespace-nowrap scrollbar-hide">.*?</div>', tabs_html, content, flags=re.DOTALL)

# 4. Conditionally render tables based on activeTab
user_table_regex = r'(<section className="bg-white border border-border-subtle rounded-xl shadow-sm overflow-hidden">.*?</div>\s*</section>)'
user_table_match = re.search(user_table_regex, content, flags=re.DOTALL)

if user_table_match:
    user_section = user_table_match.group(1)
    
    moderation_section = """
    <section className="bg-white border border-border-subtle rounded-xl shadow-sm overflow-hidden">
        <div className="p-stack-md border-b border-border-subtle bg-surface-container-lowest flex items-center justify-between">
            <h3 className="font-headline-sm text-headline-sm text-primary-container">Content Moderation Queue</h3>
            <span className="bg-error/10 text-error px-2 py-1 rounded-lg text-xs font-bold">12 Pending Reports</span>
        </div>
        <div className="overflow-x-auto custom-scrollbar">
            <table className="w-full text-left border-collapse">
                <thead className="bg-surface-container text-slate-gray font-label-md text-label-md uppercase tracking-wider">
                    <tr>
                        <th className="px-6 py-4">Content Type</th>
                        <th className="px-6 py-4">Reported By</th>
                        <th className="px-6 py-4">Reason</th>
                        <th className="px-6 py-4 text-right">Actions (FR-SM-03)</th>
                    </tr>
                </thead>
                <tbody className="divide-y divide-border-subtle text-body-md font-body-md">
                    <tr className="hover:bg-slate-50 transition-colors">
                        <td className="px-6 py-4">
                            <span className="font-semibold text-primary">Post</span> (Engineering Group)
                            <p className="text-xs text-slate-gray mt-1 truncate w-48">"Check out this amazing new diet pill..."</p>
                        </td>
                        <td className="px-6 py-4 text-slate-gray">Dave Peterson</td>
                        <td className="px-6 py-4"><span className="text-error font-semibold">Spam/Marketing</span></td>
                        <td className="px-6 py-4 text-right space-x-2">
                            <button className="text-slate-gray hover:text-primary font-label-md">Ignore</button>
                            <button className="text-error hover:underline font-label-md">Remove</button>
                            <button className="text-electric-blue hover:underline font-label-md">Block User</button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </section>
    """
    
    conditional_render = f"""
    {{activeTab === 'users' && (
        {user_section}
    )}}
    {{activeTab === 'moderation' && (
        {moderation_section}
    )}}
    """
    content = content.replace(user_section, conditional_render)

with open(admin_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("AdminConsole updated.")

# Update Search.jsx
search_file = "c:/Users/26050052/pra 2/frontend/src/pages/Search.jsx"
with open(search_file, 'r', encoding='utf-8') as f:
    search_content = f.read()

filters_html = """
<div className="flex gap-4 mb-6 overflow-x-auto pb-2">
    <select className="bg-white border border-border-subtle rounded-lg px-4 py-2 text-body-md text-slate-gray outline-none">
        <option>Date Range: Any Time</option>
        <option>Past 24 Hours</option>
        <option>Past Week</option>
        <option>Past Month</option>
    </select>
    <select className="bg-white border border-border-subtle rounded-lg px-4 py-2 text-body-md text-slate-gray outline-none">
        <option>Category: All</option>
        <option>Engineering</option>
        <option>HR</option>
        <option>Design</option>
    </select>
    <select className="bg-white border border-border-subtle rounded-lg px-4 py-2 text-body-md text-slate-gray outline-none">
        <option>Sort By: Relevance</option>
        <option>Most Viewed</option>
        <option>Most Liked</option>
        <option>Newest</option>
    </select>
</div>
"""

# Insert filters just before the results grid/list in Search.jsx
search_content = search_content.replace('<h2 className="font-headline-sm', filters_html + '\n<h2 className="font-headline-sm')

with open(search_file, 'w', encoding='utf-8') as f:
    f.write(search_content)

print("Search updated.")
