/**
 * Knome Enterprise Draft Manager
 * LinkedIn-style draft persistence and lifecycle manager:
 * - User-scoped storage isolation: knome_user_post_draft_{userId}
 * - Debounced auto-save & auto-save on modal close
 * - Stable draft identity to prevent duplicate creation
 * - Synchronizes with knome_local_posts and backend API
 * - Broadcasts real-time events across tabs & components
 */

const STORAGE_PREFIX = 'knome_user_post_draft_';
const COMPOSER_SCRATCHPAD_PREFIX = 'knome_create_post_scratchpad_';

/**
 * Get user-isolated composer scratchpad key (uncommitted text kept on Create Post only)
 */
export const getComposerScratchpadKey = (userId) => {
    return `${COMPOSER_SCRATCHPAD_PREFIX}${userId || 'guest'}`;
};

/**
 * Retrieve active uncommitted composer scratchpad for Create Post
 */
export const getActiveComposerScratchpad = (userId) => {
    if (!userId) return null;
    try {
        const raw = localStorage.getItem(getComposerScratchpadKey(userId));
        if (!raw) return null;
        const data = JSON.parse(raw);
        if (!data) return null;
        const hasText = data.text && data.text.trim().length > 0;
        const hasAttachments = Array.isArray(data.attachments) && data.attachments.length > 0;
        if (!hasText && !hasAttachments) {
            return null;
        }
        return data;
    } catch (_) {
        return null;
    }
};

/**
 * Save uncommitted in-progress composer scratchpad (preserves text on Create Post without creating a draft in the Drafts tab)
 */
export const saveActiveComposerScratchpad = (userId, data) => {
    if (!userId) return null;
    const text = data.text ?? data.content ?? data.contentText ?? '';
    const attachments = data.attachments || [];

    if (!text.trim() && attachments.length === 0) {
        clearActiveComposerScratchpad(userId);
        return null;
    }

    const scratchpad = {
        text: text,
        attachments: attachments,
        audience: data.audience || data.audienceType || 'Everyone',
        selectedCommunity: data.selectedCommunity || null,
        selectedConnections: data.selectedConnections || [],
        scheduledTime: data.scheduledTime || null,
        savedAt: new Date().toISOString()
    };

    try {
        localStorage.setItem(getComposerScratchpadKey(userId), JSON.stringify(scratchpad));
    } catch (_) {}

    return scratchpad;
};

/**
 * Clear the active composer scratchpad
 */
export const clearActiveComposerScratchpad = (userId) => {
    if (!userId) return;
    try {
        localStorage.removeItem(getComposerScratchpadKey(userId));
    } catch (_) {}
};

/**
 * Get user-isolated localStorage key
 */
export const getUserDraftKey = (userId) => {
    return `${STORAGE_PREFIX}${userId || 'guest'}`;
};

/**
 * Retrieve saved draft for the given user (ONLY explicit drafts saved via 'Save as Draft')
 */
export const getUserDraft = (userId) => {
    if (!userId) return null;
    try {
        const raw = localStorage.getItem(getUserDraftKey(userId));
        if (!raw) return null;
        const draft = JSON.parse(raw);
        if (!draft) return null;
        
        // If draft was not explicitly saved via 'Save as Draft', migrate it to scratchpad so it is preserved on Create Post, and remove from official drafts
        if (!draft.savedAsDraft) {
            if (!getActiveComposerScratchpad(userId)) {
                saveActiveComposerScratchpad(userId, draft);
            }
            removeDraftFromLocalPosts(draft.id || draft.postId);
            localStorage.removeItem(getUserDraftKey(userId));
            return null;
        }

        // Ensure draft has content
        const hasText = draft.text && draft.text.trim().length > 0;
        const hasAttachments = Array.isArray(draft.attachments) && draft.attachments.length > 0;
        if (!hasText && !hasAttachments) {
            return null;
        }
        return draft;
    } catch (e) {
        console.warn('Failed to parse user draft:', e);
        return null;
    }
};

/**
 * Check if the user has an active unpublished draft
 */
export const hasUserDraft = (userId) => {
    return Boolean(getUserDraft(userId));
};

/**
 * Save or update the active user's draft (called ONLY when user clicks 'Save as Draft')
 */
