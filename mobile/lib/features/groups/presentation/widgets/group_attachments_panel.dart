import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class GroupAttachmentsPanel extends StatefulWidget {
  final String groupId;
  final bool canUpload;
  final VoidCallback? onUploadPressed;

  const GroupAttachmentsPanel({
    super.key,
    required this.groupId,
    required this.canUpload,
    this.onUploadPressed,
  });

  @override
  State<GroupAttachmentsPanel> createState() => GroupAttachmentsPanelState();
}

class GroupAttachmentsPanelState extends State<GroupAttachmentsPanel> {
  final _dio = GetIt.I<DioClient>().dio;
  final _imagePicker = ImagePicker();
  List<Map<String, dynamic>> _files = [];
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final response = await _dio.get(ApiConstants.attachments(widget.groupId));
      if (mounted) {
        setState(() => _files = (response.data as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _upload(String path, String fileName) async {
    setState(() => _uploading = true);
    try {
      await _dio.post(
        ApiConstants.attachments(widget.groupId),
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(path, filename: fileName),
        }),
      );
      await _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File saved to this group')),
        );
      }
    } on DioException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.response?.data?['message']?.toString() ?? 'Upload failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _takePhoto() async {
    final photo = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (photo != null) {
      await _upload(photo.path, 'group_photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    final file = result?.files.single;
    if (file?.path != null) await _upload(file!.path!, file.name);
  }

  Future<void> _viewFile(Map<String, dynamic> file) async {
    final response = await _dio.get<List<int>>(
      ApiConstants.attachmentDownload(widget.groupId, file['id'].toString()),
      options: Options(responseType: ResponseType.bytes),
    );
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/${file['fileName']}';
    await File(path).writeAsBytes(response.data ?? []);
    await OpenFilex.open(path);
  }

  Future<void> _deleteFile(Map<String, dynamic> file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete file?'),
        content: Text(file['fileName']?.toString() ?? 'This file'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _dio.delete(ApiConstants.attachmentDelete(widget.groupId, file['id'].toString()));
    await _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Group files', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                if (widget.canUpload)
                  IconButton(
                    tooltip: 'Upload group file',
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: openUploadMenu,
                  ),
              ],
            ),
            if (_uploading) const LinearProgressIndicator(),
            if (_loading)
              const Padding(padding: EdgeInsets.only(top: 12), child: CircularProgressIndicator())
            else if (_files.isEmpty)
              const Padding(padding: EdgeInsets.only(top: 8), child: Text('No files uploaded yet.'))
            else
              ..._files.map(
                (file) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(file['fileName']?.toString() ?? 'File'),
                  subtitle: Text(file['uploadedBy']?['name']?.toString() ?? 'Group member'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'View file',
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => _viewFile(file),
                      ),
                      if (widget.canUpload)
                        IconButton(
                          tooltip: 'Delete file',
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _deleteFile(file),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> openUploadMenu() async {
    if (!widget.canUpload || _uploading) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take camera photo'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Choose any file'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'camera') await _takePhoto();
    if (choice == 'file') await _pickFile();
  }
}