import 'dart:typed_data';

import 'package:rahmani_project/core/errors/exceptions.dart' as app_errors;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SupportRemoteDataSource {
  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String content,
    String? attachmentPath,
  });

  Future<List<dynamic>> fetchMyTickets();

  Future<Map<String, dynamic>> fetchTicketDetail(String ticketId);

  Future<String> postTicketMessage({
    required String ticketId,
    required String content,
    String? attachmentPath,
  });

  Future<void> attachMessageFile({
    required String messageId,
    required String attachmentPath,
  });

  Future<String> uploadAttachment({
    required String userId,
    required String ticketId,
    required List<int> bytes,
    required String fileExtension,
  });

  Future<String> createSignedAttachmentUrl(String attachmentPath);
}

final class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  SupportRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String content,
    String? attachmentPath,
  }) async {
    try {
      final data = await _client.rpc(
        'create_ticket',
        params: {
          'p_subject': subject,
          'p_content': content,
          'p_attachment_path': attachmentPath,
        },
      );
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<List<dynamic>> fetchMyTickets() async {
    try {
      final data = await _client.rpc('get_my_tickets');
      return data as List<dynamic>? ?? [];
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchTicketDetail(String ticketId) async {
    try {
      final data = await _client.rpc(
        'get_ticket_detail',
        params: {'p_ticket_id': ticketId},
      );
      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<String> postTicketMessage({
    required String ticketId,
    required String content,
    String? attachmentPath,
  }) async {
    try {
      final data = await _client.rpc(
        'send_ticket_message',
        params: {
          'p_ticket_id': ticketId,
          'p_content': content,
          'p_attachment_path': attachmentPath,
        },
      );
      return data as String;
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<void> attachMessageFile({
    required String messageId,
    required String attachmentPath,
  }) async {
    try {
      await _client.rpc(
        'set_ticket_message_attachment',
        params: {
          'p_message_id': messageId,
          'p_attachment_path': attachmentPath,
        },
      );
    } on PostgrestException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<String> uploadAttachment({
    required String userId,
    required String ticketId,
    required List<int> bytes,
    required String fileExtension,
  }) async {
    try {
      final path = '$userId/$ticketId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      await _client.storage.from('support-attachments').uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              contentType: _contentTypeForExtension(fileExtension),
            ),
          );
      return path;
    } on StorageException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  @override
  Future<String> createSignedAttachmentUrl(String attachmentPath) async {
    try {
      final url = await _client.storage
          .from('support-attachments')
          .createSignedUrl(attachmentPath, 3600);
      return url;
    } on StorageException catch (e) {
      throw app_errors.ServerException(e.message);
    }
  }

  String _contentTypeForExtension(String ext) {
    return switch (ext.toLowerCase()) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'pdf' => 'application/pdf',
      _ => 'image/jpeg',
    };
  }
}
