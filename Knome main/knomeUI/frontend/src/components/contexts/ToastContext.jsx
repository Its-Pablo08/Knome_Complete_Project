import React, { createContext, useContext, useState, useCallback, useRef } from 'react';

const ToastContext = createContext();

const ICONS = {
    success: { icon: 'check_circle', color: '#10b981', bg: 'rgba(16,185,129,0.12)', border: 'rgba(16,185,129,0.25)' },
    error: { icon: 'cancel', color: '#ef4444', bg: 'rgba(239,68,68,0.12)', border: 'rgba(239,68,68,0.25)' },
    warning: { icon: 'warning', color: '#f59e0b', bg: 'rgba(245,158,11,0.12)', border: 'rgba(245,158,11,0.25)' },
    info: { icon: 'info', color: '#6366f1', bg: 'rgba(99,102,241,0.12)', border: 'rgba(99,102,241,0.25)' },
};

export function ToastProvider({ children }) {
    const [toasts, setToasts] = useState([]);
    const idRef = useRef(0);

    const addToast = useCallback((message, type = 'info', duration = 4000) => {
        const id = ++idRef.current;
        setToasts(prev => [...prev, { id, message, type }]);
        setTimeout(() => {
            setToasts(prev => prev.filter(t => t.id !== id));
        }, duration);
    }, []);

    const removeToast = useCallback((id) => {
        setToasts(prev => prev.filter(t => t.id !== id));
    }, []);

    return (
        <ToastContext.Provider value={{ addToast }}>
            {children}
            {/* Toast Container */}
            <div className="fixed bottom-6 right-6 z-[200] flex flex-col gap-2.5 pointer-events-none">
                {toasts.map(toast => {
                    const style = ICONS[toast.type] || ICONS.info;
                    return (
                        <div
                            key={toast.id}
                            className="pointer-events-auto flex items-center gap-3 px-4 py-3 rounded-2xl shadow-2xl min-w-[280px] max-w-[380px]"
                            style={{
                                background: 'var(--bg-card)',
                                border: `1px solid ${style.border}`,
                                boxShadow: `0 8px 32px rgba(0,0,0,0.15), 0 0 0 1px ${style.border}`,
                                animation: 'slideInRight 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
                            }}>
                            <div className="w-8 h-8 rounded-xl flex items-center justify-center shrink-0"
                                style={{ background: style.bg }}>
                                <span className="material-symbols-outlined text-[18px]"
                                    style={{ color: style.color, fontVariationSettings: "'FILL' 1" }}>
                                    {style.icon}
                                </span>
                            </div>
                            <p className="flex-1 text-[13px] font-semibold leading-snug"
                                style={{ color: 'var(--text-primary)' }}>
                                {toast.message}
                            </p>
                            <button
                                onClick={() => removeToast(toast.id)}
                                className="shrink-0 text-[16px] transition-opacity hover:opacity-70"
                                style={{ color: 'var(--text-muted)' }}>
                                <span className="material-symbols-outlined text-[16px]">close</span>
                            </button>
                        </div>
                    );
                })}
            </div>

            <style>{`
                @keyframes slideInRight {
                    from { opacity: 0; transform: translateX(24px) scale(0.95); }
                    to   { opacity: 1; transform: translateX(0) scale(1); }
                }
            `}</style>
        </ToastContext.Provider>
    );
}

export const useToast = () => {
    const ctx = useContext(ToastContext);
    if (!ctx) throw new Error('useToast must be used within ToastProvider');
    return ctx;
};
