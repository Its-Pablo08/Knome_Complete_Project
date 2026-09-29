import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useUser } from '../components/contexts/UserContext';
import knomeLogoDark from '../assets/knome_logo_dark.png';

const getSsoUrls = () => {
    const host = window.location.hostname || 'localhost';
    const isIis = window.location.port === '8080';
    const ehPort = isIis ? '8081' : '5001';
    const knomePort = window.location.port || (isIis ? '8080' : '5173');
    const knomeBase = `${window.location.protocol}//${host}${knomePort ? `:${knomePort}` : ''}`;

    // Target the central MPO Employee Hub online portal: https://counselling-1.mponline.demo.gov.in:3001
    const useLocalEh = Boolean(window.__USE_LOCAL_EH__ || (typeof localStorage !== 'undefined' && localStorage.getItem('knome_use_local_eh') === 'true'));
    const ehBase = useLocalEh ? `http://${host}:${ehPort}` : 'https://counselling-1.mponline.demo.gov.in:3001';
    const hubLoginUrl = `${ehBase}/login`;

    return { ehBase, hubLoginUrl, knomeBase };
};

export default function Login() {
    const { login, currentUser, isAuthenticated } = useUser();
    const navigate = useNavigate();

    useEffect(() => {
        try {
            sessionStorage.removeItem('knome_logging_out');
        } catch {}
        const { hubLoginUrl, knomeBase } = getSsoUrls();
        const returnUrl = encodeURIComponent(`${knomeBase}/login`);

        // Redirect to central MPO Hub login with registered client_id & returnUrl
        try {
            window.location.replace(`${hubLoginUrl}?client_id=Knome-2026&returnUrl=${returnUrl}&redirect_uri=${encodeURIComponent(knomeBase)}`);
        } catch {
            window.location.href = `${hubLoginUrl}?client_id=Knome-2026&returnUrl=${returnUrl}&redirect_uri=${encodeURIComponent(knomeBase)}`;
        }
    }, []);

    return (
        <div className="min-h-screen flex items-center justify-center bg-slate-950 text-white p-6 relative overflow-hidden">
            {/* Ambient Background Glows */}
            <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-blue-600/20 rounded-full blur-3xl pointer-events-none"></div>
            <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-indigo-600/20 rounded-full blur-3xl pointer-events-none"></div>

            <div className="flex flex-col items-center gap-5 relative z-10">
                <img src={knomeLogoDark} alt="KNOME" className="h-14 w-auto object-contain drop-shadow-lg animate-pulse" />
                <div className="flex items-center gap-3">
                    <div className="w-5 h-5 border-2 border-sky-400 border-t-transparent rounded-full animate-spin"></div>
                    <span className="text-sm font-semibold text-slate-300 tracking-wide">
                        Opening Knome...
                    </span>
                </div>
            </div>
        </div>
    );
}
