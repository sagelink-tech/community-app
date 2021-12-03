import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/logged_in_user.dart';

final loggedInUserProvider =
    StateNotifierProvider<LoggedInUserStateNotifier, LoggedInUser>(
        (ref) => LoggedInUserStateNotifier(LoggedInUser()));
