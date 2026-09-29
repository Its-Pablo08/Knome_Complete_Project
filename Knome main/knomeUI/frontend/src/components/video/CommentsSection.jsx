import React, { useState, useRef, useEffect, useCallback } from 'react';
import { resolveMediaUrl } from '../../utils/apiService';
import { checkRestrictedContent } from '../../utils/restrictedWords';
import { useToast } from '../contexts/ToastContext';

// ── Helpers ──────────────────────────────────────────────────────────────────

function formatRelTime(ts) {
    if (!ts) return 'Just now';
    const diff = Date.now() - new Date(ts).getTime();
    const s = Math.floor(diff / 1000);
    if (s < 60) return 'Just now';
    const m = Math.floor(s / 60); if (m < 60) return `${m} minute${m !== 1 ? 's' : ''} ago`;
    const h = Math.floor(m / 60); if (h < 24) return `${h} hour${h !== 1 ? 's' : ''} ago`;
    const d = Math.floor(h / 24); if (d < 7) return `${d} day${d !== 1 ? 's' : ''} ago`;
    const w = Math.floor(d / 7); if (w < 4) return `${w} week${w !== 1 ? 's' : ''} ago`;
    const mo = Math.floor(d / 30); if (mo < 12) return `${mo} month${mo !== 1 ? 's' : ''} ago`;
    return `${Math.floor(mo / 12)} year${Math.floor(mo / 12) !== 1 ? 's' : ''} ago`;
}

function Avatar({ name, avatar, size = 9 }) {
    const colors = [
        'from-cyan-500 to-blue-600', 'from-purple-500 to-pink-600',
        'from-orange-400 to-red-500', 'from-emerald-400 to-teal-600',
        'from-amber-400 to-yellow-500', 'from-rose-500 to-pink-600',
    ];
    const colorIdx = (name || '').charCodeAt(0) % colors.length;
    const sz = `w-${size} h-${size}`;
    return (
        <div className={`${sz} rounded-full bg-gradient-to-br ${colors[colorIdx]} flex items-center justify-center text-white font-black text-xs shrink-0 overflow-hidden shadow-sm`}>
            {avatar
                ? <img src={resolveMediaUrl(avatar)} alt={name} className="w-full h-full object-cover" />
                : (name || '?').charAt(0).toUpperCase()
            }
        </div>
    );
}

function CommentInput({ currentUser, placeholder = 'Add a comment...', onSubmit, onCancel, autoFocus = false, initialValue = '' }) {
    const { addToast } = useToast();
    const [value, setValue] = useState(initialValue);
    const [focused, setFocused] = useState(autoFocus);
    const ref = useRef(null);

    useEffect(() => { if (autoFocus && ref.current) ref.current.focus(); }, [autoFocus]);

    const handleSubmit = () => {
        if (!value.trim()) return;
        const foundKeyword = checkRestrictedContent(value.trim());
        if (foundKeyword) {
            addToast(`Security Alert: Please don't use this restricted or abusive word - "${foundKeyword}".`, 'warning');
            return;
        }
        onSubmit(value.trim());
        setValue('');
        setFocused(false);
    };

    const handleKeyDown = (e) => {
        if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) handleSubmit();
        if (e.key === 'Escape') { setValue(''); setFocused(false); onCancel?.(); }
    };

    return (
        <div className="flex gap-3 items-start">
            <Avatar name={currentUser?.name} avatar={currentUser?.avatar} size={9} />
            <div className="flex-1">
                <div className={`border-b-2 transition-colors ${focused ? 'border-slate-800 dark:border-slate-200' : 'border-slate-200 dark:border-slate-700'}`}>
                    <input
                        ref={ref}
                        type="text"
                        placeholder={placeholder}
                        value={value}
                        onChange={e => { setValue(e.target.value); if (!focused) setFocused(true); }}
                        onFocus={() => setFocused(true)}
                        onKeyDown={handleKeyDown}
                        className="w-full bg-transparent outline-none text-sm text-slate-900 dark:text-white placeholder-slate-400 dark:placeholder-slate-500 py-1"
                    />
                </div>
                {focused && (
                    <div className="flex justify-end items-center gap-2 mt-3">
                        {(() => {
                            const restrictedWord = checkRestrictedContent(value);
                            if (restrictedWord) {
                                return (
                                    <div className="flex items-center gap-1.5 text-rose-500 text-xs font-semibold px-3 py-1.5 bg-rose-50 dark:bg-rose-950/40 border border-rose-200 dark:border-rose-900/50 rounded-lg">
                                        <span className="material-symbols-outlined text-[15px]">warning</span>
                                        <span>Restricted word ("{restrictedWord}") detected! Remove it to post.</span>
                                    </div>
                                );
                            }
                            return (
                                <button
                                    onClick={handleSubmit}
                                    disabled={!value.trim()}
                                    className="px-4 py-1.5 rounded-full text-sm font-bold bg-cyan-600 disabled:bg-slate-200 dark:disabled:bg-slate-800 disabled:text-slate-400 dark:disabled:text-slate-600 disabled:cursor-not-allowed text-white hover:bg-cyan-700 transition-all cursor-pointer"
                                >
                                    {initialValue ? 'Save' : 'Comment'}
                                </button>
                            );
                        })()}
                        <button
                            onClick={() => { setValue(''); setFocused(false); onCancel?.(); }}
                            className="px-4 py-1.5 rounded-full text-sm font-bold text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-all cursor-pointer"
                        >
                            Cancel
                        </button>
                    </div>
                )}
            </div>
        </div>
    );
}

