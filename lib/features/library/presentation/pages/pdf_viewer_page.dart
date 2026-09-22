import 'package:flutter/material.dart';
import 'package:ibnzaidon/features/library/presentation/widgets/pdf_document_view.dart';

class PdfViewerArgs {
  const PdfViewerArgs({required this.title, required this.url});

  final String title;
  final String url;
}

class PdfViewerPage extends StatelessWidget {
  const PdfViewerPage({required this.args, super.key});

  final PdfViewerArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(args.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: PdfDocumentView(url: args.url),
    );
  }
}
