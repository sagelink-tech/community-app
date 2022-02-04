import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sagelink_communities/app/app_config.dart';

class GraphQLConfiguration {
  static Link? link;
  static HttpLink httpLink = HttpLink(FlutterAppConfig().apiUrl());

  static void setToken(String token) {
    AuthLink alink = AuthLink(getToken: () async => 'Bearer ' + token);
    GraphQLConfiguration.link = alink.concat(GraphQLConfiguration.httpLink);
  }

  static void removeToken() {
    GraphQLConfiguration.link = null;
  }

  static Link getLink() {
    return GraphQLConfiguration.link != null
        ? GraphQLConfiguration.link!
        : GraphQLConfiguration.httpLink;
  }

  ValueNotifier<GraphQLClient> client = ValueNotifier(GraphQLClient(
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
      link: getLink()));
}