export const saveUserDraft = (userId, draftData) => {
    if (!userId) return null;
    const text = draftData.text ?? draftData.content ?? draftData.contentText ?? '';
    const attachments = draftData.attachments || [];

    // Avoid saving completely blank drafts
    if (!text.trim() && attachments.length === 0) {
        return null;
    }

    const existingDraft = getUserDraft(userId);
    const draftId = draftData.id || existingDraft?.id || `draft_${userId}_${Date.now()}`;
    const postId = draftData.postId || existingDraft?.postId || (typeof draftId === 'number' ? draftId : null);
    const nowIso = new Date().toISOString();

    const normalizedDraft = {
        id: draftId,
        postId: postId,
        backendPostId: draftData.backendPostId || existingDraft?.backendPostId || (typeof draftId === 'number' ? draftId : null),
        userId: userId,
        authorId: userId,
        text: text,
        content: text,
        contentText: text,
        attachments: attachments.map((a, idx) => ({
            id: a.id || idx + 1,
            type: a.type || 'image',
            name: a.name || 'Attachment',
            url: a.backendUrl || a.url || '',
            backendUrl: a.backendUrl || (a.url?.startsWith('http') ? a.url : null),
            size: a.size || 0
        })),
        audience: draftData.audience || draftData.audienceType || 'Everyone',
        audienceType: draftData.audienceType || draftData.audience || 'Everyone',
        selectedCommunity: draftData.selectedCommunity || null,
        selectedConnections: draftData.selectedConnections || [],
        scheduledTime: draftData.scheduledTime || null,
        status: 'Draft',
        savedAsDraft: true,
        updatedAt: nowIso,
        savedAt: nowIso,
        createdAt: existingDraft?.createdAt || nowIso
    };

    try {
        localStorage.setItem(getUserDraftKey(userId), JSON.stringify(normalizedDraft));
    } catch (e) {
        console.warn('Failed to save user draft to localStorage:', e);
    }

    // Mirror to knome_local_posts so the draft shows up in the Drafts tab feed
    syncDraftToLocalPosts(normalizedDraft);

    // Clear composer scratchpad since it has now been officially saved into Drafts
    clearActiveComposerScratchpad(userId);

    // Broadcast update across open pages
    window.dispatchEvent(new CustomEvent('knome_drafts_updated', {
        detail: { userId, draft: normalizedDraft }
    }));

    return normalizedDraft;
};

/**
 * Clear the current user's active draft from storage
 */
export const clearUserDraft = (userId) => {
    if (!userId) return;
    try {
        localStorage.removeItem(getUserDraftKey(userId));
    } catch (e) {}

    window.dispatchEvent(new CustomEvent('knome_drafts_updated', {
        detail: { userId, draft: null }
    }));
};

/**
 * Delete a draft permanently (locally and on server if persisted)
 */
export const deleteDraft = async (userId, draftId, postsApiInstance) => {
    if (!draftId) return;
    const isNumericId = /^\d+$/.test(String(draftId));

    // Clear active draft if matching
    const currentDraft = getUserDraft(userId);
    if (currentDraft && String(currentDraft.id || currentDraft.postId) === String(draftId)) {
        clearUserDraft(userId);
    }

    // Remove from local posts fallback
    removeDraftFromLocalPosts(draftId);

    // Add to deleted IDs blacklist
    try {
        const deletedIds = JSON.parse(localStorage.getItem('knome_deleted_post_ids') || '[]');
        if (!deletedIds.includes(String(draftId))) {
            deletedIds.push(String(draftId));
            localStorage.setItem('knome_deleted_post_ids', JSON.stringify(deletedIds));
        }
    } catch (e) {}

    // Call backend API if it's a persisted DB post
    if (isNumericId && postsApiInstance) {
        try {
            await postsApiInstance.delete(draftId);
        } catch (err) {
            console.warn('Backend delete draft notice:', err);
        }
    }

    window.dispatchEvent(new CustomEvent('post-deleted', { detail: { id: draftId } }));
    window.dispatchEvent(new CustomEvent('knome_drafts_updated', { detail: { userId, draftId } }));
};

/**
 * Mirror draft to knome_local_posts
 */
