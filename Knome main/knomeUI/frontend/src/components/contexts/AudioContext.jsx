import React, { createContext, useContext, useState, useRef, useEffect } from 'react';
import { resolveMediaUrl, podcastsApi } from '../../utils/apiService';

const defaultAudioContext = {
    currentPodcast: null,
    isPlaying: false,
    volume: 1,
    speed: 1,
    progress: 0,
    currentTime: 0,
    duration: 0,
    playPodcast: () => {},
    togglePlay: () => {},
    closePlayer: () => {},
    setVolume: () => {},
    setSpeed: () => {},
    handleSeek: () => {}
};

const AudioContext = createContext(defaultAudioContext);

export const useAudio = () => useContext(AudioContext) || defaultAudioContext;

export function AudioProvider({ children }) {
    const [currentPodcast, setCurrentPodcast] = useState(null);
    const [isPlaying, setIsPlaying] = useState(false);
    const [volume, setVolume] = useState(1);
    const [speed, setSpeed] = useState(1);
    const [progress, setProgress] = useState(0); // 0 to 100
    const [duration, setDuration] = useState(0);
    const [currentTime, setCurrentTime] = useState(0);

    const audioRef = useRef(null);

    // Default sample fallback if no audio uploaded
    const sampleAudioUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";

    useEffect(() => {
        if (!audioRef.current) {
            audioRef.current = new Audio();
        }
        
        const audio = audioRef.current;
        
        const updateTime = () => {
            setCurrentTime(audio.currentTime);
            setDuration(audio.duration || 0);
            if (audio.duration) {
                setProgress((audio.currentTime / audio.duration) * 100);
            }
        };

        const handleEnded = () => {
            setIsPlaying(false);
            setProgress(0);
        };

        audio.addEventListener('timeupdate', updateTime);
        audio.addEventListener('ended', handleEnded);
        audio.addEventListener('loadedmetadata', updateTime);

        return () => {
            audio.removeEventListener('timeupdate', updateTime);
            audio.removeEventListener('ended', handleEnded);
            audio.removeEventListener('loadedmetadata', updateTime);
        };
    }, []);

    useEffect(() => {
        if (currentPodcast) {
            const mediaUrl = currentPodcast.audioUrl ? resolveMediaUrl(currentPodcast.audioUrl) : sampleAudioUrl;
            audioRef.current.src = mediaUrl;
            audioRef.current.play().catch(e => console.error("Playback error:", e));
            setIsPlaying(true);
        }
    }, [currentPodcast]);

    useEffect(() => {
        if (audioRef.current) {
            if (isPlaying) {
                audioRef.current.play().catch(e => console.error("Playback error:", e));
            } else {
                audioRef.current.pause();
            }
        }
    }, [isPlaying]);

    useEffect(() => {
        if (audioRef.current) {
            audioRef.current.volume = volume;
        }
    }, [volume]);

    useEffect(() => {
        if (audioRef.current) {
            audioRef.current.playbackRate = speed;
        }
    }, [speed]);

    const triggerRecordView = (podcast) => {
        const pid = podcast?.podcastId || podcast?.id;
        if (!pid) return;

        // Authoritative backend record and sync (strictly 1 view per user)

        // Authoritative backend record and sync
        podcastsApi.recordView(pid)
            .then(res => {
                const newViews = (res && typeof res === 'object' && 'data' in res) ? res.data : res;
                if (newViews !== undefined && newViews !== null) {
                    window.dispatchEvent(new CustomEvent('knome_podcast_viewed', { 
                        detail: { id: Number(pid), viewCount: Number(newViews) } 
                    }));
                }
            })
            .catch(err => console.warn('Failed to record podcast view:', err));
    };

    const playPodcast = (podcast) => {
        if (!podcast) return;
        const targetId = podcast.podcastId || podcast.id;
        const currentId = currentPodcast?.podcastId || currentPodcast?.id;
        const isSame = currentId && targetId && Number(currentId) === Number(targetId);

        if (isSame) {
            if (isPlaying) {
                setIsPlaying(false);
            } else {
                setIsPlaying(true);
                triggerRecordView(podcast);
            }
        } else {
            setCurrentPodcast(podcast);
            setIsPlaying(true);
            triggerRecordView(podcast);
        }
    };

    const togglePlay = () => {
        if (!isPlaying && currentPodcast) {
            triggerRecordView(currentPodcast);
        }
        setIsPlaying(!isPlaying);
    };
    
    const closePlayer = () => {
        setCurrentPodcast(null);
        setIsPlaying(false);
        if (audioRef.current) {
            audioRef.current.pause();
        }
    };

    const handleSeek = (percentage) => {
        if (audioRef.current && audioRef.current.duration) {
            const time = (percentage / 100) * audioRef.current.duration;
            audioRef.current.currentTime = time;
            setProgress(percentage);
        }
    };

    const skipTime = (seconds) => {
        if (audioRef.current && audioRef.current.duration) {
            let newTime = audioRef.current.currentTime + seconds;
            newTime = Math.max(0, Math.min(newTime, audioRef.current.duration));
            audioRef.current.currentTime = newTime;
            setCurrentTime(newTime);
            setProgress((newTime / audioRef.current.duration) * 100);
        }
    };

    const toggleMute = () => {
        if (volume > 0) {
            setVolume(0);
        } else {
            setVolume(1);
        }
    };

    return (
        <AudioContext.Provider value={{
            currentPodcast,
            isPlaying,
            volume,
            speed,
            progress,
            duration,
            currentTime,
            playPodcast,
            togglePlay,
            closePlayer,
            setVolume,
            setSpeed,
            handleSeek,
            skipTime,
            toggleMute
        }}>
            {children}
        </AudioContext.Provider>
    );
}
