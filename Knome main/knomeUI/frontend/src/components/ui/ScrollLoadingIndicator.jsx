import React from 'react';

/**
 * Reusable animated scroll loading indicator displayed at bottom of feeds/catalogs.
 */
export default function ScrollLoadingIndicator({ isVisible, text = 'Loading more on scroll...' }) {
    if (!isVisible) return null;

    return (
        <div className="col-span-full w-full py-6 text-center flex items-center justify-center gap-2 text-slate-400 dark:text-slate-500 text-xs font-semibold animate-in fade-in duration-200">
            <span className="material-symbols-outlined text-[20px] animate-spin text-indigo-500 dark:text-indigo-400">
                progress_activity
            </span>
            <span>{text}</span>
        </div>
    );
}
