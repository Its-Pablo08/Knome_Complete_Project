import os

directory = "c:/Users/26050052/pra 2"

dark_mode_css = """
    <style id="dark-mode-overrides">
        .dark body {
            background-color: #0f172a !important;
            color: #f1f5f9 !important;
        }
        .dark nav, .dark aside, .dark .bg-white, .dark .bg-surface-container-lowest, 
        .dark .bg-surface-container-low, .dark .bg-surface-container, .dark .bg-surface,
        .dark article, .dark .glass-card {
            background-color: #1e293b !important;
            border-color: #334155 !important;
        }
        .dark h1, .dark h2, .dark h3, .dark h4, .dark h5, .dark h6, 
        .dark .text-primary, .dark .text-on-surface, .dark .text-on-secondary-container {
            color: #f8fafc !important;
        }
        .dark p, .dark span, .dark .text-slate-gray, .dark .text-on-surface-variant {
            color: #cbd5e1 !important;
        }
        .dark input, .dark textarea, .dark select {
            background-color: #0f172a !important;
            color: #f1f5f9 !important;
            border-color: #334155 !important;
        }
        .dark .border-border-subtle, .dark .border-outline-variant, .dark .border {
            border-color: #334155 !important;
        }
        .dark .bg-secondary-container {
            background-color: #3b82f6 !important; /* electric blue / active state */
            color: white !important;
        }
        .dark .text-electric-blue {
            color: #60a5fa !important;
        }
        .dark .hover\:bg-surface-container:hover {
            background-color: #334155 !important;
        }
    </style>
"""

def update_files():
    for filename in os.listdir(directory):
        if filename.endswith(".html"):
            filepath = os.path.join(directory, filename)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Remove old style block if it exists (for idempotency)
            if '<style id="dark-mode-overrides">' in content:
                import re
                content = re.sub(r'<style id="dark-mode-overrides">.*?</style>', '', content, flags=re.DOTALL)
            
            # Add the new style block right before </head>
            content = content.replace("</head>", dark_mode_css + "\n</head>")

            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Added dark mode CSS to {filename}")

if __name__ == "__main__":
    update_files()
