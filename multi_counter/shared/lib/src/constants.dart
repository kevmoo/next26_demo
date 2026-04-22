/// Firestore constants for the `users` collection.
///
/// Hierarchy: `users` (collection) -> {userId} (document) -> `count` (field)
const usersCollection = 'users';
const countField = 'count';

/// Document ID used in the `users` collection for tracking QR scans.
const qrScansDocument = '_qr_scans';

/// Firestore constants for the `global` collection.
///
/// Hierarchy: `global` (collection) -> `vars` (document) ->
/// `totalCount`, `totalUsers` (fields)
const globalCollection = 'global';
const varsDocument = 'vars';
const totalCountField = 'totalCount';
const totalUsersField = 'totalUsers';

const emojiFields = {
  'emoji_blue_heart': '💙',
  'emoji_dartboard': '🎯',
  'emoji_plus': '➕',
  'emoji_rocket': '🚀',
};

/// HTTPS endpoint names.
const incrementCallable = 'increment';
const qrScanEndpoint = 'qr_scan';

/// Target URL for registration visits.
const registrationVisitUrl = 'https://goo.gle/X-Google4-Learn26?r=qr';
