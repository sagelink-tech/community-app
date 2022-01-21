import 'package:sagelink_communities/data/models/app_state_model.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagelink_communities/data/models/logged_in_user.dart';

final loggedInUserProvider =
    StateNotifierProvider<LoggedInUserStateNotifier, LoggedInUser>(
        (ref) => LoggedInUserStateNotifier(LoggedInUser(user: UserModel())));

final appStateProvider = ChangeNotifierProvider((ref) => AppState());
