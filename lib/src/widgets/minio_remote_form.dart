import 'package:flutter/material.dart';
import 'package:ecchhoos/src/models/MinioBackend.dart';

class MinioRemoteForm extends StatefulWidget {
  final MinioBackend? remote;
  final Function(MinioBackend) onSave;
  final Function(String) onDelete;

  const MinioRemoteForm({Key? key, this.remote, required this.onSave, required this.onDelete}) : super(key: key);

  @override
  _MinioRemoteFormState createState() => _MinioRemoteFormState();
}

class _MinioRemoteFormState extends State<MinioRemoteForm> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _accessKeyController;
  late TextEditingController _secretKeyController;
  late TextEditingController _bucketNameController;
  late TextEditingController _pathPrefixController;
  late TextEditingController _uuidController;
  late bool _useSSL;

  MinioBackend get remoteWithUpdatedValues => MinioBackend(
        useSSL: _useSSL,
        uuid: _uuidController.text,
        endpoint: _hostController.text,
        port: int.parse(_portController.text),
        accessKey: _accessKeyController.text,
        secretKey: _secretKeyController.text,
        bucketName: _bucketNameController.text,
        pathPrefix: _pathPrefixController.text,
      );
  late bool confirmDeleteAction;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: widget.remote?.endpoint);
    _portController = TextEditingController(text: widget.remote?.port.toString());
    _accessKeyController = TextEditingController(text: widget.remote?.accessKey);
    _secretKeyController = TextEditingController(text: widget.remote?.secretKey);
    _bucketNameController = TextEditingController(text: widget.remote?.bucketName);
    _pathPrefixController = TextEditingController(text: widget.remote?.pathPrefix);
    _uuidController = TextEditingController(text: widget.remote?.uuid);
    _useSSL = widget.remote?.useSSL ?? true;
    confirmDeleteAction = false;
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    _bucketNameController.dispose();
    _pathPrefixController.dispose();
    _uuidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('rerendering with ${widget.remote?.uuid}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'UUID'),
          controller: _uuidController,
          readOnly: true,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Host'),
          controller: _hostController,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Port'),
          keyboardType: TextInputType.number,
          controller: _portController,
        ),
        Row(
          children: [
            Text('Use SSL:'),
            Switch(
              value: _useSSL,
              onChanged: (bool value) {
                print('setting useSSL to $value');
                setState(() {
                  _useSSL = value;
                });
              },
            ),
          ],
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Access Key'),
          controller: _accessKeyController,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Secret Key'),
          controller: _secretKeyController,
          obscureText: true,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Bucket Name'),
          controller: _bucketNameController,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Path Prefix'),
          controller: _pathPrefixController,
        ),
        SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                widget.onSave(remoteWithUpdatedValues);
              },
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                if (confirmDeleteAction == true) {
                  widget.onDelete(_uuidController.text);
                } else {
                  setState(() {
                    confirmDeleteAction = true;
                  });
                }
              },
              child: Text(confirmDeleteAction ? 'Confirm Delete' : 'Delete'),
            ),
            ElevatedButton(
              onPressed: () async {
                final tempBackend = remoteWithUpdatedValues;
                print('testing connection to ${tempBackend.endpoint} (useSSL: ${tempBackend.useSSL})');
                final items = await tempBackend.enumerateAllItems();
                print('Found ${items.length} items');
              },
              child: Text('Test Connection'),
            ),
          ],
        ),
      ],
    );
  }
}
