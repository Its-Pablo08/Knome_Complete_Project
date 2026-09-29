import React, { useEffect, useState, useRef } from 'react';
import { resolveMediaUrl } from '../../utils/apiService';

export default function DocumentViewerModal({ document: docFile, onClose }) {
    const [blobUrl, setBlobUrl] = useState(null);
    const [loading, setLoading] = useState(true);
    const [hasError, setHasError] = useState(false);
    const [isFullscreen, setIsFullscreen] = useState(false);
    const [viewMode, setViewMode] = useState('fit'); // 'fit' | 'width'
    const modalRef = useRef(null);

    // Prevent background scrolling while modal is open
    useEffect(() => {
        document.body.style.overflow = 'hidden';
        return () => {
            document.body.style.overflow = '';
        };
    }, []);

    // Handle Escape and keyboard navigation
    useEffect(() => {
        const handleKeyDown = (e) => {
            if (e.key === 'Escape') {
                e.preventDefault();
                if (isFullscreen) {
                    setIsFullscreen(false);
                } else {
                    onClose();
                }
                return;
            }
        };

        window.addEventListener('keydown', handleKeyDown);
        return () => {
            window.removeEventListener('keydown', handleKeyDown);
        };
    }, [onClose, isFullscreen]);

    const fileName = docFile?.name || 'Document.pdf';
    const rawUrl = docFile?.url || docFile?.rawUrl || docFile?.fileUrl || '';
    const fileUrl = resolveMediaUrl(rawUrl);
    const isPdf = fileName.toLowerCase().endsWith('.pdf') || rawUrl.toLowerCase().includes('.pdf');
    const isImage = /\.(jpg|jpeg|png|gif|webp)$/i.test(fileName) || /\.(jpg|jpeg|png|gif|webp)/i.test(rawUrl);
    const isOfficeDoc = /\.(docx|doc|xlsx|xls|pptx|ppt)$/i.test(fileName) || /\.(docx|doc|xlsx|xls|pptx|ppt)/i.test(rawUrl);

    useEffect(() => {
        let isMounted = true;
        let createdUrl = null;
        setLoading(true);
        setHasError(false);

        if (!fileUrl || isImage || isOfficeDoc) {
            setLoading(false);
            return;
        }

        // Direct HTTP/HTTPS/Blob/Data URLs can be rendered directly by iframe
        if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://') || fileUrl.startsWith('blob:') || fileUrl.startsWith('data:')) {
            setBlobUrl(fileUrl);
            setLoading(false);
            return;
        }

        fetch(fileUrl)
            .then(res => {
                if (!res.ok) throw new Error(`HTTP ${res.status}`);
                return res.blob();
            })
            .then(blob => {
                if (!isMounted) return;
                const pdfBlob = new Blob([blob], { type: isPdf ? 'application/pdf' : blob.type });
                createdUrl = URL.createObjectURL(pdfBlob);
                setBlobUrl(createdUrl);
                setLoading(false);
            })
            .catch(err => {
                console.error("Document viewer load error", err);
                if (isMounted) {
                    setHasError(true);
                    setLoading(false);
                }
            });

        return () => {
            isMounted = false;
            if (createdUrl && createdUrl.startsWith('blob:')) {
                setTimeout(() => {
                    try { URL.revokeObjectURL(createdUrl); } catch (e) {}
                }, 3000);
            }
        };
    }, [fileUrl, isPdf, isImage, isOfficeDoc]);

    if (!docFile) return null;

    const displayUrl = blobUrl || fileUrl;
    // PDF parameters: toolbar=1 ensures browser renders its native navigation controls & does NOT clip page 1
    const pdfParams = viewMode === 'width' 
        ? '#toolbar=1&navpanes=0&view=FitH' 
        : '#toolbar=1&navpanes=0&view=Fit';

    const handleZoomIn = (e) => {
        e.stopPropagation();
        setZoom(prev => Math.min(prev + 0.25, 2.5));
    };

    const handleZoomOut = (e) => {
        e.stopPropagation();
        setZoom(prev => Math.max(prev - 0.25, 0.75));
    };

    const handleZoomReset = (e) => {
        e.stopPropagation();
        setZoom(1);
    };

    return (
        <div 
            ref={modalRef}
            className={`fixed inset-0 z-[9999] flex items-center justify-center bg-slate-950/85 backdrop-blur-md animate-fade-in ${
                isFullscreen ? 'p-0' : 'p-2 sm:p-4 md:p-6'
            }`}
            onClick={(e) => {
                if (e.target === modalRef.current) onClose();
            }}
        >
            {/* Modal Container */}
            <div className={`relative w-full bg-slate-900 border border-slate-800 shadow-2xl flex flex-col overflow-hidden transition-all duration-200 ${
                isFullscreen ? 'w-screen h-screen rounded-none border-0' : 'max-w-[96vw] h-[94vh] rounded-2xl'
            }`}>
                
                {/* Modal Header */}
                <div className="px-4 sm:px-6 py-3 bg-slate-900 border-b border-slate-800 flex items-center justify-between gap-3 shrink-0">
                    {/* Left File Title & Badge */}
                    <div className="flex items-center gap-3 overflow-hidden min-w-0">
                        <div className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 ${
                            isPdf 
                                ? 'bg-red-500/10 text-red-400 border border-red-500/20' 
                                : isOfficeDoc 
                                    ? 'bg-blue-500/10 text-blue-400 border border-blue-500/20' 
                                    : 'bg-indigo-500/10 text-indigo-400 border border-indigo-500/20'
                        }`}>
                            <span className="material-symbols-outlined text-[20px]">
                                {isPdf ? 'picture_as_pdf' : isOfficeDoc ? 'article' : 'description'}
                            </span>
                        </div>
                        <div className="min-w-0">
                            <h3 className="text-sm font-bold text-white truncate max-w-xs sm:max-w-md lg:max-w-lg" title={fileName}>
                                {fileName}
                            </h3>
                            <div className="flex items-center gap-2 mt-0.5 text-[11px] text-slate-400 font-medium">
                                <span className={`uppercase font-bold tracking-wider ${isPdf ? 'text-red-400' : 'text-blue-400'}`}>
                                    {isPdf ? 'PDF Document' : isOfficeDoc ? 'Office Document' : 'Document'}
                                </span>
                                <span>•</span>
                                <span className="flex items-center gap-1 text-emerald-400">
                                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                                    Active Viewer
                                </span>
                            </div>
                        </div>
                    </div>

                    {/* Right Controls */}
                    <div className="flex items-center gap-2 shrink-0">
                        {/* Zoom Controls for Images */}
                        {isImage && (
                            <div className="flex items-center gap-1 bg-slate-800/90 rounded-xl p-1 border border-slate-700/60">
                                <button
                                    onClick={handleZoomOut}
                                    className="w-7 h-7 flex items-center justify-center text-slate-400 hover:text-white rounded-lg hover:bg-slate-700 transition-colors"
                                    title="Zoom Out"
                                >
                                    <span className="material-symbols-outlined text-[16px]">remove</span>
                                </button>
                                <button
                                    onClick={handleZoomReset}
                                    className="px-2 py-0.5 text-[11px] font-bold text-slate-300 hover:text-white"
                                    title="Reset Zoom"
                                >
                                    {Math.round(zoom * 100)}%
                                </button>
                                <button
                                    onClick={handleZoomIn}
                                    className="w-7 h-7 flex items-center justify-center text-slate-400 hover:text-white rounded-lg hover:bg-slate-700 transition-colors"
                                    title="Zoom In"
                                >
                                    <span className="material-symbols-outlined text-[16px]">add</span>
                                </button>
                            </div>
                        )}

                        {/* PDF View Mode Toggle (Fit Page vs Fit Width) */}
                        {isPdf && (
                            <button
                                onClick={() => setViewMode(prev => prev === 'fit' ? 'width' : 'fit')}
                                className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-xs font-semibold border border-slate-700 transition-colors cursor-pointer"
                                title={viewMode === 'fit' ? 'Switch to Fit Width' : 'Switch to Fit Page'}
                            >
                                <span className="material-symbols-outlined text-[16px]">
                                    {viewMode === 'fit' ? 'fit_screen' : 'width'}
                                </span>
                                <span>{viewMode === 'fit' ? 'Fit Page' : 'Fit Width'}</span>
                            </button>
                        )}

                        {/* Open in New Tab Button */}
                        {displayUrl && (
                            <a
                                href={displayUrl}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold transition-all shadow-md shadow-blue-500/20 cursor-pointer"
                                title="Open full document in new browser tab"
                            >
                                <span className="material-symbols-outlined text-[16px]">open_in_new</span>
                                <span className="hidden sm:inline">Open in Tab</span>
                            </a>
                        )}

                        {/* Download Document Button */}
                        {displayUrl && (
                            <a
                                href={displayUrl}
                                download={fileName}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="w-9 h-9 flex items-center justify-center rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white border border-slate-700 transition-colors cursor-pointer"
                                title="Download document"
                            >
                                <span className="material-symbols-outlined text-[18px]">download</span>
                            </a>
                        )}

                        {/* Fullscreen Toggle */}
                        <button
                            onClick={() => setIsFullscreen(!isFullscreen)}
                            className="w-9 h-9 flex items-center justify-center rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white border border-slate-700 transition-colors cursor-pointer"
                            title={isFullscreen ? "Exit Fullscreen" : "Fullscreen Viewer"}
                        >
                            <span className="material-symbols-outlined text-[18px]">
                                {isFullscreen ? 'fullscreen_exit' : 'fullscreen'}
                            </span>
                        </button>

                        {/* Close Button */}
                        <button 
                            onClick={onClose}
                            className="w-9 h-9 bg-slate-800 hover:bg-rose-600 text-slate-400 hover:text-white rounded-xl transition-all flex items-center justify-center border border-slate-700 ml-1 cursor-pointer active:scale-95"
                            title="Close preview (Esc)"
                        >
                            <span className="material-symbols-outlined text-[20px]">close</span>
                        </button>
                    </div>
                </div>

                {/* Modal Body / Reader Viewport */}
                <div className="flex-1 bg-slate-950 flex items-center justify-center overflow-hidden relative">
                    {loading ? (
                        <div className="flex flex-col items-center justify-center gap-3 text-slate-400">
                            <span className="material-symbols-outlined text-[36px] animate-spin text-blue-500">progress_activity</span>
                            <p className="text-xs font-medium">Loading document preview...</p>
                        </div>
                    ) : isImage ? (
                        <div 
                            className="w-full h-full flex items-center justify-center overflow-auto p-4"
                            style={{ touchAction: 'pan-x pan-y' }}
                        >
                            <img 
                                src={displayUrl} 
                                alt={fileName} 
                                className="max-w-full max-h-full object-contain rounded-lg shadow-xl select-none transition-transform duration-150"
                                style={{ transform: `scale(${zoom})` }}
                                draggable={false}
                                onContextMenu={(e) => e.preventDefault()}
                            />
                        </div>
                    ) : isOfficeDoc ? (
                        <div className="flex flex-col items-center justify-center p-8 bg-slate-900 rounded-2xl text-center max-w-md border border-slate-800 m-4 shadow-2xl">
                            <div className="w-16 h-16 rounded-2xl bg-blue-500/10 text-blue-400 flex items-center justify-center mb-4 border border-blue-500/20">
                                <span className="material-symbols-outlined text-[36px]">description</span>
                            </div>
                            <h4 className="font-bold text-white text-base mb-1">{fileName}</h4>
                            <p className="text-xs text-slate-400 mb-6">
                                Microsoft Office Document
                            </p>
                            <div className="flex flex-col sm:flex-row items-center gap-3 w-full">
                                <a
                                    href={displayUrl}
                                    download={fileName}
                                    className="w-full py-2.5 px-4 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold rounded-xl transition-all shadow-md shadow-blue-500/20 flex items-center justify-center gap-2"
                                >
                                    <span className="material-symbols-outlined text-[16px]">download</span>
                                    Download File
                                </a>
                                <a
                                    href={`https://view.officeapps.live.com/op/view.aspx?src=${encodeURIComponent(displayUrl)}`}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="w-full py-2.5 px-4 bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-bold rounded-xl border border-slate-700 transition-all flex items-center justify-center gap-2"
                                >
                                    <span className="material-symbols-outlined text-[16px]">open_in_new</span>
                                    Office Online
                                </a>
                            </div>
                        </div>
                    ) : hasError ? (
                        <div className="flex flex-col items-center justify-center p-8 bg-slate-900 rounded-2xl text-center max-w-md border border-slate-800">
                            <div className="w-14 h-14 rounded-2xl bg-amber-500/10 text-amber-400 flex items-center justify-center mb-4 border border-amber-500/20">
                                <span className="material-symbols-outlined text-[32px]">warning</span>
                            </div>
                            <h4 className="font-bold text-white text-base mb-1">{fileName}</h4>
                            <p className="text-xs text-slate-400 mb-4">
                                Could not preview this document directly.
                            </p>
                            {displayUrl && (
                                <a
                                    href={displayUrl}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition-all shadow-md flex items-center gap-2"
                                >
                                    <span className="material-symbols-outlined text-[16px]">open_in_new</span>
                                    Open File Externally
                                </a>
                            )}
                        </div>
                    ) : (
                        <div className="w-full h-full bg-slate-950">
                            <iframe 
                                key={viewMode}
                                src={`${displayUrl}${isPdf && !displayUrl.includes('#') ? pdfParams : ''}`}
                                title={fileName}
                                className="w-full h-full border-0 bg-white"
                                loading="lazy"
                                allow="fullscreen"
                            />
                        </div>
                    )}
                </div>

                {/* Modal Footer Bar */}
                <div className="px-5 py-2.5 bg-slate-900 border-t border-slate-800 flex items-center justify-between text-[12px] text-slate-400 shrink-0">
                    <span className="flex items-center gap-1.5 font-medium">
                        <span className="material-symbols-outlined text-[16px] text-blue-400">verified_user</span>
                        Knome Enterprise Document Viewer
                    </span>
                    <div className="flex items-center gap-4">
                        {displayUrl && (
                            <a 
                                href={displayUrl} 
                                target="_blank" 
                                rel="noopener noreferrer"
                                className="hover:text-blue-400 font-medium transition-colors flex items-center gap-1"
                            >
                                <span className="material-symbols-outlined text-[14px]">open_in_new</span>
                                New Tab
                            </a>
                        )}
                        <button 
                            onClick={onClose}
                            className="hover:text-white font-medium transition-colors cursor-pointer"
                        >
                            Press Esc or Close to exit
                        </button>
                    </div>
                </div>

            </div>
        </div>
    );
}

