import 'package:flutter/material.dart';
import 'package:community_app/models/app_model.dart';
import 'package:community_app/models/user_model.dart';
import 'package:community_app/services/user_service.dart';
import 'package:provider/provider.dart';

BuildContext? _mainContext;
// The commands will use this to access the Provided models and services.
void init(BuildContext c) => _mainContext = c;

// Provide quick lookup methods for all the top-level models and services. Keeps the Command code slightly cleaner.
class BaseCommand {
  // Models
  UserModel userModel = _mainContext!.read();
  AppModel appModel = _mainContext!.read();

  // Services
  UserService userService = _mainContext!.read();
}
