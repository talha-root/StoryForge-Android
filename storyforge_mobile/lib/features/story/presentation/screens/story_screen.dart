import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryScreen extends ConsumerWidget {
  final String storyId;
  const StoryScreen({super.key, required this.storyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Story Detail')),
      body: Center(
        child: Text('Story Screen ($storyId) - TODO: implement'),
      ),
    );
  }
}
