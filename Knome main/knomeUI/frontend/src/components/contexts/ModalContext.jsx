import React, { createContext, useContext, useState } from 'react';
import CreatePostModal from '../modals/CreatePostModal';
import CreateArticleModal from '../modals/CreateArticleModal';
import { CreateVideoModal, CreatePodcastModal } from '../modals/MediaUploadModals';
import { CreateCommunityModal, CreateJobModal } from '../modals/ManagementModals';

const ModalContext = createContext();

export function ModalProvider({ children }) {
    const [isPostModalOpen, setIsPostModalOpen] = useState(false);
    const [isArticleModalOpen, setIsArticleModalOpen] = useState(false);
    const [isVideoModalOpen, setIsVideoModalOpen] = useState(false);
    const [isPodcastModalOpen, setIsPodcastModalOpen] = useState(false);
    const [isCommunityModalOpen, setIsCommunityModalOpen] = useState(false);
    const [isJobModalOpen, setIsJobModalOpen] = useState(false);

    const openPostModal = () => setIsPostModalOpen(true);
    const openArticleModal = () => setIsArticleModalOpen(true);
    const openVideoModal = () => setIsVideoModalOpen(true);
    const openPodcastModal = () => setIsPodcastModalOpen(true);
    const openCommunityModal = () => setIsCommunityModalOpen(true);
    const openJobModal = () => setIsJobModalOpen(true);

    const closeAll = () => {
        setIsPostModalOpen(false);
        setIsArticleModalOpen(false);
        setIsVideoModalOpen(false);
        setIsPodcastModalOpen(false);
        setIsCommunityModalOpen(false);
        setIsJobModalOpen(false);
    }

    return (
        <ModalContext.Provider value={{ 
            openPostModal, openArticleModal, openVideoModal, 
            openPodcastModal, openCommunityModal, openJobModal, closeAll 
        }}>
            {children}
            <CreatePostModal isOpen={isPostModalOpen} onClose={() => setIsPostModalOpen(false)} />
            <CreateArticleModal isOpen={isArticleModalOpen} onClose={() => setIsArticleModalOpen(false)} />
            <CreateVideoModal isOpen={isVideoModalOpen} onClose={() => setIsVideoModalOpen(false)} />
            <CreatePodcastModal isOpen={isPodcastModalOpen} onClose={() => setIsPodcastModalOpen(false)} />
            <CreateCommunityModal isOpen={isCommunityModalOpen} onClose={() => setIsCommunityModalOpen(false)} />
            <CreateJobModal isOpen={isJobModalOpen} onClose={() => setIsJobModalOpen(false)} />
        </ModalContext.Provider>
    );
}

export function useModal() {
    return useContext(ModalContext);
}

