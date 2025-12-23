import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';

class WebAdminChat extends StatefulWidget {
  const WebAdminChat({super.key});

  @override
  State<WebAdminChat> createState() => _WebAdminChatState();
}

class _WebAdminChatState extends State<WebAdminChat> {
  List<Map<String, dynamic>> _conversations = [];
  Map<String, dynamic>? _selectedConversation;
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  int? _getConversationId(Map<String, dynamic>? conversation) {
    if (conversation == null) return null;
    final rawId = conversation['admin_conversation_id'] ??
        conversation['conversation_id'] ??
        conversation['conversationId'] ??
        conversation['id'];
    if (rawId is int) return rawId;
    if (rawId is String) {
      final parsed = int.tryParse(rawId);
      if (parsed != null) return parsed;
    }
    if (rawId is double) return rawId.toInt();
    return null;
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/chat/conversations'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rawList = data['conversations'] ?? [];
        setState(() {
          _conversations = rawList.map((conv) {
            final normalized = Map<String, dynamic>.from(conv as Map);
            // Normalize conversation_id to int
            final id = _getConversationId(normalized);
            if (id != null) {
              normalized['admin_conversation_id'] = id;
              normalized['conversation_id'] = id;
            }
            // Normalize unread_count to int
            final unread = normalized['unread_count'];
            if (unread != null) {
              if (unread is String) {
                normalized['unread_count'] = int.tryParse(unread) ?? 0;
              } else if (unread is int) {
                normalized['unread_count'] = unread;
              } else {
                normalized['unread_count'] = 0;
              }
            } else {
              normalized['unread_count'] = 0;
            }
            return normalized;
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages(int conversationId) async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      // Ensure conversationId is properly converted to string for URL
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/chat/conversations/${conversationId.toString()}/messages',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage(int conversationId) async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/chat/conversations/$conversationId/messages',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'message_text': message}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _messageController.clear();
        _loadMessages(conversationId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi tin nhắn: $e')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _selectConversation(Map<String, dynamic> conversation) {
    final conversationId = _getConversationId(conversation);
    if (conversationId != null) {
      setState(() {
        _selectedConversation = conversation;
      });
      _loadMessages(conversationId);
    }
  }

  int _getUnreadCount(Map<String, dynamic> conversation) {
    return conversation['unread_count'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Conversations List
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.support_agent, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Hỗ trợ người dùng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadConversations,
                        tooltip: 'Làm mới',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _conversations.isEmpty
                      ? const Center(
                          child: Text('Không có cuộc trò chuyện nào'),
                        )
                      : ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = _conversations[index];
                            final isSelected = _selectedConversation != null &&
                                _getConversationId(_selectedConversation) ==
                                    _getConversationId(conversation);
                            final unreadCount = _getUnreadCount(conversation);

                            return ListTile(
                              selected: isSelected,
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  (conversation['user_email'] ?? 'U')[0]
                                      .toUpperCase(),
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                              title: Text(
                                conversation['user_email'] ?? 'Người dùng',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                conversation['subject'] ?? 'Hỗ trợ khách hàng',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: unreadCount > 0
                                  ? Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                              onTap: () => _selectConversation(conversation),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Chat View
          Expanded(
            child: _selectedConversation == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chọn cuộc trò chuyện để xem tin nhắn',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        // Chat Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  (_selectedConversation!['user_email'] ?? 'U')[0]
                                      .toUpperCase(),
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedConversation!['user_email'] ??
                                          'Người dùng',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _selectedConversation!['subject'] ??
                                          'Hỗ trợ khách hàng',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Messages
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _messages.isEmpty
                              ? const Center(
                                  child: Text('Chưa có tin nhắn nào'),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    final message = _messages[index];
                                    final isAdmin = message['sender_type'] == 'admin';

                                    return Align(
                                      alignment: isAdmin
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isAdmin
                                              ? Colors.blue.shade50
                                              : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              message['message_text'] ?? '',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              message['created_at']?.toString().split('T')[0] ??
                                                  '',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        // Message Input
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập tin nhắn...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  maxLines: null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: _isSending
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.send),
                                onPressed: _isSending
                                    ? null
                                    : () {
                                        final conversationId =
                                            _getConversationId(_selectedConversation);
                                        if (conversationId != null) {
                                          _sendMessage(conversationId);
                                        }
                                      },
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
