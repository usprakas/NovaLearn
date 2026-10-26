import 'package:flutter/material.dart';
import 'app.dart';
import 'core/network/novalearn_api.dart';
import 'core/security/session_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(NovaLearnApp(api: NovaLearnApi(), sessionStore: SessionStore()));
}
