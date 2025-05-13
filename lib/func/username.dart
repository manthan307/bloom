import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

final _random = Random();

const adjectives = [
  'focused',
  'silent',
  'brave',
  'wise',
  'calm',
  'swift',
  'sharp',
  'gentle',
  'wild',
  'pure',
];

const nouns = [
  'lion',
  'wolf',
  'eagle',
  'hawk',
  'panther',
  'tiger',
  'owl',
  'raven',
  'fox',
  'dragon',
];

String generateRandomUsername() {
  final adjective = adjectives[_random.nextInt(adjectives.length)];
  final noun = nouns[_random.nextInt(nouns.length)];
  final number = _random.nextInt(1000); // 0–999
  return '${adjective}_$noun$number';
}

Future<String> getUniqueUsername() async {
  String username = '';
  bool exists = true;

  while (exists) {
    username = generateRandomUsername();

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    exists = query.docs.isNotEmpty;
  }

  return username.toLowerCase();
}
