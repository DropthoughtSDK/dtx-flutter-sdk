import 'package:logger/logger.dart';

class ReturnLogger {
  static Logger logger =
      Logger(printer: PrettyPrinter(lineLength: 120), output: null);

  static Logger returnLogger() {
    return logger;
  }
}
