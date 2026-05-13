// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'chat_sidebar.dart';
import 'chat_provider.dart';
import 'package:framerapp/utils/appcolors.dart';
import 'package:framerapp/views/homescreen/homescreen.dart';
import 'package:framerapp/services/api_service.dart';
import 'web_camera_stub.dart' if (dart.library.html) 'web_camera_web.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});
  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  String? selectedPlant;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  final TextEditingController _questionController = TextEditingController();

  bool _isAnalyzing = false;
  bool _isSending = false;
  List<Map<String, dynamic>>? _prediction;
  List<Map<String, dynamic>> _conversation = [];
  String _language = 'english';
  Uint8List? _webImageBytes; // bytes from web camera capture

  // TTS
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  int? _speakingIndex;

  // Speech-to-text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    // Do NOT initialize speech here — browsers require a user gesture first
  }

  Future<void> _initTts() async {
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.setLanguage('en-US');
    _tts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) setState(() { _isSpeaking = false; _speakingIndex = null; });
    });
    _tts.setErrorHandler((msg) {
      if (mounted) setState(() { _isSpeaking = false; _speakingIndex = null; });
    });
  }

  Future<void> _speak(String text, int index) async {
    if (_isSpeaking && _speakingIndex == index) {
      await _tts.stop();
      setState(() { _isSpeaking = false; _speakingIndex = null; });
      return;
    }
    await _tts.stop();
    // Set language based on current selection
    if (_language == 'urdu') {
      await _tts.setLanguage('ur-PK');
    } else {
      await _tts.setLanguage('en-US');
    }
    setState(() { _isSpeaking = true; _speakingIndex = index; });
    // Strip markdown for cleaner speech
    final cleanText = text
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'#+\s'), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');
    _tts.speak(cleanText); // fire-and-forget; handlers update state
  }

  Future<void> _showVoiceDialog() async {
    // Initialize on first tap (user gesture) — triggers browser mic permission
    if (!_speechInitialized) {
      final available = await _speech.initialize(
        onError: (e) {},
        onStatus: (s) {},
      );
      if (!available) {
        _showSnack('Microphone access denied. Allow it in browser settings.');
        return;
      }
      if (mounted) setState(() => _speechInitialized = true);
    }
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _VoiceListenDialog(speech: _speech, language: _language),
    );
    if (result != null && result.isNotEmpty && mounted) {
      _questionController.value = TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() { _selectedImage = image; _webImageBytes = null; _prediction = null; _conversation = []; });
    }
  }

  Future<void> _pickFromCamera() async {
    if (kIsWeb) {
      final bytes = await showWebCameraDialog(context);
      if (bytes != null && mounted) {
        final xfile = XFile.fromData(bytes, mimeType: 'image/jpeg', name: 'photo.jpg');
        setState(() { _selectedImage = xfile; _webImageBytes = bytes; _prediction = null; _conversation = []; });
      }
    } else {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() { _selectedImage = image; _webImageBytes = null; _prediction = null; _conversation = []; });
      }
    }
  }

  Future<void> _startAnalyzing() async {
    if (_selectedImage == null) { _showSnack('Please select an image first.'); return; }
    if (selectedPlant == null) { _showSnack('Please select a plant.'); return; }
    setState(() { _isAnalyzing = true; _conversation = []; });
    try {
      final result = await ApiService.predict(imageFile: _selectedImage!, plant: selectedPlant!);
      setState(() { _prediction = result; });
      final reply = await ApiService.askDeepseek(
        plant: selectedPlant!, predictions: result,
        userQuestion: '', conversation: [], language: _language, isInitialAnalysis: true,
      );
      setState(() { _conversation = [{'role': 'assistant', 'content': reply}]; });
      Provider.of<ChatProvider>(context, listen: false).addChat('$selectedPlant Analysis');
      _speak(reply, 0);
    } catch (e) { _showSnack('Error: $e'); }
    finally { setState(() { _isAnalyzing = false; }); }
  }

  Future<void> _sendQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;
    if (_prediction == null) { _showSnack('Please analyze an image first.'); return; }
    setState(() {
      _isSending = true;
      _conversation = [..._conversation, {'role': 'user', 'content': question}];
      _questionController.clear();
    });
    try {
      final reply = await ApiService.askDeepseek(
        plant: selectedPlant!, predictions: _prediction!,
        userQuestion: question,
        conversation: _conversation.take(_conversation.length - 1)
            .map((m) => {'role': m['role'] as String, 'content': m['content'] as String}).toList(),
        language: _language, isInitialAnalysis: false,
      );
      final newConv = [..._conversation, {'role': 'assistant', 'content': reply}];
      setState(() { _conversation = newConv; });
      _speak(reply, newConv.length - 1);
    } catch (e) {
      setState(() { _conversation = [..._conversation, {'role': 'assistant', 'content': 'Sorry, an error occurred.'}]; });
    } finally { setState(() { _isSending = false; }); }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ─── UI Sections ──────────────────────────────────────────────────────────

  Widget _buildTopSection() {
    final height = MediaQuery.of(context).size.width * 0.45;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Upload a plant leaf image for analysis', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 16),

      // Image preview box
      GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: double.infinity, height: height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: _selectedImage == null
              ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Tap to select from gallery', style: TextStyle(color: Colors.grey)),
                ])
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _webImageBytes != null
                      ? Image.memory(_webImageBytes!, fit: BoxFit.cover, width: double.infinity)
                      : kIsWeb
                          ? Image.network(_selectedImage!.path, fit: BoxFit.cover, width: double.infinity)
                          : Image.file(File(_selectedImage!.path), fit: BoxFit.cover, width: double.infinity),
                ),
        ),
      ),
      const SizedBox(height: 12),

      // Gallery + Camera buttons
      Row(children: [
        Expanded(child: OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library_outlined, color: Colors.green, size: 20),
          label: const Text('Gallery', style: TextStyle(color: Colors.green)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.green),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        )),
        const SizedBox(width: 12),
        Expanded(child: OutlinedButton.icon(
          onPressed: _pickFromCamera,
          icon: const Icon(Icons.camera_alt_outlined, color: Colors.green, size: 20),
          label: const Text('Camera', style: TextStyle(color: Colors.green)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.green),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        )),
      ]),
      const SizedBox(height: 20),

      // Plant dropdown
      DropdownButtonFormField<String>(
        hint: const Text('Select a Plant'),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 1.5)),
        ),
        value: selectedPlant,
        items: ['Maize', 'ChickenPeas', 'Mango', 'Rice']
            .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) => setState(() => selectedPlant = v),
      ),
      const SizedBox(height: 20),

      // Analyze button
      SizedBox(
        height: 48, width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isAnalyzing ? null : _startAnalyzing,
          child: _isAnalyzing
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Start Analyzing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kSecondaryColor)),
        ),
      ),
    ]);
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, int index) {
    final isUser = msg['role'] == 'user';
    final text = msg['content'] as String;
    final isSpeakingThis = _isSpeaking && _speakingIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: isUser ? Colors.green : Colors.blueGrey, width: 4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
            isUser ? 'You' : 'AI Assistant',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const Spacer(),
          // Speaker button on AI messages only
          if (!isUser)
            Tooltip(
              message: isSpeakingThis ? 'Stop speaking' : 'Speak answer',
              child: InkWell(
                onTap: () => _speak(text, index),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSpeakingThis ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
                      key: ValueKey(isSpeakingThis),
                      color: isSpeakingThis ? Colors.red : Colors.green,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 6),
        Text(text),
      ]),
    );
  }

  Widget _buildResultSection() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ask About Results', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text('Ask questions about the detected diseases', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ]),
            ),
          ),
          const Divider(height: 1),

          // Messages or placeholder
          _conversation.isEmpty
              ? const SizedBox(width: double.infinity, height: 160,
                  child: Center(child: Text(
                    "Upload an image, select a plant, and click 'Start Analyzing' to begin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  )))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: _conversation.length,
                  itemBuilder: (ctx, i) => _buildMessageBubble(_conversation[i], i),
                ),

          // Thinking indicator
          if (_isSending)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Thinking...', style: TextStyle(color: Colors.grey)),
              ]),
            ),

          // Suggestion chips
          if (_prediction != null && _conversation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Try asking:', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  'Tell me more about this disease',
                  'How do I treat this?',
                  'What are the symptoms?',
                  'Is this serious?',
                ].map(_buildSuggestionChip).toList()),
                const SizedBox(height: 8),
              ]),
            ),

          // Input row: mic + text + send
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              // Mic button — opens voice popup dialog
              Tooltip(
                message: 'Voice input',
                child: InkWell(
                  onTap: _showVoiceDialog,
                  borderRadius: BorderRadius.circular(23),
                  child: Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mic_none, color: Colors.green.shade700, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Text input
              Expanded(child: TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  hintText: 'Ask a question...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _sendQuestion(),
              )),
              const SizedBox(width: 8),

              // Send button
              Container(
                decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isSending ? null : _sendQuestion,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: _isSending
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.send, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Send', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ]),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return InkWell(
      onTap: () => setState(() => _questionController.text = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(color: Colors.green, fontSize: 13)),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            centerTitle: true,
            title: const Text('AI Plant Disease Predictor', style: TextStyle(fontSize: 22)),
          ),
        ),
        drawer: const ChatSidebar(),
        body: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      label: const Text('Home', style: TextStyle(color: Colors.black)),
                      style: TextButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _language = _language == 'english' ? 'urdu' : 'english');
                        _initTts();
                      },
                      icon: const Icon(Icons.language, color: Colors.black),
                      label: Text(
                        _language == 'english' ? 'اردو' : 'English',
                        style: const TextStyle(color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildTopSection()),
                const SizedBox(height: 24),
                _buildResultSection(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Voice Listen Dialog ─────────────────────────────────────────────────────

class _VoiceListenDialog extends StatefulWidget {
  final stt.SpeechToText speech;
  final String language;
  const _VoiceListenDialog({required this.speech, required this.language});

  @override
  State<_VoiceListenDialog> createState() => _VoiceListenDialogState();
}

class _VoiceListenDialogState extends State<_VoiceListenDialog>
    with SingleTickerProviderStateMixin {
  String _transcript = '';
  bool _isListening = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    // Auto-start after dialog is built (speech is already initialized in parent)
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  Future<void> _startListening() async {
    if (!mounted || widget.speech.isListening) return;
    setState(() { _isListening = true; _transcript = ''; });
    _pulseCtrl.repeat(reverse: true);
    await widget.speech.listen(
      onResult: (result) {
        if (mounted) setState(() => _transcript = result.recognizedWords);
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 4),
      localeId: widget.language == 'urdu' ? 'ur_PK' : 'en_US',
      partialResults: true,
    );
    if (mounted) {
      setState(() => _isListening = false);
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  Future<void> _stopListening() async {
    await widget.speech.stop();
    if (mounted) {
      setState(() => _isListening = false);
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    widget.speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title bar
              Row(children: [
                const Expanded(
                  child: Text('Voice Input',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ]),
              const SizedBox(height: 28),

              // Animated mic button
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _isListening ? _pulseAnim.value : 1.0,
                    child: child,
                  ),
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.red : Colors.green.shade100,
                      boxShadow: _isListening
                          ? [BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 20, spreadRadius: 6)]
                          : [],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 44,
                      color: _isListening ? Colors.white : Colors.green.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                _isListening
                    ? 'Listening... tap mic to stop'
                    : _transcript.isNotEmpty
                        ? 'Tap mic to speak again'
                        : 'Starting mic...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isListening ? Colors.red : Colors.grey,
                  fontSize: 14,
                  fontWeight: _isListening ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),

              // Transcript display box
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 70),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _transcript.isEmpty
                      ? (_isListening ? 'Speak now...' : 'Your speech will appear here')
                      : _transcript,
                  style: TextStyle(
                    color: _transcript.isEmpty ? Colors.grey : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _transcript.isEmpty
                        ? null
                        : () => Navigator.of(context).pop(_transcript),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Use This',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}