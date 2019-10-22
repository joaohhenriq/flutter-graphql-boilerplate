import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../services/shared_preferences_service.dart';

class Config {
  static final HttpLink httpLink =
      HttpLink(uri: 'https://learn.hasura.io/graphql');

  static final AuthLink authLink =
      AuthLink(getToken: () async => await sharedPreferenceService.token);

  static final WebSocketLink webSocketLink = WebSocketLink(
      url: 'wss://learn.hasura.io/graphql',
      config: SocketClientConfig(
          autoReconnect: true, inactivityTimeout: Duration(seconds: 30)));

  static final Link link =
      authLink.concat(httpLink as Link).concat(webSocketLink);

  static ValueNotifier<GraphQLClient> initializaClient() {
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
      ),
    );
    return client;
  }
}
