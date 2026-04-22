import 'dart:async';

import 'package:firebase_functions/firebase_functions.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:multi_counter_shared/multi_counter_shared.dart';

final class QrController {
  final Firestore _firestore;

  QrController(this._firestore);

  Future<Response> handleRequest(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final emojiName = queryParams['emoji'];

      if (emojiName != null && _isValidEmoji(emojiName)) {
        await _incrementEmoji(emojiName);
      } else {
        await _incrementQrScan();
      }

      return Response.ok(
        _generateHtml(),
        headers: {'Content-Type': 'text/html; charset=utf-8'},
      );
    } catch (e, stack) {
      print('Error handling QR Scan request');
      print(e);
      print(stack);
      return Response.internalServerError(body: 'Internal Server Error');
    }
  }

  bool _isValidEmoji(String name) => emojiFields.containsKey(name);

  Future<void> _incrementField(
    DocumentReference docRef,
    String fieldName,
  ) async {
    await _firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {fieldName: 1});
      } else {
        transaction.update(docRef, {fieldName: const FieldValue.increment(1)});
      }
    });
  }

  Future<void> _incrementQrScan() => _incrementField(
    _firestore.collection(usersCollection).doc(qrScansDocument),
    qrScanCountField,
  );

  Future<void> _incrementEmoji(String emojiName) => _incrementField(
    _firestore.collection(globalCollection).doc(varsDocument),
    emojiName,
  );

  String _generateHtml() =>
      '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Multi-Counter Engagement</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      background-color: #FAFAFA;
      color: #18181B;
      text-align: center;
      padding: 2rem;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 80vh;
    }
    h1 { margin-bottom: 0.5rem; font-size: 2rem; }
    p { color: #71717A; margin-top: 0; margin-bottom: 2rem; font-size: 1.125rem; }
    .emojis {
      display: flex;
      gap: 1.5rem;
      justify-content: center;
      margin-bottom: 3rem;
    }
    .emoji-btn {
      background: white;
      border: 1px solid #E4E4E7;
      border-radius: 16px;
      font-size: 2.5rem;
      padding: 1rem;
      cursor: pointer;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
      transition: transform 0.2s, box-shadow 0.2s;
      text-decoration: none;
    }
    .emoji-btn:hover {
      transform: translateY(-4px);
      box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
    }
    .emoji-btn.clicked {
      animation: floatAndFade 0.4s cubic-bezier(0.4, 0, 0.2, 1) forwards;
    }
    @keyframes floatAndFade {
      0% { transform: translateY(0) scale(1); opacity: 1; }
      100% { transform: translateY(-30px) scale(1.2); opacity: 0; }
    }
    .link {
      color: #2563EB;
      text-decoration: none;
      font-weight: 600;
      font-size: 1.125rem;
    }
    .link:hover { text-decoration: underline; }
  </style>
  <script>
    function handleEmojiClick(event, href) {
      event.preventDefault();
      const btn = event.currentTarget;
      btn.classList.add('clicked');
      setTimeout(() => {
        window.location.href = href;
      }, 350);
    }
  </script>
</head>
<body>
  <h1>Thank you for visiting!</h1>
  <p>Show your support by clicking an emoji below:</p>

  <div class="emojis">
    ${emojiFields.entries.map((e) => '<a class="emoji-btn" onclick="handleEmojiClick(event, \'?emoji=${e.key}\')" href="?emoji=${e.key}">${e.value}</a>').join('\n    ')}
  </div>


  <a class="link" href="$registrationVisitUrl" target="_blank">Click here to register your visit</a>
</body>
</html>
''';
}
