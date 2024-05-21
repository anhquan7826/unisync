import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' hide context;
import 'package:unisync/app/home/file_transfer/file_transfer.cubit.dart';
import 'package:unisync/app/home/file_transfer/file_transfer.state.dart';
import 'package:unisync/components/enums/status.dart';
import 'package:unisync/components/widgets/clickable.dart';
import 'package:unisync/components/widgets/loading_view.dart';
import 'package:unisync/components/widgets/no_permission_view.dart';
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
          appBar: buildAppBar(state),
          body: buildBody(state),
        );
      },
    );
  }

  PreferredSizeWidget buildAppBar(FileTransferState state) {
    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device Browser'),
          if (state.status == Status.loaded)
            Text(
              state.path,
              style: context.labelM.copyWith(
                color: Colors.grey,
              ),
            ),
        ],
      ),
      actions: state.status != Status.loaded
          ? null
          : [
              IconButton(
                onPressed: () {
                  getCubit<FileTransferCubit>().stop();
                },
                icon: const Icon(Icons.stop),
              ),
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
              if (selectedFile != null &&
                  selectedFile!.type == UnisyncFile.Type.FILE)
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
    if (state.status == Status.idle) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'File server has stopped!',
              style: context.titleM,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                getCubit<FileTransferCubit>().start();
              },
              child: const Text('Start server'),
            ),
          ],
        ),
      );
    }
    if (state.status == Status.loading) {
      return const LoadingView();
    }
    if (state.status == Status.error) {
      return NoPermissionView(
        onReload: () {
          getCubit<FileTransferCubit>().start();
        },
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              if (state.path != '/') buildBack(),
              ...state.currentDirectory.map((e) {
                return buildFile(e);
              }),
            ],
          ),
        ),
        if (state.downloads.isNotEmpty || state.uploads.isNotEmpty)
          buildProgressBar(state),
      ],
    );
  }

  Widget buildProgressBar(FileTransferState state) {
    Widget buildProgress(
      String path,
      double progress, {
      bool download = true,
    }) {
      return Container(
        height: double.infinity,
        width: 400,
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                download ? Icons.download_rounded : Icons.upload_rounded,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${download ? 'Downloading' : 'Uploading'}: ${basename(path)}...',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: context.titleS.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (progress == 1)
                    const Text('Completed!')
                  else
                    LinearProgressIndicator(
                      value: progress,
                    ),
                ],
              ),
            ),
            if (progress == 1)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: IconButton(
                  onPressed: () {
                    if (download) {
                      getCubit<FileTransferCubit>()
                          .removeDownloadProgress(path);
                    } else {
                      getCubit<FileTransferCubit>().removeUploadProgress(path);
                    }
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...state.downloads.entries.map((e) {
            return buildProgress(
              e.key,
              e.value,
            );
          }),
          ...state.uploads.entries.map((e) {
            return buildProgress(
              e.key,
              e.value,
              download: false,
            );
          }),
        ],
      ),
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
