import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    lineLength: 80,
    methodCount: 0,
    errorMethodCount: 5,
  ),
);

