import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/diagnosis_data.dart';
import 'package:myapp/question_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    _diagnosisData = _loadDiagnosisData();
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
}
