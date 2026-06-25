class Conversation {
  final String id;
  final int workPermitId;
  final String? workPermitRef;
  final String? receiverRole;
  final String? branchId;
  final String? branchName;
  final String? assignedToName;
  final String? assignedToCode;
  final String? assignedToRole;
  final String? status;
  final String createdAt;
  final String updatedAt;
  final String? lastMessageContent;
  final String? lastMessageTime;
  final int unreadCount;
  final String participantName;
  final String participantRole;
  final bool isOnline;
  final bool? isNew;

  Conversation({
    required this.id,
    required this.workPermitId,
    this.workPermitRef,
    this.receiverRole,
    this.branchId,
    this.branchName,
    this.assignedToName,
    this.assignedToCode,
    this.assignedToRole,
    this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageContent,
    this.lastMessageTime,
    required this.unreadCount,
    required this.participantName,
    required this.participantRole,
    required this.isOnline,
    this.isNew,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      workPermitId: json['workPermitId'] as int? ?? 0,
      workPermitRef: json['workPermitRef'] as String?,
      receiverRole: json['receiverRole'] as String?,
      branchId: json['branchId']?.toString(),
      branchName: json['branchName'] as String?,
      assignedToName: json['assignedToName'] as String?,
      assignedToCode: json['assignedToCode'] as String?,
      assignedToRole: json['assignedToRole'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      lastMessageContent: json['lastMessageContent'] as String?,
      lastMessageTime: json['lastMessageTime'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      participantName: json['participantName'] as String? ?? '',
      participantRole: json['participantRole'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      isNew: json['isNew'] as bool?,
    );
  }
}

class ChatMessage {
  final String id;
  final String? senderName;
  final String? senderRole;
  final String? senderExternalId;
  final String? senderUserCode;
  final String? content;
  final String timestamp;
  final bool isRead;
  final String? readAt;
  final String? attachmentUrl;
  final String? attachmentName;

  ChatMessage({
    required this.id,
    this.senderName,
    this.senderRole,
    this.senderExternalId,
    this.senderUserCode,
    this.content,
    required this.timestamp,
    required this.isRead,
    this.readAt,
    this.attachmentUrl,
    this.attachmentName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderName: json['senderName'] as String?,
      senderRole: json['senderRole'] as String?,
      senderExternalId: json['senderExternalId'] as String?,
      senderUserCode: json['senderUserCode'] as String?,
      content: json['content'] as String?,
      timestamp: json['timestamp'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentName: json['attachmentName'] as String?,
    );
  }
}

class ChatHistoryResponse {
  final List<ChatMessage> messages;
  final bool hasMore;
  final String? oldestId;

  ChatHistoryResponse({
    required this.messages,
    required this.hasMore,
    this.oldestId,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['hasMore'] as bool? ?? false,
      oldestId: json['oldestId'] as String?,
    );
  }
}
