import "dart:io";
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  runApp(const UploadApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return true;
  });
}

class UploadApp extends StatelessWidget {
  const UploadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upload Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UploadHomePage(),
    );
  }
}

class UploadTaskItem {
  UploadTaskItem(this.filePath, this.task);
  final String filePath;
  final UploadTask task;
}

class UploadHomePage extends StatefulWidget {
  const UploadHomePage({super.key});

  @override
  State<UploadHomePage> createState() => _UploadHomePageState();
}

class _UploadHomePageState extends State<UploadHomePage> {
  final List<UploadTaskItem> _uploads = [];

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final ref = FirebaseStorage.instance.ref('uploads/${file.name}');
      final task = ref.putFile(File(file.path!));
      setState(() {
        _uploads.add(UploadTaskItem(file.path!, task));
      });
      task.snapshotEvents.listen((event) => setState(() {}));
    }
  }

  void _pause(UploadTaskItem item) {
    item.task.pause();
  }

  void _resume(UploadTaskItem item) {
    item.task.resume();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Manager')),
      body: ListView.builder(
        itemCount: _uploads.length,
        itemBuilder: (context, index) {
          final item = _uploads[index];
          return StreamBuilder<TaskSnapshot>(
            stream: item.task.snapshotEvents,
            builder: (context, snapshot) {
              final progress = snapshot.data?.bytesTransferred ?? 0;
              final total = snapshot.data?.totalBytes ?? 1;
              final percent = (progress / total * 100).toStringAsFixed(0);
              return ListTile(
                title: Text(item.filePath.split('/').last),
                subtitle: Text('$percent%'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.pause),
                      onPressed: () => _pause(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => _resume(item),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUpload,
        child: const Icon(Icons.add),
      ),
    );
  }
}
