import 'package:sagelink_communities/models/app_state_model.dart';
import 'package:sagelink_communities/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/logged_in_user.dart';

final loggedInUserProvider =
    StateNotifierProvider<LoggedInUserStateNotifier, LoggedInUser>(
        (ref) => LoggedInUserStateNotifier(LoggedInUser(user: UserModel())));

final appStateProvider = ChangeNotifierProvider((ref) => AppState());
