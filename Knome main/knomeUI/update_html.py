import os
import re

directory = "c:/Users/26050052/pra 2"

screen_map = {
    "SCREEN_31": "dashborad.html",
    "SCREEN_28": "community.html",
    "SCREEN_23": "video.html",
    "SCREEN_29": "prodcast.html",
    "SCREEN_24": "jobs.html",
    "SCREEN_20": "admin console.html",
    "SCREEN_21": "profile.html",
    "SCREEN_32": "search.html",
    "SCREEN_33": "hr analytics.html",
    "SCREEN_34": "karma history.html",
    "SCREEN_35": "article.html",
    "SCREEN_36": "article view.html"
}

dark_mode_head_script = """
    <script>
        // Apply theme immediately to prevent FOUC
        if (localStorage.getItem('theme') === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
            document.documentElement.classList.add('dark');
            document.documentElement.classList.remove('light');
        } else {
            document.documentElement.classList.remove('dark');
            document.documentElement.classList.add('light');
        }
    </script>
"""

dark_mode_body_script = """
    <script>
        function toggleTheme() {
            if (document.documentElement.classList.contains('dark')) {
                document.documentElement.classList.remove('dark');
                document.documentElement.classList.add('light');
                localStorage.setItem('theme', 'light');
            } else {
                document.documentElement.classList.add('dark');
                document.documentElement.classList.remove('light');
                localStorage.setItem('theme', 'dark');
            }
        }
    </script>
"""

toggle_button_html = """
                <button onclick="toggleTheme()" class="p-2 text-slate-gray hover:bg-surface-container hover:text-electric-blue rounded-full transition-all flex items-center justify-center">
                    <span class="material-symbols-outlined dark:hidden">dark_mode</span>
                    <span class="material-symbols-outlined hidden dark:block">light_mode</span>
                </button>
"""

def update_files():
    for filename in os.listdir(directory):
        if filename.endswith(".html"):
            filepath = os.path.join(directory, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 1. Replace screen placeholders
            for screen_id, target_file in screen_map.items():
                content = content.replace(f"{{{{DATA:SCREEN:{screen_id}}}}}", target_file)
                # Some might be URL encoded or missing curly braces, but based on grep, it's exact.
            
            # If still has SCREEN_, replace with "#" to avoid broken links
            content = re.sub(r'\{\{DATA:SCREEN:SCREEN_\d+\}\}', '#', content)
            
            # 2. Add head script
            if "toggleTheme()" not in content:
                # Add head script before </head>
                content = content.replace("</head>", dark_mode_head_script + "</head>")
                
                # Add body script before </body>
                content = content.replace("</body>", dark_mode_body_script + "\n</body>")
                
                # 3. Inject toggle button before notifications
                # Pattern to match the notifications button
                notif_pattern = re.compile(r'(<button[^>]*>[\s\n]*<span[^>]*>notifications</span>[\s\n]*</button>)')
                # For safety, make sure we only inject once
                if notif_pattern.search(content):
                    content = notif_pattern.sub(toggle_button_html + r'\1', content, count=1)

            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated {filename}")

if __name__ == "__main__":
    update_files()
