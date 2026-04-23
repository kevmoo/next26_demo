import 'dart:convert';

import 'package:multi_counter_shared/multi_counter_shared.dart';

String generateHtml({
  required String uptime,
  required int instanceCount,
  required Map<String, int> emojiCounts,
}) => _minifyHtml('''
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
      padding: 2rem 1rem;
      max-width: 480px;
      margin: 0 auto;
      display: block;
    }

    h1 { margin-bottom: 0.5rem; font-size: 2rem; }
    p { color: #71717A; margin-top: 0; margin-bottom: 2rem; font-size: 1.125rem; }
    .emojis {
      display: flex;
      gap: 0.75rem;
      justify-content: center;
      margin-bottom: 2rem;
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
    .cta-button {
      display: inline-block;
      background-color: #2563EB;
      color: white;
      font-weight: 600;
      font-size: 1.25rem;
      padding: 1rem 2rem;
      border-radius: 12px;
      text-decoration: none;
      box-shadow: 0 4px 6px -1px rgba(37, 99, 235, 0.2);
      transition: background-color 0.2s, transform 0.2s;
    }
    .cta-button:hover {
      background-color: #1D4ED8;
      transform: translateY(-2px);
    }
  </style>
  <script>
    const emojiMap = ${jsonEncode(emojiFields)};

    function updateMetrics(uptime, count, emojiCounts) {
      let text = `Uptime:        \${uptime}\\nLoad Count: \${String(count).padStart(14, ' ')}\\n\\n`;
      for (const [key, emoji] of Object.entries(emojiMap)) {
        text += `\${emoji}:\${emojiCounts[key] || 0} `;
      }
      document.getElementById('metrics').innerText = text.trim();
    }

    function handleEmojiClick(event, href) {
      event.preventDefault();
      const btn = event.currentTarget;
      btn.classList.add('clicked');
      fetch(href)
        .then(res => res.json())
        .then(data => {
          updateMetrics(data.uptime, data.count, data.emojiCounts);
          setTimeout(() => {
            btn.classList.remove('clicked');
          }, 400);
        })
        .catch(err => console.error('Error incrementing emoji:', err));
    }
  </script>
</head>
<body>
  <a class="cta-button" href="$registrationVisitUrl" target="_blank">Click here to register your visit</a>
  <br><br>
  <div class="emojis">
    ${emojiFields.entries.map((e) => '<a class="emoji-btn" onclick="handleEmojiClick(event, \'?emoji=${e.key}\')" href="?emoji=${e.key}">${e.value}</a>').join('\n    ')}
  </div>
  <p style="margin-top: -1.5rem; margin-bottom: 1rem; color: #52525B; font-style: italic;">Look at the big screen when you click!</p>

  <pre id="metrics" style="font-family: monospace; color: #71717A; background-color: #F4F4F5; padding: 1rem; border-radius: 8px; border: 1px solid #E4E4E7; margin-top: 0.5rem; font-size: 0.875rem; display: inline-block; text-align: left;"></pre>

  <p>
  <a class="link" href="https://firebase.google.com/docs/functions/start-dart" target="_blank">Get Started with Dart and Firebase Functions</a>
  </p>
  <div style="margin-top: 1rem; display: flex; align-items: center; justify-content: center; gap: 1.5rem;">
    Powered by
    <a href="https://dart.dev" target="_blank" style="text-decoration: none; display: flex; align-items: center; gap: 0.5rem; font-weight: 600; color: #01579B; font-family: sans-serif;">
      <svg width="24" height="24" viewBox="0 0 1080 1080" fill="none" xmlns="http://www.w3.org/2000/svg">
        <g>
          <path fill="#01579B" d="M225.6,852.14L44.84,671.38c-21.41-22.01-34.76-53.08-34.76-83.43c0-14.05,7.94-36.03,13.9-48.67 l166.86-347.62L225.6,852.14z"/>
          <path fill="#40C4FF" d="M844.37,226.42L663.61,45.66c-15.79-15.85-48.67-34.76-76.48-34.76c-23.9,0-47.36,4.78-62.57,13.9 L190.84,191.66L844.37,226.42z"/>
          <polygon fill="#40C4FF" points="441.13,1067.66 879.13,1067.66 879.13,879.95 552.37,775.66 253.41,879.95 	"/>
          <path fill="#29B6F6" d="M190.84,754.8c0,55.77,6.99,69.45,34.76,97.33l27.81,27.81h625.72L573.22,532.33L190.84,191.66V754.8z"/>
          <path fill="#01579B" d="M747.03,191.66H190.84l688.29,688.29h187.71V448.9L844.37,226.42 C813.12,195.05,785.37,191.66,747.03,191.66z"/>
        </g>
      </svg>
      Dart

    </a>
    <a href="https://cloud.google.com/run" target="_blank" style="text-decoration: none; display: flex; align-items: center; gap: 0.5rem; font-weight: 600; color: #EA4335; font-family: sans-serif;">
      <svg id="standard_product_icon" xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0 0 512 512" width="24" height="24">
        <defs>
          <style>
            .st0 { fill: none; }
            .st1 { fill: #4285f4; }
            .st2 { fill: #34a853; }
            .st3 { fill: #fbbc04; }
            .st4 { fill: #ea4335; }
          </style>
        </defs>
        <g id="bounding_box">
          <rect class="st0" width="512" height="512"/>
        </g>
        <g id="art">
          <path class="st3" d="M144.4,272c-6.4,0-12.4-3.8-14.9-10.1L55.4,75.9c-3.3-8.2.7-17.5,8.9-20.8,8.2-3.3,17.5.7,20.8,8.9l74.2,186c3.3,8.2-.7,17.5-8.9,20.8-1.9.8-3.9,1.1-5.9,1.1h-.1Z"/>
          <g id="b">
            <path class="st4" d="M256,272c-6.4,0-12.4-3.8-14.9-10.1l-74.1-186c-2.6-6.6-.6-14.1,5-18.5s13.4-4.5,19.2-.4l260.1,186c7.2,5.1,8.9,15.1,3.7,22.3s-15.1,8.9-22.3,3.7L216.9,114.7l54,135.3c3.3,8.2-.7,17.5-8.9,20.8-1.9.8-4,1.1-5.9,1.1h-.1Z"/>
          </g>
          <path class="st2" d="M127.2,256l-72,180c-3.3,8.2.7,17.5,8.9,20.8,3.1,1.2,4,1.1,5.9,1.1,6.3,0,12.4-3.8,14.9-10.1l74.4-186c.8-2,1.1-4,1.1-5.9h-33.2Z"/>
          <path class="st1" d="M414.5,256l-197.7,141.2,54.1-135.3c.8-2,1.1-4,1.1-5.9h-33.2l-72,180c-2.6,6.6-.6,14.1,5,18.5,2.9,2.3,6.4,3.4,9.9,3.4s6.5-1,9.3-3l260.4-186c4.4-3.1,6.7-8,6.7-13h-43.6Z"/>
        </g>
      </svg>
      Cloud Run
    </a>
  </div>
  <script>
    const initialEmojiCounts = ${jsonEncode(emojiCounts)};
    updateMetrics('$uptime', $instanceCount, initialEmojiCounts);
  </script>
</body>
</html>
''');

/// Stripping out the leading/trailing whitespace from each line to make things
/// a bit smaller over the wire.
String _minifyHtml(String html) =>
    const LineSplitter().convert(html).map((line) => line.trim()).join('\n');
