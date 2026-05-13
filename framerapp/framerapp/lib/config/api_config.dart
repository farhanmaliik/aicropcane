// For Android emulator use 10.0.2.2, for Windows/Web use localhost
const String serverBaseUrl = "http://localhost:3001";
const String mlBaseUrl     = "http://localhost:8000";

// Auth endpoints
const String baseUrl       = "$serverBaseUrl/auth";
const String profileUrl    = "$serverBaseUrl/profile";

// ML / chatbot endpoints
const String predictUrl    = "$mlBaseUrl/predict";
const String deepseekUrl   = "$mlBaseUrl/deepseek";
