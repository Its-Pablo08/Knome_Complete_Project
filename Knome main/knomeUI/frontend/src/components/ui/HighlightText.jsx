import React from 'react';

/**
 * HighlightText component
 * Highlights all occurrences of query tokens within text in real-time during search.
 * Uses a vibrant, accessible highlight badge with subtle rounded edges and smooth contrast.
 */
export default function HighlightText({ text, query, className = '' }) {
    if (text === null || text === undefined) return null;
    const strText = String(text);
    if (!query || typeof query !== 'string' || !query.trim()) {
        return <span className={className}>{strText}</span>;
    }

    // Split query by whitespace, ignoring empty tokens
    const rawTokens = query.trim().split(/\s+/).filter(t => t.length > 0);
    if (rawTokens.length === 0) {
        return <span className={className}>{strText}</span>;
    }

    // Also support hashtag queries: if searching "#dotnet", also match "dotnet", and vice versa
    const tokenSet = new Set();
    rawTokens.forEach(t => {
        tokenSet.add(t);
        if (t.startsWith('#') && t.length > 1) {
            tokenSet.add(t.substring(1));
        }
    });

    const tokens = Array.from(tokenSet);
    // Escape regex special characters
    const escaped = tokens.map(t => t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
    const pattern = new RegExp(`(${escaped.join('|')})`, 'gi');
    const parts = strText.split(pattern);

    return (
        <span className={className}>
            {parts.map((part, i) => {
                const isMatch = tokens.some(t => t.toLowerCase() === part.toLowerCase());
                return isMatch ? (
                    <mark
                        key={i}
                        className="bg-amber-300 dark:bg-amber-400 text-slate-950 px-1 py-0.5 rounded-[4px] font-bold shadow-xs inline-block leading-tight select-text"
                        style={{
                            backgroundColor: '#fde047',
                            color: '#0f172a',
                            boxShadow: '0 1px 2px rgba(0,0,0,0.1)'
                        }}
                    >
                        {part}
                    </mark>
                ) : (
                    <span key={i}>{part}</span>
                );
            })}
        </span>
    );
}
