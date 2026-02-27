/// Firestore constants for the `users` collection.
///
/// Hierarchy: `users` (collection) -> {userId} (document) -> `count` (field)
const $users = 'users';
const countField = 'count';

/// Firestore constants for the `global` collection.
///
/// Hierarchy: `global` (collection) -> `vars` (document) ->
/// `totalCount`, `totalUsers` (fields)
const $global = 'global';
const $global$vars = 'vars';
const totalCountField = 'totalCount';
const totalUsersField = 'totalUsers';

/// HTTPS Callable function names.
const $incrementCallable = 'increment';
