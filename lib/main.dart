import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/diagnosis_data.dart';
import 'package:myapp/question_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '恋愛診断',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.mochiyPopOneTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: const DiagnosisListScreen(),
    );
  }
}

class DiagnosisListScreen extends StatefulWidget {
  const DiagnosisListScreen({super.key});

  @override
  State<DiagnosisListScreen> createState() => _DiagnosisListScreenState();
}

class _DiagnosisListScreenState extends State<DiagnosisListScreen> {
  Future<List<Diagnosis>>? _diagnosisData;

  @override
  void initState() {
    super.initState();
    _checkVersion();
    _diagnosisData = _loadDiagnosisData();
  }

  Future<void> _checkVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final snapshot = await FirebaseFirestore.instance
        .collection('config')
        .doc('GUKgKQUkT5EpGSV6teiw') // iOSの場合は'ios'などプラットフォームに合わせて変更してください
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null && data.containsKey('iOS_ver')) {
        final latestVersion = data['iOS_ver'] as String;

        if (_compareVersions(latestVersion, currentVersion) > 0) {
          // contextが利用可能な状態か確認
          if (mounted) {
            _showUpdateDialog(context);
          }
        }
      }
    }
  }

  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    final maxLength = parts1.length > parts2.length
        ? parts1.length
        : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }
    return 0;
  }

  Future<List<Diagnosis>> _loadDiagnosisData() async {
    final jsonString = await rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Diagnosis.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('診断を選んでね！', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink[300],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.pink[50]!, Colors.pink[100]!, Colors.purple[100]!],
          ),
        ),
        child: FutureBuilder<List<Diagnosis>>(
          future: _diagnosisData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('エラー: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final tests = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  return Card(
                    elevation: 8,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.pink[200]!, Colors.purple[200]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        title: Text(
                          test.title,
                          style: GoogleFonts.mochiyPopOne(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 28,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  QuestionView(selectedTest: test),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('データが見つかりません'));
            }
          },
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('アップデートが必要です'),
          content: const Text('新しいバージョンのアプリが利用可能です。アップデートしてください。'),
          actions: [
            TextButton(
              child: const Text('アップデート'),
              onPressed: () {
                // ストアのURLを定義
                // TODO: 必ずご自身のアプリのURLに書き換えてください
                const String appStoreUrl =
                    'https://itunes.apple.com/jp/app/id6754920676?mt=8';
                const String playStoreUrl =
                    'https://play.google.com/store/apps/details?id=<あなたのパッケージ名>';

                // OSに応じて開くURLを決定
                final String url = Platform.isIOS ? appStoreUrl : playStoreUrl;

                try {
                  launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication, // ストアアプリを直接開く
                  );
                } catch (e) {
                  // エラー処理
                  debugPrint('ストアを開けませんでした: $e');
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
