import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storyforge_mobile/app.dart';

void main() {
  // TODO: implement initializations (Firebase, Logger, etc.)
  runApp(
    const ProviderScope(
      child: StoryForgeApp(),
    ),
  );
}
