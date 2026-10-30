import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/network/novalearn_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(NovaLearnApi().wakeUp());
  runApp(const ProviderScope(child: NovaLearnApp()));
}
