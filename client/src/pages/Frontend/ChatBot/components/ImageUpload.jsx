import React, { useState, useRef, useEffect } from "react";
import { IoImageOutline } from "react-icons/io5";
import { MdCamera } from "react-icons/md";

const ImageUpload = ({
    imageFile,
    imageFileName,
    imageFilePreview,
    imageFileRef,
    handleFileChange,
    setImageFile,
    setImageFileName,
    setImageFilePreview,
    t,
    languageMode
}) => {
    const [showCam, setShowCam] = useState(false);
    const [camReady, setCamReady] = useState(false);
    const [camError, setCamError] = useState(false);
    const videoRef = useRef(null);
    const canvasRef = useRef(null);
    const streamRef = useRef(null);

    useEffect(() => {
        if (!showCam) return;
        let active = true;
        (async () => {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({
                    video: { facingMode: "environment", width: 640, height: 480 },
                    audio: false,
                });
                if (!active) { stream.getTracks().forEach(t => t.stop()); return; }
                streamRef.current = stream;
                const video = videoRef.current;
                if (video) {
                    video.srcObject = stream;
                    await new Promise(resolve => { video.onloadedmetadata = resolve; });
                    await video.play();
                    if (active) setCamReady(true);
                }
            } catch (_) {
                if (active) setCamError(true);
            }
        })();
        return () => {
            active = false;
            streamRef.current?.getTracks().forEach(t => t.stop());
            streamRef.current = null;
        };
    }, [showCam]);

    const openCamera = () => { setCamError(false); setCamReady(false); setShowCam(true); };

    const closeCamera = () => {
        streamRef.current?.getTracks().forEach(t => t.stop());
        streamRef.current = null;
        setCamReady(false);
        setCamError(false);
        setShowCam(false);
    };

    const capturePhoto = () => {
        const video = videoRef.current;
        const canvas = canvasRef.current;
        if (!video || !canvas) return;
        const w = video.videoWidth || 640;
        const h = video.videoHeight || 480;
        canvas.width = w;
        canvas.height = h;
        canvas.getContext("2d").drawImage(video, 0, 0, w, h);
        canvas.toBlob((blob) => {
            if (!blob) return;
            const file = new File([blob], "camera_photo.jpg", { type: "image/jpeg" });
            setImageFile(file);
            setImageFileName(file.name);
            setImageFilePreview(URL.createObjectURL(file));
            closeCamera();
        }, "image/jpeg", 0.92);
    };

    const handleClearImage = (e) => {
        e.stopPropagation();
        setImageFile(null);
        setImageFileName(null);
        setImageFilePreview(null);
    };

    const urduFontStyle = languageMode === "urdu" ? {
        fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif",
        lineHeight: "2.2"
    } : {};

    return (
        <div>
            <label className="block text-sm font-medium mb-2" style={urduFontStyle}>{t.selectImage}:</label>

            {/* Upload + Camera row */}
            <div className="flex gap-2">
                <div
                    role="button"
                    className="relative flex flex-1 justify-center p-4 text-neutral-600 border-2 border-dashed border-neutral-300 rounded-xl cursor-pointer transition-all hover:border-green-500 hover:text-green-500 min-h-[120px]"
                    onClick={() => imageFileRef.current.click()}
                >
                    <input
                        ref={imageFileRef}
                        type="file"
                        accept="image/*"
                        className="hidden"
                        onChange={handleFileChange}
                    />
                    {imageFilePreview ? (
                        <img
                            src={imageFilePreview}
                            alt="preview"
                            className="w-full h-full object-contain rounded-lg"
                        />
                    ) : (
                        <div className="flex flex-col items-center justify-center">
                            <IoImageOutline size={40} className="mb-2 text-gray-400" />
                            <p className="text-sm text-gray-700" style={urduFontStyle}>{t.selectImage}</p>
                        </div>
                    )}
                    {imageFile && (
                        <button
                            className="absolute top-2 right-2 text-white text-xs bg-red-500 w-5 h-5 flex items-center justify-center rounded-full hover:bg-red-600 transition-colors"
                            onClick={handleClearImage}
                        >
                            ×
                        </button>
                    )}
                </div>

                {/* Camera button */}
                <button
                    type="button"
                    onClick={openCamera}
                    title={languageMode === "urdu" ? "کیمرے سے تصویر لیں" : "Take photo with camera"}
                    className="flex flex-col items-center justify-center gap-1 px-3 py-2 rounded-xl border-2 border-dashed border-neutral-300 text-gray-500 hover:border-green-500 hover:text-green-600 transition-colors min-w-[56px]"
                >
                    <MdCamera size={28} />
                    <span className="text-xs">Camera</span>
                </button>
            </div>

            {imageFileName && (
                <p className="mt-1 text-xs text-gray-600" style={urduFontStyle}>
                    {t.selected}: {imageFileName}
                </p>
            )}

            {/* Camera modal */}
            {showCam && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60">
                    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden">
                        <div className="flex items-center justify-between px-5 py-4 border-b">
                            <h3 className="font-bold text-lg">Take Photo</h3>
                            <button onClick={closeCamera} className="text-gray-400 hover:text-gray-700 text-2xl leading-none">&times;</button>
                        </div>
                        <div className="relative bg-black" style={{ height: 300 }}>
                            {camError ? (
                                <div className="absolute inset-0 flex flex-col items-center justify-center gap-2">
                                    <MdCamera size={48} className="text-gray-500" />
                                    <p className="text-gray-400 text-sm text-center px-4">
                                        Camera access denied or unavailable.<br />Allow camera in browser settings.
                                    </p>
                                </div>
                            ) : (
                                <>
                                    <video ref={videoRef} muted playsInline
                                        className="w-full h-full object-cover"
                                    />
                                    {!camReady && (
                                        <div className="absolute inset-0 flex items-center justify-center bg-black/60">
                                            <div className="text-white text-sm">Starting camera...</div>
                                        </div>
                                    )}
                                </>
                            )}
                        </div>
                        <canvas ref={canvasRef} className="hidden" />
                        <div className="flex gap-3 p-4">
                            <button onClick={closeCamera}
                                className="flex-1 py-2.5 rounded-lg border border-gray-300 text-gray-700 hover:bg-gray-50 transition-colors">
                                Cancel
                            </button>
                            <button onClick={capturePhoto} disabled={!camReady}
                                className="flex-1 py-2.5 rounded-lg bg-green-600 text-white hover:bg-green-700 disabled:opacity-40 disabled:cursor-not-allowed transition-colors flex items-center justify-center gap-2">
                                <MdCamera size={20} /> Capture
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default ImageUpload;