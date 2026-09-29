import React, { useState, useRef, useEffect, useCallback } from 'react';

const ASPECT_PRESETS = [
    { id: 'free', label: 'Free', ratio: null, ratioStr: 'Custom', icon: 'crop_free' },
    { id: 'original', label: 'Original', ratio: 'original', ratioStr: 'Original', icon: 'image' },
    { id: 'square', label: 'Square (1:1)', width: 1200, height: 1200, ratio: 1, ratioStr: '1:1', icon: 'crop_square' },
    { id: 'landscape', label: 'Landscape (1.91:1)', width: 1200, height: 627, ratio: 1200 / 627, ratioStr: '1.91:1', icon: 'crop_landscape' },
    { id: 'portrait', label: 'Portrait (4:5)', width: 1080, height: 1350, ratio: 1080 / 1350, ratioStr: '4:5', icon: 'crop_portrait' },
    { id: '16_9', label: '16:9', ratio: 16 / 9, ratioStr: '16:9', icon: 'crop_16_9' }
];

export default function ImageCropModal({ isOpen, onClose, imageSrc, fileName, onSave }) {
    const [selectedPreset, setSelectedPreset] = useState('free');
    const [rotation, setRotation] = useState(0); // 0, 90, 180, 270
    const [straightenAngle, setStraightenAngle] = useState(0); // -45 to +45
    const [flipH, setFlipH] = useState(false);
    const [flipV, setFlipV] = useState(false);

    const [naturalSize, setNaturalSize] = useState({ width: 0, height: 0 });
    const [imageLoaded, setImageLoaded] = useState(false);
    const [stageBounds, setStageBounds] = useState({ width: 600, height: 400 });
    const [imgDisplay, setImgDisplay] = useState({ width: 0, height: 0, left: 0, top: 0 });

    // Crop box coordinates relative to imgDisplay (top-left is 0,0)
    const [crop, setCrop] = useState({ x: 0, y: 0, width: 0, height: 0 });
    const [activeHandle, setActiveHandle] = useState(null); // 'nw', 'ne', 'sw', 'se', 'n', 's', 'w', 'e', 'move'
    const [dragStart, setDragStart] = useState({ mouseX: 0, mouseY: 0, cropX: 0, cropY: 0, cropW: 0, cropH: 0 });
    const [isInteracting, setIsInteracting] = useState(false);
    const [isApplying, setIsApplying] = useState(false);

    const stageRef = useRef(null);
    const imgRef = useRef(null);

    // Initialize or reset state when modal opens with a new image
    useEffect(() => {
        if (isOpen) {
            setRotation(0);
            setStraightenAngle(0);
            setFlipH(false);
            setFlipV(false);
            setSelectedPreset('free');
            setImageLoaded(false);
            setActiveHandle(null);
            setIsInteracting(false);
        }
    }, [isOpen, imageSrc]);

    // Measure stage container dimensions
    const updateStageDimensions = useCallback(() => {
        if (!stageRef.current) return;
        const rect = stageRef.current.getBoundingClientRect();
        if (rect.width > 0 && rect.height > 0) {
            setStageBounds({ width: rect.width, height: rect.height });
        }
    }, []);

    useEffect(() => {
        if (!isOpen) return;
        updateStageDimensions();
        window.addEventListener('resize', updateStageDimensions);
        return () => window.removeEventListener('resize', updateStageDimensions);
    }, [isOpen, updateStageDimensions]);

    // Compute fitted image display dimensions and position inside stage
    const computeFittedImage = useCallback((natW, natH, stageW, stageH) => {
        if (!natW || !natH || !stageW || !stageH) return { width: 0, height: 0, left: 0, top: 0 };
        // Leave 28px padding on each side
        const availW = Math.max(stageW - 56, 120);
        const availH = Math.max(stageH - 56, 120);
        const scale = Math.min(availW / natW, availH / natH);
        const width = Math.round(natW * scale);
        const height = Math.round(natH * scale);
        const left = Math.round((stageW - width) / 2);
        const top = Math.round((stageH - height) / 2);
        return { width, height, left, top };
    }, []);

    // Helper: calculate initial crop box for a given preset ratio
    const calculateCropForPreset = useCallback((presetId, imgW, imgH, natW, natH) => {
        if (!imgW || !imgH) return { x: 0, y: 0, width: 0, height: 0 };

        let targetRatio = null;
        if (presetId === 'original') {
            targetRatio = (natW && natH) ? (natW / natH) : (imgW / imgH);
        } else if (presetId !== 'free') {
            const found = ASPECT_PRESETS.find(p => p.id === presetId);
            if (found && found.ratio) targetRatio = found.ratio;
        }

        if (!targetRatio) {
            // Free mode: default to 90% of image centered
            const w = Math.round(imgW * 0.92);
            const h = Math.round(imgH * 0.92);
            return {
                x: Math.round((imgW - w) / 2),
                y: Math.round((imgH - h) / 2),
                width: w,
                height: h
            };
        }

        // Fit maximum rectangle with targetRatio inside (imgW, imgH)
        let w = imgW * 0.92;
        let h = w / targetRatio;
        if (h > imgH * 0.92) {
            h = imgH * 0.92;
            w = h * targetRatio;
        }
        w = Math.round(w);
        h = Math.round(h);
        return {
            x: Math.round((imgW - w) / 2),
            y: Math.round((imgH - h) / 2),
            width: w,
            height: h
        };
    }, []);

    // When image loads or stage bounds change, recalculate fit & initial crop
    const handleImageLoad = (e) => {
        const { naturalWidth, naturalHeight } = e.target;
        setNaturalSize({ width: naturalWidth, height: naturalHeight });
        setImageLoaded(true);

        const stageW = stageBounds.width || 600;
        const stageH = stageBounds.height || 380;
        const fitted = computeFittedImage(naturalWidth, naturalHeight, stageW, stageH);
        setImgDisplay(fitted);

        const initialCrop = calculateCropForPreset('free', fitted.width, fitted.height, naturalWidth, naturalHeight);
        setCrop(initialCrop);
    };

    // When stage bounds update after resize
    useEffect(() => {
        if (!imageLoaded || !naturalSize.width) return;
        const fitted = computeFittedImage(naturalSize.width, naturalSize.height, stageBounds.width, stageBounds.height);
        setImgDisplay(fitted);
        setCrop(calculateCropForPreset(selectedPreset, fitted.width, fitted.height, naturalSize.width, naturalSize.height));
    }, [stageBounds, imageLoaded, naturalSize, computeFittedImage, calculateCropForPreset, selectedPreset]);

    // Handle preset selection
    const handleSelectPreset = (presetId) => {
        setSelectedPreset(presetId);
        if (imgDisplay.width > 0 && imgDisplay.height > 0) {
            const newCrop = calculateCropForPreset(presetId, imgDisplay.width, imgDisplay.height, naturalSize.width, naturalSize.height);
            setCrop(newCrop);
        }
    };

    // Handle rotation buttons
    const handleRotate90 = () => {
        setRotation(prev => (prev + 90) % 360);
    };

    const handleFlipH = () => setFlipH(prev => !prev);
    const handleFlipV = () => setFlipV(prev => !prev);

    const handleReset = () => {
        setRotation(0);
        setStraightenAngle(0);
        setFlipH(false);
        setFlipV(false);
        setSelectedPreset('free');
        if (imgDisplay.width && imgDisplay.height) {
            setCrop(calculateCropForPreset('free', imgDisplay.width, imgDisplay.height, naturalSize.width, naturalSize.height));
        }
    };

    // Active aspect ratio for handle drag calculations
    const getTargetRatio = useCallback(() => {
        if (selectedPreset === 'free') return null;
        if (selectedPreset === 'original') {
            return naturalSize.width ? (naturalSize.width / naturalSize.height) : null;
        }
        const found = ASPECT_PRESETS.find(p => p.id === selectedPreset);
        return found?.ratio || null;
    }, [selectedPreset, naturalSize]);

    // --- Drag & Resize Handlers ---
    const handlePointerDown = (handle, e) => {
        e.preventDefault();
        e.stopPropagation();
        setActiveHandle(handle);
        setIsInteracting(true);
        setDragStart({
            mouseX: e.clientX,
            mouseY: e.clientY,
            cropX: crop.x,
            cropY: crop.y,
            cropW: crop.width,
            cropH: crop.height
        });
    };

    const handlePointerMove = useCallback((e) => {
        if (!activeHandle || !imgDisplay.width || !imgDisplay.height) return;

        const dx = e.clientX - dragStart.mouseX;
        const dy = e.clientY - dragStart.mouseY;
        const targetRatio = getTargetRatio();
        const minSize = 40;
        const maxW = imgDisplay.width;
        const maxH = imgDisplay.height;

        let { cropX, cropY, cropW, cropH } = dragStart;
        let newX = cropX;
        let newY = cropY;
        let newW = cropW;
        let newH = cropH;

        if (activeHandle === 'move') {
            newX = Math.max(0, Math.min(maxW - cropW, cropX + dx));
            newY = Math.max(0, Math.min(maxH - cropH, cropY + dy));
            setCrop({ x: Math.round(newX), y: Math.round(newY), width: cropW, height: cropH });
            return;
        }

        // Corner or Edge resizing
        if (activeHandle.includes('e')) {
            newW = Math.max(minSize, Math.min(maxW - cropX, cropW + dx));
        }
        if (activeHandle.includes('s')) {
            newH = Math.max(minSize, Math.min(maxH - cropY, cropH + dy));
        }
        if (activeHandle.includes('w')) {
            const proposedW = Math.max(minSize, Math.min(cropX + cropW, cropW - dx));
            newX = cropX + (cropW - proposedW);
            newW = proposedW;
        }
        if (activeHandle.includes('n')) {
            const proposedH = Math.max(minSize, Math.min(cropY + cropH, cropH - dy));
            newY = cropY + (cropH - proposedH);
            newH = proposedH;
        }

        // If aspect ratio is locked (not Free), maintain ratio
        if (targetRatio) {
            if (activeHandle === 'se') {
                newH = newW / targetRatio;
                if (cropY + newH > maxH) {
                    newH = maxH - cropY;
                    newW = newH * targetRatio;
                }
            } else if (activeHandle === 'sw') {
                newH = newW / targetRatio;
                if (cropY + newH > maxH) {
                    newH = maxH - cropY;
                    newW = newH * targetRatio;
                    newX = (cropX + cropW) - newW;
                }
            } else if (activeHandle === 'ne') {
                newH = newW / targetRatio;
                if (cropY + cropH - newH < 0) {
                    newH = cropY + cropH;
                    newW = newH * targetRatio;
                }
                newY = (cropY + cropH) - newH;
            } else if (activeHandle === 'nw') {
                newH = newW / targetRatio;
                if (cropY + cropH - newH < 0) {
                    newH = cropY + cropH;
                    newW = newH * targetRatio;
                }
                newY = (cropY + cropH) - newH;
                newX = (cropX + cropW) - newW;
            }
        }

        // Final boundary bounds clamping
        newX = Math.max(0, Math.min(maxW - minSize, newX));
        newY = Math.max(0, Math.min(maxH - minSize, newY));
        newW = Math.max(minSize, Math.min(maxW - newX, newW));
        newH = Math.max(minSize, Math.min(maxH - newY, newH));

        setCrop({
            x: Math.round(newX),
            y: Math.round(newY),
            width: Math.round(newW),
            height: Math.round(newH)
        });
    }, [activeHandle, dragStart, imgDisplay, getTargetRatio]);

    const handlePointerUp = useCallback(() => {
        setActiveHandle(null);
        setIsInteracting(false);
    }, []);

    useEffect(() => {
        if (activeHandle) {
            window.addEventListener('pointermove', handlePointerMove);
            window.addEventListener('pointerup', handlePointerUp);
            return () => {
                window.removeEventListener('pointermove', handlePointerMove);
                window.removeEventListener('pointerup', handlePointerUp);
            };
        }
    }, [activeHandle, handlePointerMove, handlePointerUp]);

    // Apply Crop & Export using Canvas
    const handleApply = useCallback(() => {
        if (!imgRef.current || !naturalSize.width || !crop.width || !crop.height) return;
        setIsApplying(true);

        try {
            const img = imgRef.current;
            const scaleToNat = naturalSize.width / imgDisplay.width;

            // Compute exact crop region in source image pixels
            const natCropX = crop.x * scaleToNat;
            const natCropY = crop.y * scaleToNat;
            const natCropW = crop.width * scaleToNat;
            const natCropH = crop.height * scaleToNat;

            // Output resolution
            let outW = Math.round(natCropW);
            let outH = Math.round(natCropH);

            const activePresetObj = ASPECT_PRESETS.find(p => p.id === selectedPreset);
            if (activePresetObj?.width && activePresetObj?.height) {
                outW = activePresetObj.width;
                outH = activePresetObj.height;
            }

            const canvas = document.createElement('canvas');
            canvas.width = outW;
            canvas.height = outH;
            const ctx = canvas.getContext('2d');
            if (!ctx) throw new Error('Could not create canvas context');

            ctx.imageSmoothingEnabled = true;
            ctx.imageSmoothingQuality = 'high';

            // Clear canvas
            ctx.clearRect(0, 0, outW, outH);

            // Center transform
            ctx.save();
            ctx.translate(outW / 2, outH / 2);

            // Apply total rotation (straighten fine angle + 90-degree steps)
            const totalAngle = rotation + straightenAngle;
            ctx.rotate((totalAngle * Math.PI) / 180);

            // Apply flips
            ctx.scale(flipH ? -1 : 1, flipV ? -1 : 1);

            // Draw cropped area
            ctx.drawImage(
                img,
                natCropX, natCropY, natCropW, natCropH,
                -outW / 2, -outH / 2, outW, outH
            );

            ctx.restore();

            // Export to blob & file
            canvas.toBlob((blob) => {
                if (!blob) {
                    setIsApplying(false);
                    return;
                }
                const newUrl = URL.createObjectURL(blob);
                const ext = fileName?.split('.').pop() || 'jpg';
                const cleanName = fileName ? fileName.replace(/\.[^/.]+$/, "") : `crop_${Date.now()}`;
                const newFile = new File([blob], `${cleanName}_cropped.${ext}`, {
                    type: blob.type || 'image/jpeg'
                });

                onSave(blob, newUrl, newFile);
                setIsApplying(false);
                onClose();
            }, 'image/jpeg', 0.95);
        } catch (err) {
            console.error('Failed to apply Google Photos crop:', err);
            setIsApplying(false);
        }
    }, [crop, naturalSize, imgDisplay, selectedPreset, rotation, straightenAngle, flipH, flipV, fileName, onSave, onClose]);

    if (!isOpen || !imageSrc) return null;

    // Total transform string for image display inside stage
    const totalRotationDeg = rotation + straightenAngle;

    return (
        <div className="fixed inset-0 z-[120] flex items-center justify-center p-2 sm:p-4 bg-black/90 backdrop-blur-md animate-in fade-in duration-200 select-none">
            <div className="relative w-full max-w-4xl bg-[#131316] border border-slate-800 rounded-3xl shadow-2xl overflow-hidden flex flex-col max-h-[96vh] text-white">

                {/* Top Bar: Google Photos Minimal Header */}
                <div className="px-5 py-3.5 border-b border-slate-800/80 flex items-center justify-between bg-[#0e0e11]">
                    <div className="flex items-center gap-3">
                        <button
                            type="button"
                            onClick={onClose}
                            className="w-9 h-9 rounded-full flex items-center justify-center text-slate-400 hover:text-white hover:bg-slate-800 transition-colors cursor-pointer"
                            title="Close"
                        >
                            <span className="material-symbols-outlined text-[20px]">close</span>
                        </button>
                        <div>
                            <h3 className="font-bold text-sm text-white flex items-center gap-2">
                                <span>Crop & Straighten</span>
                                {straightenAngle !== 0 && (
                                    <span className="text-[11px] font-mono font-semibold px-2 py-0.5 rounded-full bg-blue-500/20 text-blue-400 border border-blue-500/30">
                                        {straightenAngle > 0 ? `+${straightenAngle}°` : `${straightenAngle}°`}
                                    </span>
                                )}
                            </h3>
                            <p className="text-[11px] text-slate-400">Drag corners or edges to crop • Straighten with slider</p>
                        </div>
                    </div>

                    <div className="flex items-center gap-2">
                        <button
                            type="button"
                            onClick={handleReset}
                            className="px-3.5 py-1.5 rounded-full text-xs font-semibold text-slate-400 hover:text-white hover:bg-slate-800/80 transition-colors cursor-pointer"
                            title="Reset all crop and rotation changes"
                        >
                            Reset
                        </button>
                    </div>
                </div>

                {/* Main Interactive Stage (Deep dark canvas) */}
                <div
                    ref={stageRef}
                    className="relative flex-1 min-h-[320px] max-h-[440px] bg-[#09090b] flex items-center justify-center overflow-hidden"
                >
                    {/* The Image Element under transformations */}
                    <div
                        style={{
                            width: `${imgDisplay.width}px`,
                            height: `${imgDisplay.height}px`,
                            transform: `rotate(${totalRotationDeg}deg) scale(${flipH ? -1 : 1}, ${flipV ? -1 : 1})`,
                            transition: isInteracting ? 'none' : 'transform 0.2s ease-out'
                        }}
                        className="relative pointer-events-none"
                    >
                        <img
                            ref={imgRef}
                            src={imageSrc}
                            alt="Crop Preview"
                            onLoad={handleImageLoad}
                            draggable={false}
                            className="w-full h-full object-contain pointer-events-none select-none"
                        />
                    </div>

                    {/* Dark Mask Overlay with Cutout for Crop Box */}
                    {imageLoaded && imgDisplay.width > 0 && (
                        <div
                            style={{
                                width: `${imgDisplay.width}px`,
                                height: `${imgDisplay.height}px`,
                                left: `${imgDisplay.left}px`,
                                top: `${imgDisplay.top}px`
                            }}
                            className="absolute pointer-events-none"
                        >
                            {/* Google Photos Interactive Crop Box */}
                            <div
                                style={{
                                    transform: `translate(${crop.x}px, ${crop.y}px)`,
                                    width: `${crop.width}px`,
                                    height: `${crop.height}px`
                                }}
                                className="absolute top-0 left-0 border border-white/90 shadow-[0_0_0_9999px_rgba(0,0,0,0.65)] pointer-events-auto"
                            >
                                {/* Center Drag Area */}
                                <div
                                    onPointerDown={(e) => handlePointerDown('move', e)}
                                    className="absolute inset-0 cursor-move"
                                    title="Click and drag to reposition crop"
                                />

                                {/* 3x3 Rule-of-Thirds Grid (Dynamically highlights when dragging) */}
                                <div
                                    className={`absolute inset-0 grid grid-cols-3 grid-rows-3 pointer-events-none transition-opacity duration-200 ${
                                        isInteracting ? 'opacity-85' : 'opacity-35'
                                    }`}
                                >
                                    <div className="border-r border-b border-white/60"></div>
                                    <div className="border-r border-b border-white/60"></div>
                                    <div className="border-b border-white/60"></div>
                                    <div className="border-r border-b border-white/60"></div>
                                    <div className="border-r border-b border-white/60"></div>
                                    <div className="border-b border-white/60"></div>
                                    <div className="border-r border-b border-white/60"></div>
                                    <div className="border-r border-b border-white/60"></div>
                                    <div></div>
                                </div>

                                {/* Google Photos Signature White Corner L-Brackets */}
                                {/* Top-Left Corner */}
                                <div
                                    onPointerDown={(e) => handlePointerDown('nw', e)}
                                    className="absolute -top-3 -left-3 w-8 h-8 cursor-nwse-resize z-30 flex items-start justify-start p-2"
                                    title="Resize Top-Left"
                                >
                                    <div className="relative w-4 h-4 pointer-events-none">
                                        <div className="absolute top-0 left-0 w-4 h-[3.5px] bg-white rounded-xs shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                        <div className="absolute top-0 left-0 w-[3.5px] h-4 bg-white rounded-xs shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                    </div>
                                </div>

                                {/* Top-Right Corner */}
                                <div
                                    onPointerDown={(e) => handlePointerDown('ne', e)}
                                    className="absolute -top-3 -right-3 w-8 h-8 cursor-nesw-resize z-30 flex items-start justify-end p-2"
                                    title="Resize Top-Right"
                                >
                                    <div className="relative w-4 h-4 pointer-events-none">
                                        <div className="absolute top-0 right-0 w-4 h-[3.5px] bg-white rounded-xs shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                        <div className="absolute top-0 right-0 w-[3.5px] h-4 bg-white rounded-xs shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                    </div>
                                </div>

                                {/* Bottom-Left Corner */}
                                <div
                                    onPointerDown={(e) => handlePointerDown('sw', e)}
                                    className="absolute -bottom-3 -left-3 w-8 h-8 cursor-nesw-resize z-30 flex items-end justify-start p-2"
                                    title="Resize Bottom-Left"
                                >
                                    <div className="relative w-4 h-4 pointer-events-none">
                                        <div className="absolute bottom-0 left-0 w-4 h-[3.5px] bg-white rounded-xs shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                        <div className="absolute bottom-0 left-0 w-[3.5px] h-4 bg-white rounded-xs shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                    </div>
                                </div>

                                {/* Bottom-Right Corner */}
                                <div
                                    onPointerDown={(e) => handlePointerDown('se', e)}
                                    className="absolute -bottom-3 -right-3 w-8 h-8 cursor-nwse-resize z-30 flex items-end justify-end p-2"
                                    title="Resize Bottom-Right"
                                >
                                    <div className="relative w-4 h-4 pointer-events-none">
                                        <div className="absolute bottom-0 right-0 w-4 h-[3.5px] bg-white rounded-xs shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                        <div className="absolute bottom-0 right-0 w-[3.5px] h-4 bg-white rounded-xs shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                    </div>
                                </div>

                                {/* Edge Handles (Google Photos style pill bars) */}
                                {/* Top Edge */}
                                <div
                                    onPointerDown={(e) => handlePointerDown('n', e)}
                                    className="absolute -top-2.5 left-1/2 -translate-x-1/2 w-10 h-5 cursor-ns-resize z-20 flex items-center justify-center"
                                >
                                    <div className="w-6 h-[3px] bg-white rounded-full shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                </div>

                                {/* Bottom Edge */}
                                <div
                                    onPointerDown={(e) => handlePointerDown('s', e)}
                                    className="absolute -bottom-2.5 left-1/2 -translate-x-1/2 w-10 h-5 cursor-ns-resize z-20 flex items-center justify-center"
                                >
                                    <div className="w-6 h-[3px] bg-white rounded-full shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                </div>

                                {/* Left Edge */}
                                <div
                                    onPointerDown={(e) => handlePointerDown('w', e)}
                                    className="absolute -left-2.5 top-1/2 -translate-y-1/2 w-5 h-10 cursor-ew-resize z-20 flex items-center justify-center"
                                >
                                    <div className="w-[3px] h-6 bg-white rounded-full shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                </div>

                                {/* Right Edge */}
                                <div
                                    onPointerDown={(e) => handlePointerDown('e', e)}
                                    className="absolute -right-2.5 top-1/2 -translate-y-1/2 w-5 h-10 cursor-ew-resize z-20 flex items-center justify-center"
                                >
                                    <div className="w-[3px] h-6 bg-white rounded-full shadow-[0_0_2px_rgba(0,0,0,0.8)]"></div>
                                </div>
                            </div>
                        </div>
                    )}
                </div>

                {/* Google Photos Straighten Dial & Rotation Bar */}
                <div className="px-5 py-3 bg-[#131316] border-t border-slate-800/80 flex flex-col gap-2.5">
                    <div className="flex items-center justify-between gap-4">
                        {/* 90° Rotation & Flip Buttons */}
                        <div className="flex items-center gap-1.5">
                            <button
                                type="button"
                                onClick={handleRotate90}
                                className="p-2 rounded-xl bg-slate-800/80 hover:bg-slate-700 text-slate-200 hover:text-white transition-all flex items-center gap-1 text-xs font-semibold cursor-pointer active:scale-95"
                                title="Rotate 90° Clockwise"
                            >
                                <span className="material-symbols-outlined text-[18px]">rotate_90_degrees_cw</span>
                                <span className="hidden sm:inline">+90°</span>
                            </button>

                            <button
                                type="button"
                                onClick={handleFlipH}
                                className={`p-2 rounded-xl transition-all flex items-center gap-1 text-xs font-semibold cursor-pointer active:scale-95 ${
                                    flipH ? 'bg-blue-600 text-white' : 'bg-slate-800/80 hover:bg-slate-700 text-slate-200 hover:text-white'
                                }`}
                                title="Flip Horizontal"
                            >
                                <span className="material-symbols-outlined text-[18px]">flip</span>
                            </button>

                            <button
                                type="button"
                                onClick={handleFlipV}
                                className={`p-2 rounded-xl transition-all flex items-center gap-1 text-xs font-semibold cursor-pointer active:scale-95 ${
                                    flipV ? 'bg-blue-600 text-white' : 'bg-slate-800/80 hover:bg-slate-700 text-slate-200 hover:text-white'
                                }`}
                                title="Flip Vertical"
                            >
                                <span className="material-symbols-outlined text-[18px] rotate-90">flip</span>
                            </button>
                        </div>

                        {/* Google Photos Straighten Ruler Slider */}
                        <div className="flex items-center gap-3 flex-1 max-w-md">
                            <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider shrink-0 hidden sm:inline">
                                Straighten:
                            </span>
                            <div className="relative flex-1 flex items-center">
                                <input
                                    type="range"
                                    min="-45"
                                    max="45"
                                    step="0.5"
                                    value={straightenAngle}
                                    onChange={(e) => setStraightenAngle(parseFloat(e.target.value))}
                                    className="w-full accent-blue-500 cursor-pointer h-1.5 bg-slate-800 rounded-lg appearance-none"
                                />
                            </div>
                            <button
                                type="button"
                                onClick={() => setStraightenAngle(0)}
                                className={`text-xs font-mono font-bold px-2 py-1 rounded-lg border transition-all cursor-pointer ${
                                    straightenAngle === 0
                                        ? 'text-slate-400 border-transparent hover:text-white'
                                        : 'text-blue-400 border-blue-500/40 bg-blue-500/10 hover:bg-blue-500/20'
                                }`}
                                title="Click to reset angle to 0°"
                            >
                                {straightenAngle > 0 ? `+${straightenAngle.toFixed(1)}°` : `${straightenAngle.toFixed(1)}°`}
                            </button>
                        </div>
                    </div>

                    {/* Google Photos Aspect Ratio Pills */}
                    <div className="flex items-center gap-1.5 overflow-x-auto custom-scrollbar pt-1">
                        <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider shrink-0 mr-1 hidden sm:inline">
                            Aspect:
                        </span>
                        {ASPECT_PRESETS.map((p) => {
                            const isSelected = selectedPreset === p.id;
                            return (
                                <button
                                    key={p.id}
                                    type="button"
                                    onClick={() => handleSelectPreset(p.id)}
                                    className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-all shrink-0 flex items-center gap-1.5 cursor-pointer border ${
                                        isSelected
                                            ? 'bg-blue-600 text-white border-blue-500 shadow-md shadow-blue-600/30'
                                            : 'bg-slate-800/60 hover:bg-slate-800 text-slate-300 border-slate-700/60 hover:text-white'
                                    }`}
                                >
                                    <span className="material-symbols-outlined text-[15px]">{p.icon}</span>
                                    <span>{p.label}</span>
                                    <span className="text-[10px] opacity-75 font-mono">({p.ratioStr})</span>
                                </button>
                            );
                        })}
                    </div>
                </div>

                {/* Bottom Bar: Dimensions & Action Controls (Google Photos Style) */}
                <div className="px-5 py-3 bg-[#0e0e11] border-t border-slate-800/80 flex items-center justify-between gap-3">
                    <div className="flex items-center gap-2 text-xs text-slate-400">
                        <span className="font-mono text-slate-300">
                            {crop.width && naturalSize.width ? (
                                `${Math.round(crop.width * (naturalSize.width / imgDisplay.width))} × ${Math.round(crop.height * (naturalSize.width / imgDisplay.width))} px`
                            ) : (
                                `${naturalSize.width} × ${naturalSize.height} px`
                            )}
                        </span>
                        {selectedPreset !== 'free' && (
                            <>
                                <span>•</span>
                                <span className="font-semibold text-blue-400">
                                    {ASPECT_PRESETS.find(p => p.id === selectedPreset)?.label}
                                </span>
                            </>
                        )}
                    </div>

                    <div className="flex items-center gap-2.5">
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-4 py-2 rounded-full text-xs font-semibold text-slate-300 hover:text-white hover:bg-slate-800 transition-colors cursor-pointer"
                        >
                            Cancel
                        </button>
                        <button
                            type="button"
                            onClick={handleApply}
                            disabled={isApplying || !imageLoaded}
                            className="px-6 py-2 rounded-full text-xs font-bold bg-blue-600 hover:bg-blue-500 active:scale-95 text-white shadow-md shadow-blue-600/30 transition-all flex items-center gap-1.5 disabled:opacity-50 cursor-pointer"
                        >
                            {isApplying ? (
                                <>
                                    <span className="material-symbols-outlined text-[16px] animate-spin">progress_activity</span>
                                    <span>Saving...</span>
                                </>
                            ) : (
                                <>
                                    <span className="material-symbols-outlined text-[16px]">check</span>
                                    <span>Done</span>
                                </>
                            )}
                        </button>
                    </div>
                </div>

            </div>
        </div>
    );
}
