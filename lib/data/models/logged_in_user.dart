import 'package:firebase_auth/firebase_auth.dart';
import 'package:sagelink_communities/data/models/app_state_model.dart';
import 'package:sagelink_communities/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getUserQuery = """
query Users(\$where: UserWhere) {
  users(where: \$where) {
    id
    email
    name
    accountPictureUrl
    memberOfBrands{
      id
      logoUrl
      name
      mainColor
    }
    employeeOfBrands{
      id
      logoUrl
      name
      mainColor
    }
  }
}
""";

//ignore: constant_identifier_names
const String CREATE_USER_MUTATION = """
mutation CreateUsers(\$input: [UserCreateInput!]!) {
  createUsers(input: \$input) {
    users {
      id
    }
  }
}
""";

enum LoginState { isLoggedOut, isLoggingIn, isLoggedIn, needToCreateUser }

class LoggedInUser {
  UserModel? user;
  LoginState status = LoginState.isLoggedOut;
  bool isAdmin = false;
  String? adminBrandId;

  // Main use case interfaces
  UserModel getUser() {
    return user ?? UserModel();
  }

  LoggedInUser(
      {this.user,
      this.status = LoginState.isLoggedOut,
      this.isAdmin = false,
      this.adminBrandId});
}

class LoggedInUserStateNotifier extends StateNotifier<LoggedInUser> {
  LoggedInUserStateNotifier(state,
      {required this.client, required this.appState})
      : super(state ?? LoggedInUser());

  final GraphQLClient client;
  final AppState appState;

  void updateUserWithState(User? user) {
    if (user == null && state.status != LoginState.isLoggedOut) {
      LoggedInUser _loggedInUser =
          LoggedInUser(user: UserModel(), status: LoginState.isLoggedOut);
      state = _loggedInUser;
    } else if (user != null && state.status != LoginState.isLoggedIn) {
      fetchUserData(firebaseUser: user);
    }
  }

  void setIsLoading() {
    state = LoggedInUser(user: UserModel(), status: LoginState.isLoggingIn);
  }

  // Fetch logged in user's data from the SL backend
  Future<Object?> fetchUserData(
      {String userId = "", String email = "", User? firebaseUser}) async {
    if (userId.isEmpty && email.isEmpty && firebaseUser == null) {
      return Exception(
          "missing required uid fields [email, userId, firebaseUser]");
    }

    state = LoggedInUser(user: null, status: LoginState.isLoggingIn);
    final QueryResult result = await client.query(QueryOptions(
      document: gql(getUserQuery),
      variables: {
        "where": userId.isNotEmpty
            ? {"id": userId}
            : email.isNotEmpty
                ? {"email": email}
                : {"firebaseId": firebaseUser!.uid},
        "options": {"limit": 1}
      },
    ));
    if (result.hasException) {
      throw (result.exception!);
    }

    if (result.data != null && (result.data!['users'] as List).isNotEmpty) {
      var _userData = result.data?['users'][0];
      UserModel _user = UserModel.fromJson(_userData);
      String? brandId;
      bool isAdmin = false;

      if ((_userData['employeeOfBrands'] as List).isNotEmpty) {
        isAdmin = true;
        brandId = _userData['employeeOfBrands'][0]['id'];
      }
      LoggedInUser _loggedInUser = LoggedInUser(
          user: _user,
          status: LoginState.isLoggedIn,
          isAdmin: isAdmin,
          adminBrandId: brandId);
      // update app state that the user has successfully logged in
      appState.didSignIn();
      state = _loggedInUser;
    } else if (result.data != null && firebaseUser != null) {
      LoggedInUser _loggedInUser = LoggedInUser(
          user: UserModel.fromFirebaseUser(firebaseUser),
          status: LoginState.needToCreateUser);
      state = _loggedInUser;
    }
  }

  void updateWithUserId(String userId) {
    setIsLoading();
    fetchUserData(userId: userId);
  }

  void createNewUser(UserModel user, {OnMutationCompleted? onComplete}) async {
    // initialize mutation variables
    Map<String, dynamic> mutationVariables = user.toJson();
    mutationVariables.remove('id');
    mutationVariables["causes"] = {
      "connectOrCreate": user.causes
          .map((e) => {
                "where": {
                  "node": {"title": e.title}
                },
                "onCreate": {
                  "node": {"title": e.title}
                }
              })
          .toList()
    };

    // Update
    MutationOptions options =
        MutationOptions(document: gql(CREATE_USER_MUTATION), variables: {
      "input": [mutationVariables]
    });

    QueryResult result = await client.mutate(options);

    bool success = (result.data != null &&
        (result.data!['createUsers']['users'] as List).length == 1);
    if (onComplete != null) {
      await onComplete(result.data);
    }
    if (success) {
      updateWithUserId(result.data!['createUsers']['users'][0]['id']);
    }
  }
}
