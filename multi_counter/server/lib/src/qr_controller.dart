import 'dart:async';
import 'dart:convert';

import 'package:firebase_functions/firebase_functions.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

import 'helpers.dart';
import 'html_generator.dart';

final class QrController {
  final Firestore _firestore;
  var _instanceCount = 0;
  final _startTime = DateTime.now();

  QrController(this._firestore);

  Future<Response> handleRequest(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final emojiName = queryParams['emoji'];

      if (emojiName != null && _isValidEmoji(emojiName)) {
        await _incrementEmoji(emojiName);
        await updateGlobalCount(_firestore);
        return Response.ok(
          jsonEncode({
            'uptime': _formatDuration(DateTime.now().difference(_startTime)),
            'count': _instanceCount,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        _instanceCount++;
        await _incrementQrScan();
        await updateGlobalCount(_firestore);
        return Response.ok(
          generateHtml(
            uptime: _formatDuration(DateTime.now().difference(_startTime)),
            instanceCount: _instanceCount,
          ),
          headers: {'Content-Type': 'text/html; charset=utf-8'},
        );
      }
    } catch (e, stack) {
      print('Error handling QR Scan request');
      print(e);
      print(stack);
      return Response.internalServerError(body: 'Internal Server Error');
    }
  }

  bool _isValidEmoji(String name) => emojiFields.containsKey(name);

  Future<void> _incrementField(
    DocumentReference<Map<String, Object?>> docRef,
    String fieldName,
  ) async {
    await _firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set<Map<String, Object?>>(docRef, <String, Object?>{
          fieldName: 1,
        });
      } else {
        transaction.update(docRef, {fieldName: const FieldValue.increment(1)});
      }
    });
  }

  Future<void> _incrementQrScan() => _incrementField(
    _firestore.collection(usersCollection).doc(qrScansDocument),
    countField,
  );

  Future<void> _incrementEmoji(String emojiName) => _incrementField(
    _firestore.collection(globalCollection).doc(varsDocument),
    emojiName,
  );

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours}h ${minutes}m ${seconds}s';
  }
}
