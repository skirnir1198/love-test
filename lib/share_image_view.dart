import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ShareImageView extends StatefulWidget {
  final String typeName;
  final String title;

  const ShareImageView({
    super.key,
    required this.typeName,
    required this.title,
  });

  @override
  State<ShareImageView> createState() => _ShareImageViewState();
}

class _ShareImageViewState extends State<ShareImageView> {
  // 画像に変換したいWidgetを特定するためのキー
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _saveImage() async {
    // 1. 権限を確認
    final status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('写真へのアクセスが許可されていません。')));
      }
      return;
    }

    try {
      // 2. RepaintBoundaryから画像データを生成
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // 高解像度でキャプチャ
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 3. image_gallery_saver を使って画像を保存
      await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: "love_test_result",
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('画像をギャラリーに保存しました！')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('画像の保存に失敗しました: $e')));
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // temporary directoryに保存
      final tempDir = Directory.systemTemp;
      final imagePath = '${tempDir.path}/love_test_result.png';
      final file = File(imagePath);
      await file.writeAsBytes(pngBytes);

      // share_plusで共有
      await Share.shareXFiles([
        XFile(imagePath),
      ], text: '${widget.title} #恋愛診断');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('画像の共有に失敗しました: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画面サイズに合わせて調整
    final screenWidth = MediaQuery.of(context).size.width;
    final double baseFontSize = screenWidth / 12;

    return Scaffold(
      appBar: AppBar(
        title: const Text('シェア画像', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink[300],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: FloatingActionButton.extended(
          onPressed: _shareImage,
          label: const Text(
            '画像を保存/シェア',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.share, color: Colors.white),
          backgroundColor: Colors.pink[400],
        ),
      ),
      body: Center(
        // Instagramストーリーのアスペクト比 (9:16) に近いコンテナ
        child: RepaintBoundary(
          key: _globalKey,
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.purple[200]!,
                    Colors.pink[200]!,
                    Colors.orange[100]!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // 中央の診断結果タイプ名
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        widget.typeName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.mochiyPopOne(
                          fontSize: baseFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(
                              blurRadius: 10.0,
                              color: Colors.black45,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 下部のタイトルとアプリ名
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.notoSansJp(
                              fontSize: baseFontSize * 0.4,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '#恋愛診断',
                            style: GoogleFonts.notoSansJp(
                              fontSize: baseFontSize * 0.35,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
