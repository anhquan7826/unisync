import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/file_transfer/file_transfer.cubit.dart';
import 'package:unisync/app/home/file_transfer/file_transfer.state.dart';
import 'package:unisync/components/enums/file_type.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/components/widgets/clickable.dart';
import 'package:unisync/models/file/file.model.dart';
import 'package:unisync/utils/extensions/context.ext.dart';
import 'package:unisync/utils/extensions/state.ext.dart';

class FileTransferScreen extends StatefulWidget {
  const FileTransferScreen({super.key});

  @override
  State<FileTransferScreen> createState() => _FileTransferScreenState();
}

class _FileTransferScreenState extends State<FileTransferScreen>
    with AutomaticKeepAliveClientMixin {
  final height = 42.0;

  UnisyncFile? selectedFile;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<FileTransferCubit, FileTransferState>(
      builder: (context, state) {
        return Scaffold(
          appBar: buildAppBar(state.path),
          body: buildBody(state),
        );
      },
    );
  }

  PreferredSizeWidget buildAppBar(String path) {
    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device Browser'),
          Text(
            path,
            style: context.labelM.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            getCubit<FileTransferCubit>().refresh();
          },
          icon: const Icon(Icons.refresh_rounded),
        ),
        TextButton.icon(
          onPressed: () {
            getCubit<FileTransferCubit>().putFile();
          },
          icon: const Icon(Icons.upload_rounded),
          label: const Text('Upload'),
        ),
        if (selectedFile != null && selectedFile!.type == UnisyncFile.Type.FILE)
          TextButton.icon(
            onPressed: () {
              getCubit<FileTransferCubit>().getFiles(selectedFile!);
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download'),
          ),
      ],
    );
  }

  Widget buildBody(FileTransferState state) {
    if (state.status == Status.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView(
      children: [
        if (state.path != '/') buildBack(),
        ...state.currentDirectory.map((e) {
          return buildFile(e);
        }),
      ],
    );
  }

  Widget buildProgressBar() {
    return Row(
      children: [],
    );
  }

  Widget buildFile(UnisyncFile file) {
    return Clickable(
      onDoubleTap: () {
        if (file.type == UnisyncFile.Type.DIRECTORY) {
          getCubit<FileTransferCubit>().goToFolder(file.name);
        }
      },
      onTap: () => setState(() {
        selectedFile = selectedFile == file ? null : file;
      }),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: selectedFile == file ? Colors.grey.shade200 : null,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                () {
                  if (file.type == UnisyncFile.Type.DIRECTORY) {
                    return Icons.folder_rounded;
                  }
                  if (file.type == UnisyncFile.Type.SYMLINK) {
                    return Icons.link;
                  }
                  return Icons.description_rounded;
                }.call(),
              ),
            ),
            Expanded(
              child: Text(
                file.name,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBack() {
    return Clickable(
      onDoubleTap: () {
        getCubit<FileTransferCubit>().goBack();
      },
      child: Container(
        height: height,
        alignment: Alignment.centerLeft,
        child: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text('..'),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
