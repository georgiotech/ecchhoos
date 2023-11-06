import 'package:flutter/widgets.dart';

class TranscriptViewer extends StatelessWidget {
  const TranscriptViewer({Key? key, required this.transcribedText}) : super(key: key);

  final String? transcribedText;

  @override
  Widget build(BuildContext context) {
    return transcribedText == null
        ? const Center(
            child: Text(
              'Ec...ch...ho...os...',
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [Expanded(child: SingleChildScrollView(child: Text(transcribedText!)))],
            ),
          );
  }
}
