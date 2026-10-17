import 'dart:async';

import 'package:rahmani_project/core/constants/pagination_constants.dart';
import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:rahmani_project/features/chat/data/models/chat_models.dart';
import 'package:rahmani_project/features/chat/domain/entities/chat_entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ChatRemoteDataSource {
  Future<String> createConversation(String boothId);

  Future<String> postMessage({
    required String conversationId,
    required String content,
  });

  Future<List<dynamic>> fetchConversations();

  Future<List<dynamic>> fetchMessages(
    String conversationId, {
    int limit = PaginationConstants.chatMessagePageSize,
    DateTime? beforeCreatedAt,
  });

  Future<void> markRead(String conversationId);

  Stream<MessageEntity> subscribeToMessages(String conversationId);
}

final class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<String> createConversation(String boothId) async {
    try {
      final data = await _client.rpc('start_conversation', params: {'p_booth_id': boothId});
      return data as String;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<String> postMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final data = await _client.rpc(
        'send_message',
        params: {
          'p_conversation_id': conversationId,
          'p_content': content,
        },
      );
      return data as String;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchConversations() async {
    try {
      final data = await _client.rpc('get_my_conversations');
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchMessages(
    String conversationId, {
    int limit = PaginationConstants.chatMessagePageSize,
    DateTime? beforeCreatedAt,
  }) async {
    try {
      final data = await _client.rpc(
        'get_conversation_messages',
        params: {
          'p_conversation_id': conversationId,
          'p_limit': limit,
          if (beforeCreatedAt != null)
            'p_before_created_at': beforeCreatedAt.toUtc().toIso8601String(),
        },
      );
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> markRead(String conversationId) async {
    try {
      await _client.rpc('mark_messages_read', params: {'p_conversation_id': conversationId});
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Stream<MessageEntity> subscribeToMessages(String conversationId) {
    final controller = StreamController<MessageEntity>.broadcast();
    final channel = _client.channel('conversation:$conversationId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isEmpty) return;
            controller.add(ChatModels.messageFromJson(Map<String, dynamic>.from(record)));
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isEmpty) return;
            controller.add(ChatModels.messageFromJson(Map<String, dynamic>.from(record)));
          },
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }
}
