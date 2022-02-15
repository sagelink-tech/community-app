import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/app/app_config.dart';
import 'package:sagelink_communities/data/models/auth_model.dart';

class GraphQLConfiguration extends ChangeNotifier {
  AuthLink? authLink;
  HttpLink httpLink = HttpLink(FlutterAppConfig.apiUrl());
  bool get isAuthenticated => authLink != null;

  AuthState authState;

  GraphQLConfiguration({required this.authState}) {
    updateGQLConfig();
  }

  void updateGQLConfig() {
    print("UPDATING GQL CONFIG WITH " + authState.isAuthenticated.toString());
    if (!authState.isAuthenticated) {
      authLink = null;
    } else {
      authLink = AuthLink(getToken: () async {
        print("Checking expiration");
        return 'Bearer ${await authState.getToken()}';
      });
    }
    updateClient();
  }

  Link getLink() {
    return authLink != null ? authLink!.concat(httpLink) : httpLink;
  }

  void updateClient() {
    client = GraphQLClient(
        defaultPolicies: DefaultPolicies(
            watchQuery:
                Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
            watchMutation:
                Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
            query: Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
            mutate:
                Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all),
            subscribe:
                Policies(fetch: FetchPolicy.noCache, error: ErrorPolicy.all)),
        cache: GraphQLCache(store: HiveStore()),
        link: getLink());
    notifyListeners();
  }

  late GraphQLClient client;
}
