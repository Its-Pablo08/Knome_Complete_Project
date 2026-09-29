import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Modal from './Modal';
import { interactionsApi, resolveMediaUrl } from '../../utils/apiService';

const REACTION_META = {
    all: { icon: '👥', label: 'All' },
    like: { icon: '👍', label: 'Like', color: 'text-blue-500', bg: 'bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400 border-blue-200 dark:border-blue-800' },
    celebrate: { icon: '🎉', label: 'Celebrate', color: 'text-amber-500', bg: 'bg-amber-50 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400 border-amber-200 dark:border-amber-800' },
    support: { icon: '🤝', label: 'Support', color: 'text-purple-500', bg: 'bg-purple-50 dark:bg-purple-950/40 text-purple-600 dark:text-purple-400 border-purple-200 dark:border-purple-800' },
    heart: { icon: '❤️', label: 'Heart', color: 'text-rose-500', bg: 'bg-rose-50 dark:bg-rose-950/40 text-rose-600 dark:text-rose-400 border-rose-200 dark:border-rose-800' }
};

export default function ReactionsModal({ isOpen, onClose, contentType = 'Post', contentId, initialReactions = [] }) {
    const navigate = useNavigate();
    const [reactions, setReactions] = useState(initialReactions || []);
    const [loading, setLoading] = useState(false);
    const [activeTab, setActiveTab] = useState('all');

    useEffect(() => {
        if (!isOpen || !contentId) return;

        let isMounted = true;
        setLoading(true);

        // Fetch fresh reactions list from backend
        interactionsApi.getReactionsList(contentType, contentId)
            .then(res => {
                if (!isMounted) return;
                const list = Array.isArray(res) ? res : (res?.data || []);
                if (list.length > 0) {
                    setReactions(list);
                } else if (initialReactions && initialReactions.length > 0) {
                    setReactions(initialReactions);
                } else {
                    setReactions([]);
                }
            })
            .catch(err => {
                console.warn('Could not load detailed reactions list, using summary fallback', err);
                if (isMounted) {
                    interactionsApi.getReactions(contentType, contentId)
                        .then(sumRes => {
                            if (!isMounted) return;
                            const sumData = sumRes?.data || sumRes;
                            if (sumData?.reactions && sumData.reactions.length > 0) {
                                setReactions(sumData.reactions);
                            } else if (initialReactions && initialReactions.length > 0) {
                                setReactions(initialReactions);
                            }
                        })
                        .catch(() => {
                            if (initialReactions && initialReactions.length > 0) {
                                setReactions(initialReactions);
                            }
                        });
                }
            })
            .finally(() => {
                if (isMounted) setLoading(false);
            });

        return () => {
            isMounted = false;
        };
    }, [isOpen, contentType, contentId]);

    if (!isOpen) return null;

    // Normalizing reaction items
    const normalized = reactions.map(r => ({
        id: r.reactionId || r.id || `${r.userId}-${r.reactionType}`,
        userId: r.userId,
        userName: r.userFullName || r.userName || r.authorFullName || 'Colleague',
        userDesignation: r.userDesignation || r.designation || r.department || 'MPOnline Team Member',
        avatar: resolveMediaUrl(r.userProfilePhotoUrl || r.avatar || r.profilePhotoUrl),
        reactionType: (r.reactionType || 'Like').toLowerCase()
    }));

    // Filter counts per type
    const counts = {
        all: normalized.length,
        like: normalized.filter(r => r.reactionType === 'like').length,
        celebrate: normalized.filter(r => r.reactionType === 'celebrate').length,
        support: normalized.filter(r => r.reactionType === 'support').length,
        heart: normalized.filter(r => r.reactionType === 'heart').length
    };

    const filteredReactions = activeTab === 'all'
        ? normalized
        : normalized.filter(r => r.reactionType === activeTab);

    const handleUserClick = (item) => {
        onClose();
        navigate('/profile', {
            state: {
                user: {
                    id: item.userId,
                    userId: item.userId,
                    fullName: item.userName,
                    designation: item.userDesignation,
                    profilePhotoUrl: item.avatar
                }
            }
        });
    };

    return (
        <Modal isOpen={isOpen} onClose={onClose} title="Reactions" maxWidth="max-w-md">
            <div className="flex flex-col gap-4">
                {/* Reaction Filter Tabs */}
                <div className="flex items-center gap-1.5 border-b border-slate-200 dark:border-slate-800 pb-2 overflow-x-auto custom-scrollbar shrink-0">
                    <button
                        onClick={() => setActiveTab('all')}
                        className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold transition-all whitespace-nowrap cursor-pointer ${
                            activeTab === 'all'
                                ? 'bg-primary text-white shadow-xs'
                                : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800'
                        }`}
                    >
                        <span>All</span>
                        <span className={`px-1.5 py-0.5 rounded-full text-[10px] ${activeTab === 'all' ? 'bg-white/20 text-white' : 'bg-slate-100 dark:bg-slate-800 text-slate-500'}`}>
                            {counts.all}
                        </span>
                    </button>

                    {['like', 'celebrate', 'support', 'heart'].map(type => {
                        const typeCount = counts[type];
                        if (typeCount === 0) return null;
                        const meta = REACTION_META[type];
                        const isActive = activeTab === type;
                        return (
                            <button
                                key={type}
                                onClick={() => setActiveTab(type)}
                                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold transition-all whitespace-nowrap cursor-pointer ${
                                    isActive
                                        ? 'bg-primary text-white shadow-xs'
                                        : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800'
                                }`}
                            >
                                <span className="text-sm">{meta.icon}</span>
                                <span>{meta.label}</span>
                                <span className={`px-1.5 py-0.5 rounded-full text-[10px] ${isActive ? 'bg-white/20 text-white' : 'bg-slate-100 dark:bg-slate-800 text-slate-500'}`}>
                                    {typeCount}
                                </span>
                            </button>
                        );
                    })}
                </div>

                {/* User List */}
                <div className="flex flex-col divide-y divide-slate-100 dark:divide-slate-800 max-h-[360px] overflow-y-auto pr-1 custom-scrollbar">
                    {loading && normalized.length === 0 ? (
                        <div className="py-8 flex flex-col items-center justify-center gap-2 text-slate-400">
                            <span className="material-symbols-outlined animate-spin text-2xl text-primary">progress_activity</span>
                            <span className="text-xs">Loading reactions...</span>
                        </div>
                    ) : filteredReactions.length === 0 ? (
                        <div className="py-8 flex flex-col items-center justify-center gap-2 text-slate-400">
                            <span className="material-symbols-outlined text-3xl">sentiment_dissatisfied</span>
                            <span className="text-xs">No reactions found</span>
                        </div>
                    ) : (
                        filteredReactions.map(item => {
                            const meta = REACTION_META[item.reactionType] || REACTION_META.like;
                            const initials = item.userName
                                .split(' ')
                                .filter(Boolean)
                                .map(n => n[0])
                                .slice(0, 2)
                                .join('')
                                .toUpperCase() || 'U';

                            return (
                                <div
                                    key={item.id}
                                    className="py-3 flex items-center justify-between gap-3 hover:bg-slate-50/70 dark:hover:bg-slate-800/40 px-2 rounded-xl transition-colors"
                                >
                                    {/* User Info */}
                                    <div
                                        onClick={() => handleUserClick(item)}
                                        className="flex items-center gap-3 min-w-0 flex-1 cursor-pointer group"
                                    >
                                        <div className="relative shrink-0">
                                            {item.avatar ? (
                                                <img
                                                    src={item.avatar}
                                                    alt={item.userName}
                                                    className="w-11 h-11 rounded-full object-cover border border-slate-200 dark:border-slate-700 group-hover:ring-2 group-hover:ring-primary/40 transition-all"
                                                    onError={(e) => {
                                                        e.target.onerror = null;
                                                        e.target.src = `https://ui-avatars.com/api/?name=${encodeURIComponent(item.userName)}&background=6366f1&color=fff`;
                                                    }}
                                                />
                                            ) : (
                                                <div className="w-11 h-11 rounded-full bg-gradient-to-tr from-primary to-indigo-500 text-white flex items-center justify-center font-bold text-sm shadow-xs group-hover:ring-2 group-hover:ring-primary/40 transition-all">
                                                    {initials}
                                                </div>
                                            )}
                                            {/* Reaction Badge overlay */}
                                            <span
                                                className="absolute -bottom-1 -right-1 w-5 h-5 rounded-full bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 flex items-center justify-center text-xs shadow-xs"
                                                title={meta.label}
                                            >
                                                {meta.icon}
                                            </span>
                                        </div>

                                        <div className="flex flex-col min-w-0 flex-1">
                                            <span className="text-sm font-bold text-slate-800 dark:text-slate-100 truncate group-hover:text-primary transition-colors">
                                                {item.userName}
                                            </span>
                                            <span className="text-xs text-slate-500 dark:text-slate-400 truncate">
                                                {item.userDesignation}
                                            </span>
                                        </div>
                                    </div>

                                    {/* Reaction Chip */}
                                    <div className="shrink-0 flex items-center">
                                        <span
                                            className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold border ${meta.bg}`}
                                        >
                                            <span className="text-xs">{meta.icon}</span>
                                            <span>{meta.label}</span>
                                        </span>
                                    </div>
                                </div>
                            );
                        })
                    )}
                </div>
            </div>
        </Modal>
    );
}
