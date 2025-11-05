import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/diagnosis_data.dart';
import 'package:myapp/share_image_view.dart';

class ResultView extends StatelessWidget {
  final Diagnosis selectedTest;
  final int yesCount;

  const ResultView({
    super.key,
    required this.selectedTest,
    required this.yesCount,
  });

  // yesCountに基づいて表示すべき診断結果を決定するロジック
  DiagnosisResult _determineResult() {
    final List<DiagnosisResult> results = selectedTest.results;

    // 診断結果のリストが5つの場合、指定されたロジックを適用
    if (results.length == 5) {
      if (yesCount <= 2) return results[0];
      if (yesCount <= 4) return results[1];
      if (yesCount <= 6) return results[2];
      if (yesCount <= 8) return results[3];
      return results[4]; // 9-10
    }
    // 結果が5つでない場合のフォールバック処理
    else if (results.isNotEmpty) {
      double percentage = yesCount / 10.0;
      int index = (percentage * (results.length - 1)).round();
      return results[index];
    }
    // 結果が存在しない場合は例外を投げる
    else {
      throw Exception('Selected test has no results.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DiagnosisResult result = _determineResult();

    return Scaffold(
      appBar: AppBar(
        title: const Text('診断結果'),
        automaticallyImplyLeading: false, // 戻るボタンを非表示
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'あなたのタイプは...',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 8,
                  shadowColor: Colors.purple.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          result.typeName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          result.descriptionHint,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: Text(
                    'この結果をシェアする',
                    style: GoogleFonts.notoSansJp(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[400],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShareImageView(
                          typeName: result.typeName,
                          title: selectedTest.title,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('最初の画面に戻る', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
