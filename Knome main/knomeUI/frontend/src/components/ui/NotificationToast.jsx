import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { formatNotificationDate } from '../../utils/notificationHelpers';

export default function NotificationToast({ notification, onClose }) {
    const navigate = useNavigate();

    useEffect(() => {
        const timer = setTimeout(() => {
            onClose();
        }, 6000);
        return () => clearTimeout(timer);
    }, [onClose]);

    if (!notification) return null;

    const handleToastClick = () => {
        onClose();
        if (notification.targetUrl) {
            navigate(notification.targetUrl);
        } else if (notification.type?.includes('follow') && notification.senderUserId) {
            navigate(`/profile?id=${notification.senderUserId}`);
        } else {
            navigate('/posts');
        }
    };

    return (
        <div className="fixed top-20 right-6 z-50 max-w-sm w-full bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl shadow-2xl p-4 flex items-start gap-3 animate-in fade-in slide-in-from-top-5 duration-300 backdrop-blur-xl">
            {/* Sender Avatar */}
            <div className="w-10 h-10 rounded-full overflow-hidden shrink-0 border border-slate-200 dark:border-slate-700 bg-indigo-100 dark:bg-indigo-900 flex items-center justify-center text-indigo-600 dark:text-indigo-300 font-bold">
                {notification.senderAvatar ? (
                    <img src={notification.senderAvatar} alt="Sender" className="w-full h-full object-cover" />
                ) : (
                    <span>{(notification.senderName || notification.title || 'N').charAt(0)}</span>
                )}
            </div>

            {/* Notification Details */}
            <div className="flex-1 min-w-0 cursor-pointer" onClick={handleToastClick}>
                <div className="flex items-center justify-between gap-2 mb-1">
                    <h4 className="text-xs font-black text-slate-900 dark:text-white truncate">
                        {notification.title || 'New Notification'}
                    </h4>
                    <span className="text-[10px] font-bold text-indigo-500 bg-indigo-50 dark:bg-indigo-900/30 px-2 py-0.5 rounded-full whitespace-nowrap">
                        {formatNotificationDate(notification.createdDate || notification.createdAt || notification.time)}
                    </span>
                </div>
                <p className="text-xs text-slate-600 dark:text-slate-300 line-clamp-2 leading-snug">
                    {notification.senderName ? (
                        <>
                            <span className="font-bold text-slate-900 dark:text-white">{notification.senderName} </span>
                            <span>{notification.message?.replace(new RegExp(`^${notification.senderName}\\s*`, 'i'), '') || notification.text}</span>
                        </>
                    ) : (
                        notification.message || notification.text
                    )}
                </p>
            </div>

            {/* Close Button */}
            <button
                onClick={(e) => {
                    e.stopPropagation();
                    onClose();
                }}
                className="text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 text-sm p-1 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
            >
                <span className="material-symbols-outlined text-[18px]">close</span>
            </button>
        </div>
    );
}
