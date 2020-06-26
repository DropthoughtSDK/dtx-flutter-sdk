import 'package:graphql/client.dart';
import 'package:logger/logger.dart';
import '../UI/Low/Logger.dart';

class ConfigTest {
  static final HttpLink _httpLink = HttpLink(uri: 'http://10.0.2.2:3000/');
  static Logger log = ReturnLogger.returnLogger();

  static GraphQLClient initailizeClient() {
    GraphQLClient client = GraphQLClient(
      cache: InMemoryCache(),
      link: _httpLink,
    );
    log.i("GraphQLClient has been created and connected to the backend");
    return client;
  }
}
