
import 'package:flutter/material.dart';

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key, required this.initText, required this.title});
  final String? initText;
  final String title;

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {

  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode(debugLabel: 'note');

  @override
  void initState() {
    _textController.text = widget.initText ?? "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_textFocusNode);
    });
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        focusNode: _textFocusNode,
        controller: _textController,
        decoration: const InputDecoration(hintText: 'Nhập ghi chú'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_textController.text);
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}