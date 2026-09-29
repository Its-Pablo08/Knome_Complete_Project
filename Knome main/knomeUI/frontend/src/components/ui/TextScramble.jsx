import React, { useState, useEffect, useRef } from 'react';

export default function TextScramble({ phrases, className = '' }) {
    const [text, setText] = useState('');
    const phraseIndexRef = useRef(0);
    const chars = '!<>-_\\/[]{}—=+*^?#________';
    
    useEffect(() => {
        let animationFrameId;
        
        // Randomize initial phrase to make it different on every reload/dashboard
        phraseIndexRef.current = Math.floor(Math.random() * phrases.length);
        
        const scramble = () => {
            const currentPhrase = phrases[phraseIndexRef.current];
            const length = currentPhrase.length;
            
            let frame = 0;
            const queue = [];
            for (let i = 0; i < length; i++) {
                const start = Math.floor(Math.random() * 40);
                const end = start + Math.floor(Math.random() * 40);
                queue.push({ from: currentPhrase[i], start, end, char: '' });
            }
            
            const update = () => {
                let output = '';
                let complete = 0;
                
                for (let i = 0; i < length; i++) {
                    const { from, start, end } = queue[i];
                    if (frame >= end) {
                        complete++;
                        output += from;
                    } else if (frame >= start) {
                        if (!queue[i].char || Math.random() < 0.28) {
                            queue[i].char = chars[Math.floor(Math.random() * chars.length)];
                        }
                        output += queue[i].char;
                    } else {
                        output += ''; // Or some placeholder space
                    }
                }
                
                setText(output);
                
                if (complete === length) {
                    // Animation complete for this phrase
                } else {
                    frame++;
                    animationFrameId = requestAnimationFrame(update);
                }
            };
            
            update();
        };
        
        scramble();
        
        return () => {
            cancelAnimationFrame(animationFrameId);
        };
    }, [phrases]);

    return (
        <span className={`font-mono inline-block ${className}`}>
            {text}
        </span>
    );
}