export const syncDraftToLocalPosts = (draft) => {
    if (!draft) return;
    try {
        const localPosts = JSON.parse(localStorage.getItem('knome_local_posts') || '[]');
        const draftIdStr = String(draft.id || draft.postId);
        const existingIdx = localPosts.findIndex(lp => String(lp.id || lp.postId) === draftIdStr);

        const localPostItem = {
            id: draft.id,
            postId: draft.postId,
            userId: draft.userId,
            authorId: draft.userId,
            authorName: draft.authorName || 'You',
            content: draft.text,
            contentText: draft.text,
            status: 'Draft',
            savedAsDraft: true,
            attachments: draft.attachments || [],
            audienceType: draft.audience || 'Everyone',
            communityId: draft.selectedCommunity?.id || null,
            communityName: draft.selectedCommunity?.name || null,
            sharedCommunity: draft.selectedCommunity,
            sharedUsers: draft.selectedConnections,
            updatedAt: draft.updatedAt,
            createdDate: draft.createdAt || draft.updatedAt
        };

        if (existingIdx >= 0) {
            localPosts[existingIdx] = { ...localPosts[existingIdx], ...localPostItem };
        } else {
            localPosts.unshift(localPostItem);
        }
        localStorage.setItem('knome_local_posts', JSON.stringify(localPosts));
    } catch (e) {}
};

/**
 * Remove draft from local posts
 */
export const removeDraftFromLocalPosts = (draftId) => {
    if (!draftId) return;
    try {
        const draftIdStr = String(draftId);
        const localPosts = JSON.parse(localStorage.getItem('knome_local_posts') || '[]');
        const filtered = localPosts.filter(lp => String(lp.id || lp.postId) !== draftIdStr);
        localStorage.setItem('knome_local_posts', JSON.stringify(filtered));
    } catch (e) {}
};

/**
 * Human-friendly "Saved 2m ago" relative time formatter
 */
export const formatDraftTimeAgo = (dateInput) => {
    if (!dateInput) return 'Saved recently';
    const date = new Date(dateInput);
    if (isNaN(date.getTime())) return 'Saved recently';

    const diffSeconds = Math.floor((Date.now() - date.getTime()) / 1000);
    if (diffSeconds < 5) return 'Saved just now';
    if (diffSeconds < 60) return `Saved ${diffSeconds}s ago`;

    const diffMinutes = Math.floor(diffSeconds / 60);
    if (diffMinutes === 1) return 'Saved 1m ago';
    if (diffMinutes < 60) return `Saved ${diffMinutes}m ago`;

    const diffHours = Math.floor(diffMinutes / 60);
    if (diffHours === 1) return 'Saved 1h ago';
    if (diffHours < 24) return `Saved ${diffHours}h ago`;

    const diffDays = Math.floor(diffHours / 24);
    if (diffDays === 1) return 'Saved yesterday';
    if (diffDays < 7) return `Saved ${diffDays}d ago`;

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return `Saved on ${date.getDate()} ${months[date.getMonth()]}`;
};

/**
 * Retrieve the latest available draft for the user, checking local draft storage first,
 * then falling back to any server-side draft matching authorUserId.
 */
export const getLatestDraft = (userId, serverPosts = []) => {
    if (!userId) return null;
    const localDraft = getUserDraft(userId);
    if (localDraft) return localDraft;

    const currentUserIdStr = String(userId);
    const serverDraft = serverPosts.find(p => {
        if (p.status !== 'Draft') return false;
        const authorIdStr = String(p.author?.id || p.authorId || p.userId || p.authorUserId || '');
        return authorIdStr === currentUserIdStr;
    });

    if (serverDraft) {
        return mapServerPostToDraft(serverDraft);
    }

    return null;
};

/**
 * Map a server post object with status 'Draft' into the normalized draft format
 */
export const mapServerPostToDraft = (post) => {
    if (!post) return null;
    const text = post.contentText || post.content || post.text || '';
    return {
        id: post.postId || post.id,
        postId: post.postId || post.id,
        backendPostId: post.postId || post.id,
        userId: post.authorId || post.authorUserId || post.userId,
        text: text,
        content: text,
        contentText: text,
        attachments: (post.attachments || post.postAttachments || []).map((a, idx) => ({
            id: a.attachmentId || a.id || idx + 1,
            type: a.type || a.fileType?.toLowerCase() || 'image',
            name: a.name || 'Attachment',
            url: a.fileUrl || a.url || '',
            backendUrl: a.fileUrl || a.url || '',
            size: a.size || 0
        })),
        audience: post.audienceType || 'Everyone',
        audienceType: post.audienceType || 'Everyone',
        selectedCommunity: post.communityId ? { id: post.communityId, name: post.communityName || 'Community' } : null,
        selectedConnections: post.sharedUsers || [],
        scheduledTime: post.scheduledDate || null,
        status: 'Draft',
        updatedAt: post.updatedAt || post.publishedDate || post.createdDate || new Date().toISOString(),
        savedAt: post.updatedAt || post.publishedDate || post.createdDate || new Date().toISOString()
    };
};
