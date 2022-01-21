import '../app_config.dart';

void main() async {
  await FlutterAppConfig(
    environment: AppEnvironment.development,
    apiBaseUrl: 'https://sl-gql-server.herokuapp.com/graphql',
    appName: 'Sagelink Demo',
    initializeCrashlytics: true,
  ).run();
}
