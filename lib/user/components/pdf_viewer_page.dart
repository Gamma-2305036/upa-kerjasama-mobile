import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;
  const PdfViewerPage({super.key, required this.url, this.title = 'Dokumen PDF'});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _loading = true;
  String? _localPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    try {
      final uri = Uri.parse(widget.url);
      final client = http.Client();
      final req = http.Request('GET', uri);
      req.headers['Accept'] = 'application/pdf';
      req.headers['Accept-Encoding'] = 'identity'; // avoid gzip/chunk issues
      final streamed = await client.send(req).timeout(const Duration(seconds: 30));
      if (streamed.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/view.pdf');
        final sink = file.openWrite();
        await streamed.stream.pipe(sink);
        await sink.close();
        if (mounted) setState(() { _localPath = file.path; _loading = false; });
      } else {
        if (mounted) setState(() { _loading = false; _error = 'Gagal mengunduh PDF (kode ${streamed.statusCode})'; });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        foregroundColor: const Color(0xFF1A365D),
        backgroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_localPath == null
              ? _buildError()
              : PDFView(
                  filePath: _localPath!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: true,
                )),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(_error ?? 'Gagal memuat PDF'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Buka di Browser'),
            ),
          ],
        ),
      ),
    );
  }
}


