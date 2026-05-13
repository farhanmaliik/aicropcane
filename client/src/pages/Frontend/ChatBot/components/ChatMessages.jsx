import React, { useState, useEffect, useRef } from "react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { BsFillVolumeUpFill, BsFillVolumeMuteFill } from "react-icons/bs";

const stripMarkdown = (text) =>
    text
        .replace(/#{1,6}\s+/g, "")
        .replace(/\*\*(.*?)\*\*/g, "$1")
        .replace(/\*(.*?)\*/g, "$1")
        .replace(/`{1,3}(.*?)`{1,3}/gs, "$1")
        .replace(/\[(.*?)\]\(.*?\)/g, "$1")
        .replace(/>\s?/g, "")
        .replace(/\n+/g, " ")
        .trim();

const MarkdownComponents = {
    p: ({ node, ...props }) => <p className="mb-2 mixed-text" dir="auto" style={{ fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif" }} {...props} />,
    h1: ({ node, ...props }) => <h1 className="text-xl font-bold mt-4 mb-2 mixed-text" dir="auto" style={{ fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif" }} {...props} />,
    h2: ({ node, ...props }) => <h2 className="text-lg font-bold mt-3 mb-2 mixed-text" dir="auto" style={{ fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif" }} {...props} />,
    h3: ({ node, ...props }) => <h3 className="text-base font-bold mt-2 mb-1 mixed-text" dir="auto" style={{ fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif" }} {...props} />,
    ul: ({ node, ...props }) => <ul className="list-disc pl-5 mb-2 mixed-text" dir="auto" style={{ fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif" }} {...props} />,
    ol: ({ node, ...props }) => <ol className="list-decimal pl-5 mb-2 mixed-text" dir="auto" style={{ fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif" }} {...props} />,
    li: ({ node, ...props }) => <li className="mb-1 mixed-text" dir="auto" style={{ fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif" }} {...props} />,
    strong: ({ node, ...props }) => <strong className="font-semibold mixed-text" style={{ fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif" }} {...props} />,
    em: ({ node, ...props }) => <em className="italic mixed-text" style={{ fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif" }} {...props} />,
    blockquote: ({ node, ...props }) => (
        <blockquote className="border-l-4 border-gray-300 pl-4 italic my-2 mixed-text" dir="auto" style={{ fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif" }} {...props} />
    ),
    code: ({ node, inline, ...props }) =>
        inline ? (
            <code className="bg-gray-100 px-1 rounded font-mono text-sm mixed-text" dir="ltr" {...props} />
        ) : (
            <pre className="bg-gray-100 p-3 rounded my-2 overflow-x-auto" dir="ltr">
                <code className="font-mono text-sm" {...props} />
            </pre>
        ),
};

const ChatMessages = ({ conversation, chatLoading, chatContainerRef, t }) => {
    const [speakingIdx, setSpeakingIdx] = useState(null);
    const voicesRef = useRef([]);

    // Voices load asynchronously — capture them once ready
    useEffect(() => {
        const load = () => { voicesRef.current = window.speechSynthesis.getVoices(); };
        load();
        window.speechSynthesis.onvoiceschanged = load;
        return () => { window.speechSynthesis.onvoiceschanged = null; };
    }, []);

    const toggleSpeak = (content, idx) => {
        if (window.speechSynthesis.speaking) {
            window.speechSynthesis.cancel();
            setSpeakingIdx(null);
            return;
        }
        const plain = stripMarkdown(content);
        const isUrduText = /[\u0600-\u06FF]/.test(content);
        const utterance = new SpeechSynthesisUtterance(plain);
        const voices = voicesRef.current;

        if (isUrduText) {
            const voice = voices.find(v => v.lang === "ur-PK") ||
                          voices.find(v => v.lang.startsWith("ur")) ||
                          voices.find(v => v.lang.startsWith("hi")) ||
                          null;
            if (voice) utterance.voice = voice;
            utterance.lang = voice ? voice.lang : "ur-PK";
            utterance.rate = 0.85;
        } else {
            const voice = voices.find(v => v.lang === "en-US") ||
                          voices.find(v => v.lang.startsWith("en")) ||
                          null;
            if (voice) utterance.voice = voice;
            utterance.lang = "en-US";
            utterance.rate = 1;
        }

        utterance.onend = () => setSpeakingIdx(null);
        utterance.onerror = () => setSpeakingIdx(null);
        setSpeakingIdx(idx);
        window.speechSynthesis.speak(utterance);
    };

    return (
        <div
            ref={chatContainerRef}
            className="flex-1 p-4 bg-gray-50 overflow-y-auto"
            style={{
                fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif",
                minHeight: '300px',
                maxHeight: 'calc(100vh - 350px)'
            }}
        >
            {conversation.length === 0 ? (
                <div className="flex items-center justify-center h-full">
                    <div className="text-center">
                        <p className="text-gray-500 mixed-text" dir="auto">
                            {t.analyzeFirst}
                        </p>
                    </div>
                </div>
            ) : (
                conversation.map((msg, idx) => (
                    <div
                        key={idx}
                        className={`mb-3 p-3 rounded-lg ${
                            msg.role === "user"
                                ? "bg-green-50 border-l-4 border-green-500"
                                : "bg-gray-50 border-l-4 border-gray-500"
                        } mixed-text`}
                        dir="auto"
                        style={{
                            fontFamily: "'Noto Nastaliq Urdu', 'Noto Sans', sans-serif",
                            lineHeight: '2'
                        }}
                    >
                        <div className="flex justify-between items-center mb-1">
                            <div className="font-semibold text-sm">
                                {msg.role === "user" ? t.you : t.assistant}
                            </div>
                            <div className="flex items-center gap-2">
                                {msg.role === "assistant" && (
                                    <button
                                        onClick={() => toggleSpeak(msg.content, idx)}
                                        title={speakingIdx === idx ? "Stop speaking" : "Read aloud"}
                                        className={`p-1 rounded transition-colors ${
                                            speakingIdx === idx
                                                ? "text-green-600 animate-pulse"
                                                : "text-gray-400 hover:text-gray-600"
                                        }`}
                                    >
                                        {speakingIdx === idx
                                            ? <BsFillVolumeMuteFill size={16} />
                                            : <BsFillVolumeUpFill size={16} />
                                        }
                                    </button>
                                )}
                                <div className="text-xs text-gray-500">
                                    {new Date(msg.timestamp).toLocaleTimeString([], {
                                        hour: '2-digit',
                                        minute: '2-digit'
                                    })}
                                </div>
                            </div>
                        </div>

                        {msg.isMarkdown ? (
                            <div className="prose prose-sm max-w-none">
                                <ReactMarkdown
                                    remarkPlugins={[remarkGfm]}
                                    components={MarkdownComponents}
                                >
                                    {msg.content}
                                </ReactMarkdown>
                            </div>
                        ) : (
                            <div className="whitespace-pre-wrap">
                                {msg.content}
                            </div>
                        )}
                    </div>
                ))
            )}
            {chatLoading && (
                <div className="flex items-center p-3 text-gray-600">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-gray-600 mr-2"></div>
                    {t.thinking}
                </div>
            )}
        </div>
    );
};

export default ChatMessages;