// ── Single Comment ────────────────────────────────────────────────────────────

function renderCommentText(text) {
    if (!text) return '';
    const parts = text.split(/(@[\w\s]+?)(?=\s|$|[.,!?])/g);
    return parts.map((part, i) => {
        if (part.startsWith('@')) {
            return <span key={i} className="font-bold text-cyan-600 dark:text-cyan-400 mr-0.5">{part}</span>;
        }
        return part;
    });
}

function Comment({ comment, currentUser, videoId, onUpdateComment, onDeleteComment, onAddChildReply, depth = 0 }) {
    const [showReplies, setShowReplies] = useState(false);
    const [showReplyInput, setShowReplyInput] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [showMenu, setShowMenu] = useState(false);
    const menuRef = useRef(null);
    const isOwn = String(comment.authorId) === String(currentUser?.id || currentUser?.userId);

    // Close menu on outside click
    useEffect(() => {
        const fn = (e) => { if (menuRef.current && !menuRef.current.contains(e.target)) setShowMenu(false); };
        document.addEventListener('mousedown', fn);
        return () => document.removeEventListener('mousedown', fn);
    }, []);

    const handleLike = () => {
        const wasLiked = comment.likedByMe;
        const wasDisliked = comment.dislikedByMe;
        onUpdateComment(comment.id, {
            likes: wasLiked ? comment.likes - 1 : comment.likes + 1,
            dislikes: wasDisliked ? comment.dislikes - 1 : comment.dislikes,
            likedByMe: !wasLiked,
            dislikedByMe: false,
        });
    };

    const handleDislike = () => {
        const wasDisliked = comment.dislikedByMe;
        const wasLiked = comment.likedByMe;
        onUpdateComment(comment.id, {
            dislikes: wasDisliked ? comment.dislikes - 1 : comment.dislikes + 1,
            likes: wasLiked ? comment.likes - 1 : comment.likes,
            dislikedByMe: !wasDisliked,
            likedByMe: false,
        });
    };

    const handleReplySubmit = (text) => {
        const reply = {
            id: `reply_${Date.now()}_${Math.random()}`,
            text,
            author: currentUser?.name || 'You',
            authorId: currentUser?.id || currentUser?.userId,
            avatar: currentUser?.avatar || null,
            createdAt: new Date().toISOString(),
            likes: 0,
            dislikes: 0,
            likedByMe: false,
            dislikedByMe: false,
            replies: [],
        };
        if (onAddChildReply) {
            onAddChildReply(reply);
        } else {
            onUpdateComment(comment.id, {
                replies: [...(comment.replies || []), reply],
            });
        }
        setShowReplyInput(false);
        setShowReplies(true);
    };

    const handleEditSave = (text) => {
        onUpdateComment(comment.id, { text, edited: true });
        setIsEditing(false);
    };

    return (
        <div className={`flex gap-3 ${depth > 0 ? '' : ''}`}>
            <Avatar name={comment.author} avatar={comment.avatar} size={depth > 0 ? 8 : 9} />
            <div className="flex-1 min-w-0">
                {/* Header */}
                <div className="flex items-center gap-2 mb-1">
                    <span className="text-[13px] font-bold text-slate-800 dark:text-slate-200">{comment.author}</span>
                    <span className="text-[11px] text-slate-400 dark:text-slate-500">{formatRelTime(comment.createdAt)}</span>
                    {comment.edited && <span className="text-[11px] text-slate-400 italic">(edited)</span>}
                </div>

                {/* Body */}
                {isEditing ? (
                    <CommentInput
                        currentUser={currentUser}
                        placeholder="Edit your comment..."
                        onSubmit={handleEditSave}
                        onCancel={() => setIsEditing(false)}
                        autoFocus
                        initialValue={comment.text}
                    />
                ) : (
                    <p className="text-sm text-slate-700 dark:text-slate-300 break-words leading-relaxed">{renderCommentText(comment.text)}</p>
                )}

                {/* Actions */}
                {!isEditing && (
                    <div className="flex items-center gap-1 mt-2">
                        {/* Like */}
                        <button
                            onClick={handleLike}
                            className={`flex items-center gap-1 px-2 py-1 rounded-full text-[12px] font-semibold transition-all cursor-pointer ${comment.likedByMe ? 'text-cyan-600 dark:text-cyan-400 bg-cyan-50 dark:bg-cyan-900/30' : 'text-slate-500 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'}`}
                        >
                            <span className="material-symbols-outlined text-[16px]" style={{ fontVariationSettings: comment.likedByMe ? "'FILL' 1" : "'FILL' 0" }}>thumb_up</span>
                            {comment.likes > 0 && <span>{comment.likes}</span>}
                        </button>

                        {/* Dislike */}
                        <button
                            onClick={handleDislike}
                            className={`flex items-center gap-1 px-2 py-1 rounded-full text-[12px] font-semibold transition-all cursor-pointer ${comment.dislikedByMe ? 'text-rose-500 bg-rose-50 dark:bg-rose-900/20' : 'text-slate-500 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'}`}
                        >
                            <span className="material-symbols-outlined text-[16px]" style={{ fontVariationSettings: comment.dislikedByMe ? "'FILL' 1" : "'FILL' 0" }}>thumb_down</span>
                        </button>

                        {/* Reply button — available on all comments and replies */}
                        <button
                            onClick={() => setShowReplyInput(p => !p)}
                            className="px-3 py-1 rounded-full text-[12px] font-bold text-slate-500 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 transition-all cursor-pointer"
                        >
                            Reply
                        </button>

                        {/* 3-dot menu for own comments */}
                        {isOwn && (
                            <div className="relative ml-1" ref={menuRef}>
                                <button
                                    onClick={() => setShowMenu(p => !p)}
                                    className="w-7 h-7 rounded-full flex items-center justify-center text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 transition-all cursor-pointer"
                                >
                                    <span className="material-symbols-outlined text-[18px]">more_vert</span>
                                </button>
                                {showMenu && (
                                    <div className="absolute left-0 top-full mt-1 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl shadow-xl z-20 min-w-[140px] py-1 animate-in fade-in duration-150">
                                        <button
                                            onClick={() => { setIsEditing(true); setShowMenu(false); }}
                                            className="w-full flex items-center gap-2.5 px-4 py-2.5 text-sm text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-700 transition-colors cursor-pointer text-left"
                                        >
                                            <span className="material-symbols-outlined text-[18px]">edit</span> Edit
                                        </button>
                                        <button
                                            onClick={() => { onDeleteComment(comment.id); setShowMenu(false); }}
                                            className="w-full flex items-center gap-2.5 px-4 py-2.5 text-sm text-rose-500 hover:bg-rose-50 dark:hover:bg-rose-900/20 transition-colors cursor-pointer text-left"
                                        >
                                            <span className="material-symbols-outlined text-[18px]">delete</span> Delete
                                        </button>
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                )}

                {/* Reply Input */}
                {showReplyInput && (
                    <div className="mt-3">
                        <CommentInput
                            currentUser={currentUser}
                            placeholder={`Reply to ${comment.author}...`}
                            initialValue={depth > 0 ? `@${comment.author} ` : ''}
                            onSubmit={handleReplySubmit}
                            onCancel={() => setShowReplyInput(false)}
                            autoFocus
                        />
                    </div>
                )}

                {/* Replies Thread */}
                {(comment.replies || []).length > 0 && (
                    <div className="mt-2">
                        <button
                            onClick={() => setShowReplies(p => !p)}
                            className="flex items-center gap-1.5 text-[13px] font-bold text-cyan-600 dark:text-cyan-400 hover:bg-cyan-50 dark:hover:bg-cyan-900/20 px-3 py-1.5 rounded-full transition-all cursor-pointer"
                        >
                            <span className="material-symbols-outlined text-[16px]">{showReplies ? 'expand_less' : 'expand_more'}</span>
                            {showReplies ? 'Hide' : `${comment.replies.length}`} {comment.replies.length === 1 ? 'reply' : 'replies'}
                        </button>

                        {showReplies && (
                            <div className="mt-3 flex flex-col gap-4 border-l-2 border-slate-200 dark:border-slate-700 pl-4 ml-2">
                                {comment.replies.map(r => (
                                    <Comment
                                        key={r.id}
                                        comment={r}
                                        currentUser={currentUser}
                                        videoId={videoId}
                                        onUpdateComment={(rId, patch) => {
                                            const updatedReplies = (comment.replies || []).map(rep =>
                                                rep.id === rId ? { ...rep, ...patch } : rep
                                            );
                                            onUpdateComment(comment.id, { replies: updatedReplies });
                                        }}
                                        onDeleteComment={(rId) => {
                                            const updatedReplies = (comment.replies || []).filter(rep => rep.id !== rId);
                                            onUpdateComment(comment.id, { replies: updatedReplies });
                                        }}
                                        onAddChildReply={(newReply) => {
                                            const updatedReplies = [...(comment.replies || []), newReply];
                                            onUpdateComment(comment.id, { replies: updatedReplies });
                                        }}
                                        depth={depth + 1}
                                    />
                                ))}
                            </div>
                        )}
                    </div>
                )}
            </div>
        </div>
    );
}


// ── Main CommentsSection ──────────────────────────────────────────────────────

const STORAGE_KEY = (videoId) => `knome_yt_comments_v2_${videoId}`;

export default function CommentsSection({ videoId, currentUser, authorId, awardRuleKarma }) {
    const [comments, setComments] = useState([]);
    const [sortBy, setSortBy] = useState('top'); // 'top' | 'newest'
    const [showSortMenu, setShowSortMenu] = useState(false);
    const [visibleCount, setVisibleCount] = useState(20);
    const sortMenuRef = useRef(null);

    // ── Persistence ───────────────────────────────────────────────────────────
    const loadComments = useCallback(() => {
        try {
            return JSON.parse(localStorage.getItem(STORAGE_KEY(videoId)) || '[]');
        } catch { return []; }
    }, [videoId]);

    const saveComments = useCallback((data) => {
        try {
            localStorage.setItem(STORAGE_KEY(videoId), JSON.stringify(data));
        } catch { }
    }, [videoId]);

    useEffect(() => {
        setComments(loadComments());
        setVisibleCount(20);
        setSortBy('top');
    }, [videoId, loadComments]);

    useEffect(() => {
        const fn = (e) => { if (sortMenuRef.current && !sortMenuRef.current.contains(e.target)) setShowSortMenu(false); };
        document.addEventListener('mousedown', fn);
        return () => document.removeEventListener('mousedown', fn);
    }, []);

    // ── Sorted ────────────────────────────────────────────────────────────────
    const sorted = [...comments].sort((a, b) => {
        if (sortBy === 'newest') return new Date(b.createdAt) - new Date(a.createdAt);
        // Top: by net likes desc, then newest
        const scoreA = (a.likes || 0) - (a.dislikes || 0);
        const scoreB = (b.likes || 0) - (b.dislikes || 0);
        if (scoreB !== scoreA) return scoreB - scoreA;
        return new Date(b.createdAt) - new Date(a.createdAt);
    });

    // ── Add comment ───────────────────────────────────────────────────────────
    const handleAddComment = (text) => {
        const newC = {
            id: `c_${Date.now()}_${Math.random().toString(36).slice(2)}`,
            text,
            author: currentUser?.name || 'You',
            authorId: currentUser?.id || currentUser?.userId,
            avatar: currentUser?.avatar || null,
            createdAt: new Date().toISOString(),
            likes: 0,
            dislikes: 0,
            likedByMe: false,
            dislikedByMe: false,
            edited: false,
            replies: [],
        };
        const updated = [newC, ...comments];
        setComments(updated);
        saveComments(updated);
        if (awardRuleKarma && authorId) awardRuleKarma(authorId, 'COMMENT_RECEIVED');
    };

    // ── Update comment (patch) ────────────────────────────────────────────────
    const handleUpdateComment = useCallback((id, patch) => {
        setComments(prev => {
            const updated = prev.map(c => c.id === id ? { ...c, ...patch } : c);
            saveComments(updated);
            return updated;
        });
    }, [saveComments]);

    // ── Delete comment ────────────────────────────────────────────────────────
    const handleDeleteComment = useCallback((id) => {
        setComments(prev => {
            const updated = prev.filter(c => c.id !== id);
            saveComments(updated);
            return updated;
        });
    }, [saveComments]);

    const totalCount = comments.reduce((acc, c) => acc + 1 + (c.replies?.length || 0), 0);

    return (
        <div className="mt-8">
            {/* Header */}
            <div className="flex items-center gap-4 mb-6">
                <h2 className="text-[15px] font-black text-slate-900 dark:text-white">
                    {totalCount.toLocaleString()} Comments
                </h2>

                {/* Sort */}
                <div className="relative" ref={sortMenuRef}>
                    <button
                        onClick={() => setShowSortMenu(p => !p)}
                        className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[13px] font-bold text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-all cursor-pointer"
                    >
                        <span className="material-symbols-outlined text-[18px]">sort</span>
                        Sort by
                    </button>
                    {showSortMenu && (
                        <div className="absolute left-0 top-full mt-2 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-2xl shadow-2xl z-30 w-52 py-2 animate-in fade-in duration-150">
                            <p className="px-4 py-2 text-[11px] font-black text-slate-400 uppercase tracking-widest">Sort by</p>
                            {[
                                { key: 'top', label: 'Top comments', icon: 'trending_up' },
                                { key: 'newest', label: 'Newest first', icon: 'schedule' },
                            ].map(opt => (
                                <button
                                    key={opt.key}
                                    onClick={() => { setSortBy(opt.key); setShowSortMenu(false); }}
                                    className={`w-full flex items-center gap-3 px-4 py-3 text-sm transition-colors cursor-pointer text-left ${sortBy === opt.key ? 'text-cyan-600 dark:text-cyan-400 bg-cyan-50 dark:bg-cyan-900/20 font-bold' : 'text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-700 font-semibold'}`}
                                >
                                    <span className="material-symbols-outlined text-[18px]">{opt.icon}</span>
                                    {opt.label}
                                    {sortBy === opt.key && <span className="material-symbols-outlined text-[16px] ml-auto">check</span>}
                                </button>
                            ))}
                        </div>
                    )}
                </div>
            </div>

            {/* Add Comment */}
            <div className="mb-8">
                <CommentInput
                    currentUser={currentUser}
                    placeholder="Add a comment..."
                    onSubmit={handleAddComment}
                />
            </div>

            {/* Comment List */}
            {sorted.length === 0 ? (
                <div className="py-12 text-center">
                    <span className="material-symbols-outlined text-[40px] text-slate-300 dark:text-slate-600 mb-2 block">chat_bubble_outline</span>
                    <p className="text-sm font-bold text-slate-500 dark:text-slate-400">No comments yet</p>
                    <p className="text-xs text-slate-400 dark:text-slate-500 mt-1">Be the first to share your thoughts!</p>
                </div>
            ) : (
                <div className="flex flex-col gap-6">
                    {sorted.slice(0, visibleCount).map(comment => (
                        <Comment
                            key={comment.id}
                            comment={comment}
                            currentUser={currentUser}
                            videoId={videoId}
                            onUpdateComment={handleUpdateComment}
                            onDeleteComment={handleDeleteComment}
                        />
                    ))}

                    {visibleCount < sorted.length && (
                        <button
                            onClick={() => setVisibleCount(p => p + 20)}
                            className="mx-auto flex items-center gap-2 px-6 py-2.5 rounded-full text-sm font-bold text-cyan-600 dark:text-cyan-400 border border-cyan-300 dark:border-cyan-700 hover:bg-cyan-50 dark:hover:bg-cyan-900/20 transition-all cursor-pointer"
                        >
                            <span className="material-symbols-outlined text-[18px]">expand_more</span>
                            Show more comments ({sorted.length - visibleCount} remaining)
                        </button>
                    )}
                </div>
            )}
        </div>
    );
}
