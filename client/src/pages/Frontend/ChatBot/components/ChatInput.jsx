import React, { useState, useRef } from "react";
import { IoSend } from "react-icons/io5";
import { BsMicFill } from "react-icons/bs";

/* Animated sound bars shown inside the mic popup */
const SoundBars = () => (
    <div className="flex items-end justify-center gap-1 h-10">
        {[1, 2, 3, 4, 5, 6, 7].map((i) => (
            <span
                key={i}
                style={{
                    display: "inline-block",
                    width: 5,
                    borderRadius: 3,
                    background: "#16a34a",
                    animation: `soundbar 0.8s ease-in-out ${i * 0.1}s infinite alternate`,
                    height: `${10 + Math.random() * 24}px`,
                }}
            />
        ))}
        <style>{`
            @keyframes soundbar {
                from { transform: scaleY(0.3); opacity: 0.5; }
                to   { transform: scaleY(1);   opacity: 1;   }
            }
        `}</style>
    </div>
);

const ChatInput = ({
    customPrompt,
    setCustomPrompt,
    sendCustomPrompt,
    filteredPrediction,
    chatLoading,
    t,
    languageMode,
}) => {
    const [showMicModal, setShowMicModal] = useState(false);
    const [micStatus, setMicStatus] = useState("idle");
    const [interimText, setInterimText] = useState("");
    const recognitionRef = useRef(null);

    const handleKeyDown = (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendCustomPrompt();
        }
    };

    const startListening = () => {
        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (!SpeechRecognition) {
            alert("Voice input is not supported in this browser. Please use Chrome.");
            return;
        }
        setInterimText("");
        setMicStatus("listening");
        setShowMicModal(true);

        const recognition = new SpeechRecognition();
        recognition.lang = languageMode === "urdu" ? "ur-PK" : "en-US";
        recognition.continuous = false;
        recognition.interimResults = true;

        recognition.onresult = (e) => {
            let interim = "";
            let final = "";
            for (let i = e.resultIndex; i < e.results.length; i++) {
                if (e.results[i].isFinal) final += e.results[i][0].transcript;
                else interim += e.results[i][0].transcript;
            }
            setInterimText(final || interim);
            if (final) {
                setCustomPrompt(final);
                setMicStatus("done");
            }
        };
        recognition.onerror = () => { setMicStatus("error"); };
        recognition.onend = () => {
            setMicStatus((prev) => prev === "listening" ? "done" : prev);
        };
        recognitionRef.current = recognition;
        recognition.start();
    };

    const stopListening = () => {
        recognitionRef.current?.stop();
        setMicStatus("done");
    };

    const closeModal = () => {
        recognitionRef.current?.stop();
        setShowMicModal(false);
        setMicStatus("idle");
        setInterimText("");
    };

    const isUrdu = languageMode === "urdu";

    return (
        <>
            {/* Mic Modal */}
            {showMicModal && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
                    <div className="bg-white rounded-2xl shadow-2xl p-8 w-80 flex flex-col items-center gap-4">
                        <div className={`w-16 h-16 rounded-full flex items-center justify-center ${micStatus === "listening" ? "bg-green-100" : "bg-gray-100"}`}>
                            <BsMicFill size={32} className={micStatus === "listening" ? "text-green-600" : "text-gray-400"} />
                        </div>

                        {micStatus === "listening" && (
                            <>
                                <p className="text-green-700 font-semibold text-center">
                                    {isUrdu ? "بولیں... آپ کی آواز سنی جا رہی ہے" : "Listening... please speak now"}
                                </p>
                                <SoundBars />
                                <p className="text-gray-500 text-sm text-center min-h-[20px]" dir="auto">
                                    {interimText}
                                </p>
                                <button
                                    onClick={stopListening}
                                    className="mt-2 px-5 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
                                >
                                    {isUrdu ? "رکیں" : "Stop"}
                                </button>
                            </>
                        )}

                        {micStatus === "done" && (
                            <>
                                <p className="text-gray-700 font-semibold text-center">
                                    {isUrdu ? "یہ سنا گیا:" : "You said:"}
                                </p>
                                <p className="text-green-700 text-center font-medium px-2 min-h-[24px]" dir="auto">
                                    {interimText || customPrompt}
                                </p>
                                <div className="flex gap-3 mt-2">
                                    <button
                                        onClick={closeModal}
                                        className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
                                    >
                                        {isUrdu ? "ٹھیک ہے" : "OK, use this"}
                                    </button>
                                    <button
                                        onClick={() => { setInterimText(""); setCustomPrompt(""); startListening(); }}
                                        className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
                                    >
                                        {isUrdu ? "دوبارہ" : "Retry"}
                                    </button>
                                </div>
                            </>
                        )}

                        {micStatus === "error" && (
                            <>
                                <p className="text-red-600 font-semibold text-center">
                                    {isUrdu ? "خرابی ہوئی، دوبارہ کوشش کریں" : "Could not hear you. Try again."}
                                </p>
                                <div className="flex gap-3 mt-2">
                                    <button onClick={closeModal} className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200">
                                        {isUrdu ? "بند کریں" : "Close"}
                                    </button>
                                    <button onClick={() => startListening()} className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700">
                                        {isUrdu ? "دوبارہ" : "Retry"}
                                    </button>
                                </div>
                            </>
                        )}
                    </div>
                </div>
            )}

            <div className="p-4 border-t border-gray-200">
                <div className="flex gap-2">
                    <input
                        type="text"
                        value={customPrompt}
                        onChange={(e) => setCustomPrompt(e.target.value)}
                        onKeyDown={handleKeyDown}
                        placeholder={t.placeholder}
                        disabled={!filteredPrediction || chatLoading}
                        className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-200 disabled:bg-gray-100 disabled:cursor-not-allowed mixed-text"
                        dir="auto"
                    />
                    <button
                        onClick={startListening}
                        disabled={!filteredPrediction || chatLoading}
                        title={isUrdu ? "آواز سے سوال کریں" : "Speak your question"}
                        className="px-3 py-2 rounded-lg border bg-white text-gray-600 border-gray-300 hover:bg-green-50 hover:border-green-400 hover:text-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        <BsMicFill size={18} />
                    </button>
                    <button
                        onClick={sendCustomPrompt}
                        disabled={!customPrompt.trim() || !filteredPrediction || chatLoading}
                        className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center transition-colors"
                    >
                        <IoSend className="mr-1" size={16} />
                        <span className="hidden sm:inline">
                            {isUrdu ? "بھیجیں" : "Send"}
                        </span>
                    </button>
                </div>
            </div>

            {/* Suggested Prompts */}
            {filteredPrediction && filteredPrediction.length > 0 && (
                <div className="px-4 pb-4">
                    <div className="text-xs text-gray-600 mb-2">{t.tryAsking}:</div>
                    <div className="flex flex-wrap gap-1">
                        {t.suggestedPrompts.map((prompt, idx) => (
                            <button
                                key={idx}
                                onClick={() => setCustomPrompt(prompt)}
                                className="px-3 py-1 text-xs bg-green-50 text-green-700 border border-green-200 rounded-lg hover:bg-green-100 transition-colors mixed-text"
                                disabled={chatLoading}
                            >
                                {prompt}
                            </button>
                        ))}
                    </div>
                </div>
            )}
        </>
    );
};

export default ChatInput;