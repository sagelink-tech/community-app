import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/app/app_config.dart';
import 'package:sagelink_communities/data/models/auth_model.dart';
import 'package:sagelink_communities/data/providers.dart';

class GraphQLConfiguration {
  AuthLink? authLink;
  HttpLink httpLink = HttpLink(FlutterAppConfig.apiUrl());
  bool get isAuthenticated => authLink != null;

  GraphQLConfiguration({this.authLink});

  Link getLink() {
    return authLink != null ? authLink!.concat(httpLink) : httpLink;
  }

  late GraphQLClient client = GraphQLClient(
      defaultPolicies: DefaultPolicies(
          watchQuery:
              Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
          watchMutation:
              Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
          query: Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
          mutate: Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
          subscribe:
              Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all)),
      cache: GraphQLCache(store: HiveStore()),
      link: getLink());
}

class GraphQLConfigurationNotifier extends StateNotifier<GraphQLConfiguration> {
  GraphQLConfigurationNotifier(state) : super(state);

  static final provider =
      StateNotifierProvider<GraphQLConfigurationNotifier, GraphQLConfiguration>(
          (ref) {
    GraphQLConfigurationNotifier gqlNotifier =
        GraphQLConfigurationNotifier(GraphQLConfiguration());
    AuthState authState = ref.watch(AuthStateNotifier.provider);
    AuthStateNotifier authNofifier =
        ref.watch(AuthStateNotifier.provider.notifier);
    final authUser = ref.watch(authStateChangesProvider);

    authUser.whenData((data) {
      gqlNotifier.updateGQLConfig(authState, authNofifier);
    });

    return gqlNotifier;
  });

  void updateGQLConfig(AuthState authState, AuthStateNotifier notifier) {
    print("UPDATING GQL CONFIG WITH " + authState.isAuthenticated.toString());
    if (!authState.isAuthenticated) {
      state = GraphQLConfiguration();
    } else {
      AuthLink alink = AuthLink(getToken: () async {
        if (authState.isExpired) {
          await notifier.updateToken();
        }
        return 'Bearer ${authState.token}';
      });
      state = GraphQLConfiguration(authLink: alink);
    }
  }
}
