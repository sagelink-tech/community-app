import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/app/app_config.dart';

class GraphQLConfiguration extends ChangeNotifier {
  Link? link;
  HttpLink httpLink = HttpLink(FlutterAppConfig().apiUrl());
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  bool get isAuthenticated => link != null;

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

  void setToken(String token) {
    AuthLink alink = AuthLink(getToken: () => 'Bearer ' + token);
    link = alink.concat(httpLink);
    updateClient();
  }

  void removeToken() {
    link = null;
    updateClient();
  }

  Link getLink() {
    return link != null ? link! : httpLink;
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
