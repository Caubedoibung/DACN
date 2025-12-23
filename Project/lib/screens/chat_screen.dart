import 'dart:typed_data';
import '../config/api_config.dart';

import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/chat_service.dart';
import 'package:my_diary/services/social_service.dart';
import 'package:my_diary/services/ai_analysis_service.dart';
import 'package:my_diary/widgets/nutrition_result_table.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:my_diary/screens/ai_image_analysis_screen.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Chatbot tab state
  final TextEditingController _chatbotController = TextEditingController();
  List<Map<String, dynamic>> _chatbotMessages = [];
  bool _isLoadingChatbot = false;
  int? _chatbotConversationId;

  // Admin tab state
  final TextEditingController _adminController = TextEditingController();
  List<Map<String, dynamic>> _adminMessages = [];
  bool _isLoadingAdmin = false;
  int? _adminConversationId;
  bool _showBotTyping = false;

  // Community tab state
  final TextEditingController _communityController = TextEditingController();
  List<Map<String, dynamic>> _communityMessages = [];
  bool _isLoadingCommunity = false;
  final ScrollController _communityScrollController = ScrollController();
  Uint8List? _communityImageBytes;
  String? _communityImageMimeType;

  // Friends tab state
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _friendRequests = [];
  bool _isLoadingFriends = false;
  bool _isLoadingRequests = false;
  final Set<int> _friendIds = {};
  final Set<int> _pendingSentRequests = {};
  final Set<int> _incomingRequestUserIds = {};
  // ignore: unused_field
  bool _friendsLoaded = false;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // Scroll controllers
  final ScrollController _chatbotScrollController = ScrollController();
  final ScrollController _adminScrollController = ScrollController();
  final Set<dynamic> _animatedBotMessages = <dynamic>{};
  bool _nutritionSynced = false;
  late final AnimationController _typingController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _loadConversations();
    _loadFriends();
    _loadFriendRequests();
    _tabController.addListener(() {
      if (!mounted) return;
      if (_tabController.index == 2 &&
          _communityMessages.isEmpty &&
          !_isLoadingCommunity) {
        _loadCommunityMessages();
      } else if (_tabController.index == 3) {
        if (_friends.isEmpty && !_isLoadingFriends) {
          _loadFriends();
        }
        if (_friendRequests.isEmpty && !_isLoadingRequests) {
          _loadFriendRequests();
        }
      }
    });
  }

  Map<String, dynamic> _normalizeMessage(Map<String, dynamic> message) {
    final normalized = Map<String, dynamic>.from(message);
    final id = normalized['id'] ?? normalized['message_id'];
    if (id != null) normalized['id'] = id;
    return normalized;
  }

  String _formatAiAnalysisForChat(Map<String, dynamic> result) {
    final items = result['items'] as List<dynamic>? ?? [];
    if (items.isEmpty) return 'Không tìm thấy món ăn/đồ uống trong ảnh';

    final buffer = StringBuffer();
    buffer.writeln('🔍 **AI đã phân tích ảnh của bạn:**\n');

    for (var item in items) {
      final name = item['item_name'] ?? 'Món không xác định';
      final confidence = (item['confidence_score'] ?? 0.0).toDouble();
      final nutrients = item['nutrients'] as Map<String, dynamic>? ?? {};

      buffer.writeln(
        '📌 **$name** (${confidence.toStringAsFixed(1)}% chính xác)',
      );

      // Main nutrients
      if (nutrients['enerc_kcal'] != null && nutrients['enerc_kcal'] > 0) {
        buffer.writeln('   🔥 Calories: ${nutrients['enerc_kcal']} kcal');
      }
      if (nutrients['procnt'] != null && nutrients['procnt'] > 0) {
        buffer.writeln('   💪 Protein: ${nutrients['procnt']} g');
      }
      if (nutrients['fat'] != null && nutrients['fat'] > 0) {
        buffer.writeln('   🥑 Fat: ${nutrients['fat']} g');
      }
      if (nutrients['chocdf'] != null && nutrients['chocdf'] > 0) {
        buffer.writeln('   🍞 Carbs: ${nutrients['chocdf']} g');
      }
      if (item['water_ml'] != null && item['water_ml'] > 0) {
        buffer.writeln('   💧 Water: ${item['water_ml']} ml');
      }
      buffer.writeln('');
    }

    buffer.writeln('Nhấn "Chấp nhận" để lưu vào nhật ký!');
    return buffer.toString();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatbotController.dispose();
    _adminController.dispose();
    _communityController.dispose();
    _chatbotScrollController.dispose();
    _adminScrollController.dispose();
    _communityScrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    try {
      // Load chatbot conversation
      final chatbotConv = await ChatService.getChatbotConversation();
      if (chatbotConv != null && chatbotConv['conversation_id'] != null) {
        _chatbotConversationId = chatbotConv['conversation_id'];
        final chatbotMsgs = await ChatService.getChatbotMessages(
          _chatbotConversationId!,
        );

        if (mounted) {
          setState(() {
            _chatbotMessages = chatbotMsgs
                .map<Map<String, dynamic>>((m) => _normalizeMessage(m))
                .toList();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text(l10n.pleaseLoginToUseChat);
                },
              ),
            ),
          );
        }
        return;
      }

      // Load admin conversation
      final adminConv = await ChatService.getAdminConversation();
      if (adminConv != null && adminConv['admin_conversation_id'] != null) {
        _adminConversationId = adminConv['admin_conversation_id'];
        final adminMsgs = await ChatService.getAdminMessages(
          _adminConversationId!,
        );

        if (mounted) {
          setState(() {
            _adminMessages = adminMsgs
                .map<Map<String, dynamic>>((m) => _normalizeMessage(m))
                .toList();
          });
        }
      }

      if (mounted) {
        // Scroll to bottom
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToBottom(_chatbotScrollController);
          _scrollToBottom(_adminScrollController);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải tin nhắn: $e')));
      }
    }
  }

  Future<void> _loadCommunityMessages() async {
    if (_isLoadingCommunity) return;
    if (!mounted) return;

    setState(() => _isLoadingCommunity = true);

    try {
      final messages = await SocialService.getCommunityMessages();
      messages.sort((a, b) {
        final aDate =
            DateTime.tryParse(a['created_at']?.toString() ?? '') ??
            DateTime.now();
        final bDate =
            DateTime.tryParse(b['created_at']?.toString() ?? '') ??
            DateTime.now();
        return aDate.compareTo(bDate);
      });
      if (mounted) {
        setState(() {
          _communityMessages = messages;
          _isLoadingCommunity = false;
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _communityScrollController.hasClients) {
            _scrollToBottom(_communityScrollController);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCommunity = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tải tin nhắn cộng đồng: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  Future<void> _sendCommunityMessage() async {
    final text = _communityController.text.trim();
    if (text.isEmpty && _communityImageBytes == null) return;

    setState(() => _isLoadingCommunity = true);

    try {
      String? imageUrl;
      if (_communityImageBytes != null) {
        imageUrl = await SocialService.uploadImage(
          _communityImageBytes!,
          folder: 'community',
          mimeType: _communityImageMimeType,
          filename: 'community_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      await SocialService.postCommunityMessage(
        messageText: text.isEmpty ? null : text,
        imageUrl: imageUrl,
      );

      _communityController.clear();
      _selectedCommunityImage = null;
      _communityImageBytes = null;
      _communityImageMimeType = null;
      await _loadCommunityMessages();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCommunity = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi gửi tin nhắn: $e')));
      }
    }
  }

  // ignore: unused_field
  XFile? _selectedCommunityImage;

  void _setChatbotLoading(bool loading, {bool showTyping = false}) {
    if (!mounted) return;
    if (_isLoadingChatbot == loading && _showBotTyping == showTyping) {
      if (!loading) {
        _typingController.stop();
        _typingController.reset();
      }
      return;
    }
    setState(() {
      _isLoadingChatbot = loading;
      if (!loading) {
        _showBotTyping = false;
      } else if (showTyping) {
        _showBotTyping = true;
      }
    });
    if (loading && showTyping) {
      if (!_typingController.isAnimating) {
        _typingController.repeat();
      }
      _scrollToBottom(_chatbotScrollController);
    } else if (!loading) {
      _typingController.stop();
      _typingController.reset();
    }
  }

  void _scrollToBottom(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendChatbotMessage() async {
    final text = _chatbotController.text.trim();
    if (text.isEmpty || _chatbotConversationId == null) return;

    _chatbotController.clear();
    _setChatbotLoading(true, showTyping: true);

    try {
      final response = await ChatService.sendChatbotMessage(
        _chatbotConversationId!,
        text,
      );

      if (mounted) {
        setState(() {
          if (response?['userMessage'] != null) {
            _chatbotMessages.add(_normalizeMessage(response!['userMessage']));
          }
          if (response?['botMessage'] != null) {
            _chatbotMessages.add(_normalizeMessage(response!['botMessage']));
          }
        });
        _setChatbotLoading(false);
        _scrollToBottom(_chatbotScrollController);
      }
    } catch (e) {
      if (mounted) {
        _setChatbotLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text('${l10n.errorSendingMessage}: $e');
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendAdminMessage() async {
    final text = _adminController.text.trim();
    if (text.isEmpty || _adminConversationId == null) return;

    _adminController.clear();
    setState(() => _isLoadingAdmin = true);

    try {
      final message = await ChatService.sendAdminMessage(
        _adminConversationId!,
        text,
      );

      if (mounted && message != null) {
        setState(() {
          final normalized = Map<String, dynamic>.from(
            message['message'] ?? message,
          );
          _adminMessages.add(_normalizeMessage(normalized));
          _isLoadingAdmin = false;
        });
        _scrollToBottom(_adminScrollController);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAdmin = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text('${l10n.errorSendingMessage}: $e');
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickImageForChatbot() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      _setChatbotLoading(true, showTyping: true);

      // Use new AI Analysis service
      final result = await AiAnalysisService.analyzeImage(File(image.path));

      if (mounted) {
        if (result.isNotEmpty) {
          setState(() {
            // Add user message with image
            _chatbotMessages.add({
              'role': 'user',
              'content': '[Đã gửi ảnh đồ ăn/đồ uống]',
              'timestamp': DateTime.now().toIso8601String(),
            });

            // Add AI analysis result
            _chatbotMessages.add({
              'role': 'assistant',
              'content': _formatAiAnalysisForChat({'items': result}),
              'ai_analysis': result,
              'timestamp': DateTime.now().toIso8601String(),
            });
          });
          _scrollToBottom(_chatbotScrollController);
        }
        _setChatbotLoading(false);
      }
    } catch (e) {
      if (mounted) {
        _setChatbotLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text('${l10n.errorAnalyzingImage}: $e');
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickImageForAdmin() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null || _adminConversationId == null) return;

      setState(() => _isLoadingAdmin = true);

      final message = await ChatService.sendAdminMessage(
        _adminConversationId!,
        'Đã gửi ảnh',
        imageUrl: image.path,
      );

      if (mounted && message != null) {
        setState(() {
          final normalized = Map<String, dynamic>.from(
            message['message'] ?? message,
          );
          _adminMessages.add(_normalizeMessage(normalized));
          _isLoadingAdmin = false;
        });
        _scrollToBottom(_adminScrollController);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAdmin = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text('${l10n.errorSendingImage}: $e');
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _approveNutrition(int messageId, bool approve) async {
    _setChatbotLoading(true);

    try {
      final response = await ChatService.approveNutrition(messageId, approve);

      if (!mounted) return;
      final index = _chatbotMessages.indexWhere(
        (m) => (m['id'] ?? m['message_id']) == messageId,
      );
      if (index != -1) {
        setState(() {
          _chatbotMessages[index]['is_approved'] = approve;
        });
      }

      if (approve && response != null && response['today'] != null) {
        final today = Map<String, dynamic>.from(response['today']);
        final profile = context.maybeProfile();
        profile?.applyTodayTotals({
          'today_calories': today['today_calories'],
          'today_protein': today['today_protein'],
          'today_fat': today['today_fat'],
          'today_carbs': today['today_carbs'],
        });
        setState(() => _nutritionSynced = true);
      }

      _setChatbotLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? '✓ Đã lưu thông tin dinh dưỡng vào ngày hôm nay'
                : 'Đã từ chối kết quả phân tích',
          ),
          backgroundColor: approve ? Colors.green : null,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        _setChatbotLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text('${l10n.errorProcessing}: $e');
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          Navigator.of(context).pop(_nutritionSynced);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            'Trò chuyện',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(_nutritionSynced),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: Color(0xFF667EEA)),
              tooltip: 'Phân tích hình ảnh AI',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AiImageAnalysisScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF667EEA),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF667EEA),
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            tabs: const [
              Tab(icon: Icon(Icons.smart_toy), text: 'AI Chatbot'),
              Tab(icon: Icon(Icons.support_agent), text: 'Hỗ trợ Admin'),
              Tab(icon: Icon(Icons.people), text: 'Cộng đồng'),
              Tab(icon: Icon(Icons.person_add), text: 'Bạn bè'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildChatbotTab(),
            _buildAdminTab(),
            _buildCommunityTab(),
            _buildFriendsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatbotTab() {
    final showTyping = _showBotTyping;
    final shouldShowList = _chatbotMessages.isNotEmpty || showTyping;

    return Column(
      children: [
        Expanded(
          child: shouldShowList
              ? ListView.builder(
                  controller: _chatbotScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatbotMessages.length + (showTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (showTyping && index == _chatbotMessages.length) {
                      return _buildTypingIndicator();
                    }
                    final message = _chatbotMessages[index];
                    return _buildChatbotMessage(message);
                  },
                )
              : _buildEmptyState(
                  icon: Icons.smart_toy,
                  title: 'AI Assistant',
                  subtitle:
                      'Hỏi tôi về dinh dưỡng hoặc gửi ảnh món ăn để phân tích',
                ),
        ),
        _buildChatbotInput(),
      ],
    );
  }

  Widget _buildAdminTab() {
    return Column(
      children: [
        Expanded(
          child: _adminMessages.isEmpty
              ? _buildEmptyState(
                  icon: Icons.support_agent,
                  title: 'Hỗ trợ Admin',
                  subtitle: 'Gửi tin nhắn cho admin để được hỗ trợ',
                )
              : ListView.builder(
                  controller: _adminScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _adminMessages.length,
                  itemBuilder: (context, index) {
                    final message = _adminMessages[index];
                    return _buildAdminMessage(message);
                  },
                ),
        ),
        if (_isLoadingAdmin)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Đang gửi...',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        _buildAdminInput(),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 64, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatbotMessage(Map<String, dynamic> message) {
    final isBot = message['sender'] == 'bot' || message['role'] == 'assistant';
    final hasNutrition = message['nutrition_data'] != null;
    final hasAiAnalysis = message['ai_analysis'] != null;
    final messageId = message['id'] ?? message['message_id'];
    final bool shouldAnimate =
        isBot && messageId != null && !_animatedBotMessages.contains(messageId);

    Widget content = Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isBot
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            if (message['image_url'] != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "${ApiConfig.baseUrl}${message['image_url']}",
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 50),
                      );
                    },
                  ),
                ),
              ),
            if ((message['message_text'] ??
                        message['message'] ??
                        message['content'])
                    ?.toString()
                    .isNotEmpty ==
                true)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isBot ? Colors.white : const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  (message['message_text'] ??
                              message['message'] ??
                              message['content'])
                          ?.toString() ??
                      '',
                  style: TextStyle(
                    color: isBot ? Colors.black87 : Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            if (hasNutrition) _buildNutritionResult(message),
            if (hasAiAnalysis) _buildAiAnalysisActions(message),
            const SizedBox(height: 4),
            Text(
              _formatTime(message['created_at'] ?? message['timestamp']),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );

    if (shouldAnimate) {
      _animatedBotMessages.add(messageId);
      content = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 350),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 24),
              child: child,
            ),
          );
        },
        child: content,
      );
    }

    return content;
  }

  Widget _buildNutritionResult(Map<String, dynamic> message) {
    final nutritionData = message['nutrition_data'];
    final isApproved = nutritionData['is_approved'];

    // Don't show if already processed
    if (isApproved != null) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isApproved ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isApproved ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isApproved ? Icons.check_circle : Icons.cancel,
              color: isApproved ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isApproved ? 'Đã lưu vào nhật ký' : 'Đã từ chối',
              style: TextStyle(
                color: isApproved ? Colors.green.shade700 : Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return NutritionResultTable(
      foodName: nutritionData['food_name'] ?? 'Món ăn',
      confidence: (nutritionData['confidence'] ?? 0.0).toDouble(),
      nutrients: List<Map<String, dynamic>>.from(
        nutritionData['nutrients'] ?? [],
      ),
      onApprove: () =>
          _approveNutrition(message['id'] ?? message['message_id'], true),
      onReject: () =>
          _approveNutrition(message['id'] ?? message['message_id'], false),
      isLoading: _isLoadingChatbot,
    );
  }

  Widget _buildAiAnalysisActions(Map<String, dynamic> message) {
    final aiAnalysis = message['ai_analysis'] as List<dynamic>? ?? [];
    if (aiAnalysis.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () => _acceptAiAnalysisFromChat(aiAnalysis),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Chấp nhận'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _chatbotMessages.removeWhere((m) => m == message);
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptAiAnalysisFromChat(List<dynamic> items) async {
    try {
      for (var item in items) {
        final id = item['id'];
        if (id != null) {
          await AiAnalysisService.acceptAnalysis(id);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã lưu vào nhật ký!'),
            backgroundColor: Colors.green,
          ),
        );

        // Remove message after accepting
        setState(() {
          _chatbotMessages.removeWhere((m) => m['ai_analysis'] == items);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildAdminMessage(Map<String, dynamic> message) {
    final isAdmin = message['sender_type'] == 'admin';

    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isAdmin
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            if (message['image_url'] != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "${ApiConfig.baseUrl}${message['image_url']}",
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 50),
                      );
                    },
                  ),
                ),
              ),
            if ((message['message_text'] ?? message['message'])
                    ?.toString()
                    .isNotEmpty ==
                true)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? Colors.amber.shade50
                      : const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(16),
                  border: isAdmin
                      ? Border.all(color: Colors.amber.shade200)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              size: 14,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      (message['message_text'] ?? message['message'])
                              ?.toString() ??
                          '',
                      style: TextStyle(
                        color: isAdmin ? Colors.black87 : Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message['created_at']),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                if (!isAdmin && message['is_read'] == true) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.done_all, size: 14, color: Colors.blue.shade400),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _typingController,
              builder: (context, child) {
                final progress = (_typingController.value + index * 0.2) % 1.0;
                final scale = 0.6 + 0.4 * (1 - ((progress - 0.5).abs() * 2));
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF667EEA,
                        ).withOpacity(0.5 + 0.4 * scale),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildChatbotInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isLoadingChatbot ? null : _pickImageForChatbot,
            icon: Icon(
              Icons.photo_camera,
              color: _isLoadingChatbot ? Colors.grey : const Color(0xFF667EEA),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _chatbotController,
              enabled: !_isLoadingChatbot,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendChatbotMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF667EEA),
            child: IconButton(
              onPressed: _isLoadingChatbot ? null : _sendChatbotMessage,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isLoadingAdmin ? null : _pickImageForAdmin,
            icon: Icon(
              Icons.photo,
              color: _isLoadingAdmin ? Colors.grey : const Color(0xFF667EEA),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _adminController,
              enabled: !_isLoadingAdmin,
              decoration: InputDecoration(
                hintText: 'Gửi tin nhắn cho admin...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendAdminMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF667EEA),
            child: IconButton(
              onPressed: _isLoadingAdmin ? null : _sendAdminMessage,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    try {
      final DateTime dtUtc = timestamp is DateTime
          ? timestamp
          : DateTime.parse(timestamp.toString());
      final dt = dtUtc.toLocal();

      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inMinutes < 1) {
        return 'Vừa xong';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return DateFormat('dd/MM/yyyy HH:mm').format(dt);
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildCommunityTab() {
    return Column(
      children: [
        Expanded(
          child: _isLoadingCommunity && _communityMessages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _communityMessages.isEmpty
              ? _buildEmptyState(
                  icon: Icons.people_outline,
                  title: 'Chưa có tin nhắn',
                  subtitle: 'Hãy là người đầu tiên chia sẻ!',
                )
              : RefreshIndicator(
                  onRefresh: _loadCommunityMessages,
                  child: ListView.builder(
                    controller: _communityScrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _communityMessages.length,
                    itemBuilder: (context, index) {
                      return _buildCommunityMessage(_communityMessages[index]);
                    },
                  ),
                ),
        ),
        _buildCommunityInput(),
      ],
    );
  }

  Widget _buildCommunityMessage(Map<String, dynamic> message) {
    final profile = context.maybeProfile();
    final currentUserId = profile?.raw?['user_id'];
    final userId = (message['user_id'] as num?)?.toInt();
    final isMe = userId != null && userId == currentUserId;
    final username = message['username']?.toString() ?? 'Người dùng';
    final avatarUrl = _resolveImageUrl(message['avatar_url']?.toString());
    final gender = message['gender']?.toString().toLowerCase() ?? '';
    final isFriend = userId != null && _friendIds.contains(userId);
    final isPendingRequest =
        userId != null &&
        (_pendingSentRequests.contains(userId) ||
            _incomingRequestUserIds.contains(userId));
    final canSendFriendRequest = !isMe && userId != null && !isFriend;
    final timestamp = _formatMessageTime(message['created_at']?.toString());
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * (isMe ? 0.75 : 0.65);

    Widget buildAvatar() {
      return CircleAvatar(
        radius: 20,
        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
            ? NetworkImage(avatarUrl)
            : null,
        backgroundColor: gender == 'male'
            ? Colors.blue.withValues(alpha: 0.3)
            : gender == 'female'
            ? Colors.pink.withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.3),
        child: avatarUrl == null || avatarUrl.isEmpty
            ? Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            GestureDetector(
              onTap: userId != null
                  ? () => _showUserProfile(userId, username, avatarUrl, gender)
                  : null,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      buildAvatar(),
                      if (canSendFriendRequest)
                        Positioned(
                          bottom: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: isPendingRequest
                                ? null
                                : () => _sendFriendRequest(userId),
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: isPendingRequest
                                  ? Colors.grey
                                  : const Color(0xFF667EEA),
                              child: Icon(
                                isPendingRequest
                                    ? Icons.hourglass_bottom
                                    : Icons.person_add,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Icon(
                    gender == 'male'
                        ? Icons.male
                        : gender == 'female'
                        ? Icons.female
                        : Icons.person,
                    size: 12,
                    color: gender == 'male'
                        ? Colors.blue
                        : gender == 'female'
                        ? Colors.pink
                        : Colors.grey,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF667EEA) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (canSendFriendRequest)
                            GestureDetector(
                              onTap: isPendingRequest
                                  ? null
                                  : () => _sendFriendRequest(userId),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: isPendingRequest
                                    ? Colors.grey
                                    : const Color(0xFF667EEA),
                                child: Icon(
                                  isPendingRequest
                                      ? Icons.hourglass_bottom
                                      : Icons.person_add,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (message['message_text'] != null)
                      Text(
                        (message['message_text'] ?? '').toString(),
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    if (message['image_url'] != null) ...[
                      if (message['message_text'] != null)
                        const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _resolveImageUrl(message['image_url']?.toString()) ??
                              '',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image);
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      timestamp,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) ...[const SizedBox(width: 8), buildAvatar()],
        ],
      ),
    );
  }

  Widget _buildCommunityInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isLoadingCommunity
                ? null
                : () async {
                    final image = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null && mounted) {
                      final bytes = await image.readAsBytes();
                      setState(() {
                        _selectedCommunityImage = image;
                        _communityImageBytes = bytes;
                        _communityImageMimeType = image.mimeType ?? 'image/png';
                      });
                    }
                  },
            icon: Icon(
              Icons.photo_library,
              color: _isLoadingCommunity
                  ? Colors.grey
                  : const Color(0xFF667EEA),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _communityController,
              decoration: const InputDecoration(
                hintText: 'Chia sẻ kinh nghiệm...',
                border: InputBorder.none,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendCommunityMessage(),
            ),
          ),
          if (_communityImageBytes != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _communityImageBytes!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCommunityImage = null;
                          _communityImageBytes = null;
                          _communityImageMimeType = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            onPressed: _isLoadingCommunity ? null : _sendCommunityMessage,
            icon: Icon(
              Icons.send,
              color: _isLoadingCommunity
                  ? Colors.grey
                  : const Color(0xFF667EEA),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final dt = DateTime.parse(timeStr).toLocal();
      return DateFormat('HH:mm • dd/MM').format(dt);
    } catch (e) {
      return '';
    }
  }

  String? _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${AuthService.baseUrl}$url';
  }

  // ignore: unused_element
  bool _isFriend(int? userId) {
    if (userId == null) return false;
    return _friendIds.contains(userId);
  }

  Future<void> _sendFriendRequest(int userId) async {
    try {
      await SocialService.sendFriendRequest(userId);
      if (mounted) {
        setState(() {
          _pendingSentRequests.add(userId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã gửi lời mời kết bạn')));
        _loadFriendRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  Future<void> _showUserProfile(
    int userId,
    String username,
    String? avatarUrl,
    String gender,
  ) async {
    try {
      final resolvedAvatar = _resolveImageUrl(avatarUrl);
      final measurements = await SocialService.getUserBodyMeasurements(userId);
      if (!mounted) return;

      final sorted = List<Map<String, dynamic>>.from(measurements);
      sorted.sort((a, b) {
        final aDate =
            DateTime.tryParse(a['measurement_date']?.toString() ?? '') ??
            DateTime(1970);
        final bDate =
            DateTime.tryParse(b['measurement_date']?.toString() ?? '') ??
            DateTime(1970);
        return bDate.compareTo(aDate);
      });

      showDialog(
        context: context,
        builder: (dialogCtx) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Material(
                borderRadius: BorderRadius.circular(28),
                clipBehavior: Clip.antiAlias,
                color:
                    Theme.of(dialogCtx).dialogTheme.backgroundColor ??
                    Theme.of(dialogCtx).colorScheme.surface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                resolvedAvatar != null &&
                                    resolvedAvatar.isNotEmpty
                                ? NetworkImage(resolvedAvatar)
                                : null,
                            backgroundColor: gender == 'male'
                                ? Colors.blue.withValues(alpha: 0.2)
                                : gender == 'female'
                                ? Colors.pink.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.2),
                            child:
                                (resolvedAvatar == null ||
                                    resolvedAvatar.isEmpty)
                                ? Text(
                                    username.isNotEmpty
                                        ? username[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      gender == 'male'
                                          ? Icons.male
                                          : gender == 'female'
                                          ? Icons.female
                                          : Icons.person,
                                      size: 16,
                                      color: gender == 'male'
                                          ? Colors.blue
                                          : gender == 'female'
                                          ? Colors.pink
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      gender == 'male'
                                          ? 'Nam'
                                          : gender == 'female'
                                          ? 'Nữ'
                                          : 'Khác',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (sorted.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'Chưa có dữ liệu đo lường cơ thể',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      else ...[
                        _buildMeasurementDialogCard(dialogCtx, sorted.first),
                        if (sorted.length > 1) ...[
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Lịch sử gần đây',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...sorted
                              .skip(1)
                              .take(4)
                              .map((m) => _buildMeasurementHistoryTile(m)),
                        ],
                      ],
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          child: const Text('Đóng'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  Widget _buildMeasurementDialogCard(
    BuildContext context,
    Map<String, dynamic> measurement,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final weightKg = _toDouble(measurement['weight_kg']) ?? 0;
    final weightLbs = weightKg * 2.20462;
    final heightCm = _toDouble(measurement['height_cm']) ?? 0;
    final bmi = _toDouble(measurement['bmi']) ?? 0;
    final score =
        int.tryParse(measurement['bmi_score']?.toString() ?? '5') ?? 5;
    final category = measurement['bmi_category']?.toString();
    final measurementDate = measurement['measurement_date']?.toString();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FitnessAppTheme.white,
            FitnessAppTheme.white.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(68),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.weight,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: FitnessAppTheme.grey.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          weightLbs.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w700,
                            fontSize: 36,
                            color: FitnessAppTheme.nearlyDarkBlue,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6, bottom: 6),
                          child: Text(
                            l10n.lbs,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: FitnessAppTheme.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatMeasurementTimestamp(measurementDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FitnessAppTheme.nearlyDarkBlue.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${weightKg.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: FitnessAppTheme.nearlyDarkBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMeasurementStat(
                        value: '${heightCm.toStringAsFixed(0)} cm',
                        label: l10n.height,
                      ),
                      const SizedBox(height: 20),
                      _buildMeasurementStat(
                        value: '${bmi.toStringAsFixed(1)} BMI',
                        label: _measurementCategoryText(l10n, category),
                      ),
                    ],
                  ),
                ),
                _buildMeasurementScoreCircle(score, l10n),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementStat({required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMeasurementScoreCircle(int score, AppLocalizations l10n) {
    final normalized = (score.clamp(0, 10)) / 10;
    final color = _measurementScoreColor(score);
    final label = _measurementScoreLabel(l10n, score);

    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: CircularProgressIndicator(
              value: normalized,
              color: color,
              strokeWidth: 8,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementHistoryTile(Map<String, dynamic> measurement) {
    final weight = _toDouble(measurement['weight_kg']);
    final bmi = _toDouble(measurement['bmi']);
    final iso = measurement['measurement_date']?.toString();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMeasurementTimestamp(iso),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (weight != null)
                      'Cân nặng: ${weight.toStringAsFixed(1)} kg',
                    if (bmi != null) 'BMI: ${bmi.toStringAsFixed(1)}',
                  ].join(' • '),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _measurementCategoryText(AppLocalizations l10n, String? category) {
    switch (category) {
      case 'severely_underweight':
        return l10n.severelyUnderweight;
      case 'underweight':
      case 'mild_underweight':
        return l10n.underweight;
      case 'normal':
      case 'optimal':
        return l10n.normal;
      case 'normal_high':
        return l10n.slightlyOverweight;
      case 'overweight':
        return l10n.overweight;
      case 'obese_class_1':
      case 'obese_class_2':
      case 'obese_class_3':
        return l10n.obese;
      default:
        return l10n.notDetermined;
    }
  }

  Color _measurementScoreColor(int score) {
    if (score >= 9) return const Color(0xFF00E676);
    if (score >= 7) return const Color(0xFF76FF03);
    if (score >= 5) return const Color(0xFFFFD600);
    if (score >= 3) return const Color(0xFFFF6D00);
    return const Color(0xFFDD2C00);
  }

  String _measurementScoreLabel(AppLocalizations l10n, int score) {
    if (score >= 9) return l10n.perfect;
    if (score >= 7) return l10n.good;
    if (score >= 5) return l10n.normal;
    if (score >= 3) return l10n.needAttention;
    return l10n.needImprovement;
  }

  String _formatMeasurementTimestamp(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Future<void> _loadFriends() async {
    if (_isLoadingFriends) return;
    if (!mounted) return;

    setState(() => _isLoadingFriends = true);

    try {
      final friends = await SocialService.getFriends();
      if (mounted) {
        setState(() {
          _friends = friends;
          _friendIds
            ..clear()
            ..addAll(
              friends
                  .map((f) => (f['friend_id'] as num?)?.toInt())
                  .whereType<int>(),
            );
          _pendingSentRequests.removeWhere((id) => _friendIds.contains(id));
          _friendsLoaded = true;
          _isLoadingFriends = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFriends = false);
      }
    }
  }

  Future<void> _loadFriendRequests() async {
    if (_isLoadingRequests) return;
    if (!mounted) return;

    setState(() => _isLoadingRequests = true);

    try {
      final requests = await SocialService.getFriendRequests(type: 'received');
      if (mounted) {
        setState(() {
          _friendRequests = List<Map<String, dynamic>>.from(requests)
            ..sort((a, b) {
              final aDate =
                  DateTime.tryParse(a['created_at']?.toString() ?? '') ??
                  DateTime.now();
              final bDate =
                  DateTime.tryParse(b['created_at']?.toString() ?? '') ??
                  DateTime.now();
              return aDate.compareTo(bDate);
            });
          _incomingRequestUserIds
            ..clear()
            ..addAll(
              _friendRequests
                  .map((req) => (req['sender_id'] as num?)?.toInt())
                  .whereType<int>(),
            );
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRequests = false);
      }
    }
  }

  Widget _buildFriendsTab() {
    return Column(
      children: [
        // Friend requests section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lời mời kết bạn',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadFriendRequests,
                  ),
                ],
              ),
              if (_isLoadingRequests)
                const Center(child: CircularProgressIndicator())
              else if (_friendRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Không có lời mời kết bạn nào'),
                )
              else
                SizedBox(
                  height: 170,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: _friendRequests.length,
                    itemBuilder: (context, index) {
                      final request = _friendRequests[index];
                      return _buildFriendRequestCard(request);
                    },
                  ),
                ),
            ],
          ),
        ),
        // Friends list
        Expanded(
          child: _isLoadingFriends
              ? const Center(child: CircularProgressIndicator())
              : _friends.isEmpty
              ? const Center(child: Text('Chưa có bạn bè'))
              : RefreshIndicator(
                  onRefresh: _loadFriends,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      return _buildFriendCard(_friends[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFriendRequestCard(Map<String, dynamic> request) {
    final username = request['username']?.toString() ?? 'Người dùng';
    final avatarUrl = _resolveImageUrl(request['avatar_url']?.toString());
    final gender = request['gender']?.toString().toLowerCase() ?? '';

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                backgroundColor: gender == 'male'
                    ? Colors.blue.withValues(alpha: 0.3)
                    : gender == 'female'
                    ? Colors.pink.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.3),
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                username,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 16,
                    ),
                    onPressed: () => _respondToFriendRequest(
                      request['request_id'],
                      'accept',
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: const Icon(Icons.close, color: Colors.red, size: 16),
                    onPressed: () => _respondToFriendRequest(
                      request['request_id'],
                      'reject',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    final username = friend['username']?.toString() ?? 'Người dùng';
    final avatarUrl = _resolveImageUrl(friend['avatar_url']?.toString());
    final gender = friend['gender']?.toString().toLowerCase() ?? '';
    final friendId = (friend['friend_id'] as num?)?.toInt();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          backgroundColor: gender == 'male'
              ? Colors.blue.withValues(alpha: 0.3)
              : gender == 'female'
              ? Colors.pink.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(username),
        subtitle: Row(
          children: [
            Icon(
              gender == 'male'
                  ? Icons.male
                  : gender == 'female'
                  ? Icons.female
                  : Icons.person,
              size: 16,
              color: gender == 'male'
                  ? Colors.blue
                  : gender == 'female'
                  ? Colors.pink
                  : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              gender == 'male'
                  ? 'Nam'
                  : gender == 'female'
                  ? 'Nữ'
                  : 'Khác',
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chat),
          onPressed: friendId != null
              ? () => _openPrivateChat(friendId, username, avatarUrl, gender)
              : null,
        ),
        onTap: friendId != null
            ? () => _showUserProfile(friendId, username, avatarUrl, gender)
            : null,
      ),
    );
  }

  Future<void> _respondToFriendRequest(int requestId, String action) async {
    try {
      await SocialService.respondToFriendRequest(requestId, action);
      if (mounted) {
        setState(() {
          final request = _friendRequests.firstWhere(
            (r) => r['request_id'] == requestId,
            orElse: () => {},
          );
          final userId = (request['sender_id'] as num?)?.toInt();
          if (userId != null) {
            _incomingRequestUserIds.remove(userId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'accept'
                  ? 'Đã chấp nhận lời mời'
                  : 'Đã từ chối lời mời',
            ),
          ),
        );
        _loadFriendRequests();
        _loadFriends();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  Future<void> _openPrivateChat(
    int friendId,
    String friendName,
    String? avatarUrl,
    String gender,
  ) async {
    try {
      final profile = context.maybeProfile();
      final currentUserId = (profile?.raw?['user_id'] as num?)?.toInt();
      final conversation = await SocialService.getOrCreatePrivateConversation(
        friendId,
      );
      final conversationData =
          (conversation['conversation'] ?? conversation)
              as Map<String, dynamic>?;
      final conversationId = (conversationData?['conversation_id'] as num?)
          ?.toInt();

      if (!mounted) return;

      if (conversationId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể mở đoạn chat')));
        return;
      }

      final sheetFriendName =
          conversationData?['friend_username']?.toString() ?? friendName;
      final sheetFriendAvatar =
          _resolveImageUrl(
            conversationData?['friend_avatar_url']?.toString(),
          ) ??
          avatarUrl;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => PrivateChatSheet(
          conversationId: conversationId,
          friendId: friendId,
          friendName: sheetFriendName,
          friendAvatar: sheetFriendAvatar,
          friendGender: gender,
          currentUserId: currentUserId,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }
}

class PrivateChatSheet extends StatefulWidget {
  final int conversationId;
  final int friendId;
  final String friendName;
  final String? friendAvatar;
  final String friendGender;
  final int? currentUserId;

  const PrivateChatSheet({
    super.key,
    required this.conversationId,
    required this.friendId,
    required this.friendName,
    required this.friendAvatar,
    required this.friendGender,
    required this.currentUserId,
  });

  @override
  State<PrivateChatSheet> createState() => _PrivateChatSheetState();
}

class _PrivateChatSheetState extends State<PrivateChatSheet> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final msgs = await SocialService.getPrivateMessages(
        widget.conversationId,
      );
      if (!mounted) return;
      setState(() {
        _messages = msgs;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải tin nhắn: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      await SocialService.sendPrivateMessage(
        conversationId: widget.conversationId,
        messageText: text,
      );
      if (!mounted) return;
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không gửi được: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          (widget.friendAvatar != null &&
                              widget.friendAvatar!.isNotEmpty)
                          ? NetworkImage(widget.friendAvatar!)
                          : null,
                      backgroundColor: widget.friendGender == 'male'
                          ? Colors.blue.withValues(alpha: 0.2)
                          : widget.friendGender == 'female'
                          ? Colors.pink.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      child:
                          (widget.friendAvatar == null ||
                              widget.friendAvatar!.isEmpty)
                          ? Text(
                              widget.friendName.isNotEmpty
                                  ? widget.friendName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.friendName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đoạn chat riêng tư',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                    ? const Center(child: Text('Hãy gửi lời chào đầu tiên!'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: Icon(
                        Icons.send,
                        color: _isSending
                            ? Colors.grey
                            : const Color(0xFF667EEA),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final senderId = (message['sender_id'] as num?)?.toInt();
    final isMe =
        widget.currentUserId != null && senderId == widget.currentUserId;
    final text = message['message_text']?.toString() ?? '';
    final timeLabel = _formatTimestamp(message['created_at']?.toString());

    final bubbleColor = isMe
        ? const Color(0xFF667EEA)
        : Colors.grey.withValues(alpha: 0.2);
    final textColor = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe)
              Text(
                message['username']?.toString() ?? '',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isMe ? Colors.white70 : Colors.grey[700],
                ),
              ),
            if (!isMe) const SizedBox(height: 4),
            Text(text, style: TextStyle(color: textColor, fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              timeLabel,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('HH:mm • dd/MM').format(dt);
    } catch (_) {
      return '';
    }
  }
}
