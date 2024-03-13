import 'package:flutter/material.dart';
import 'package:unisync/components/resources/resources.dart';
import 'package:unisync/components/widgets/image.dart';

class FileTransferScreen extends StatefulWidget {
  const FileTransferScreen({super.key});

  @override
  State<FileTransferScreen> createState() => _FileTransferScreenState();
}

class _FileTransferScreenState extends State<FileTransferScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UImage.asset(
            R.icon.error,
            width: 64,
            height: 128,
          ),
          const Text('Feature is not available!'),
        ],
      ),
    );
    // return Column(
    //   children: [
    //     Expanded(
    //       child: Row(
    //         children: [
    //           Expanded(
    //             child: Column(
    //               children: [
    //                 buildDeviceName('Your PC'),
    //                 const Divider(),
    //                 Expanded(
    //                   child: buildListFolders(mockFilesPc),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           const VerticalDivider(
    //             width: 0,
    //           ),
    //           Expanded(
    //             child: Column(
    //               children: [
    //                 buildDeviceName('aaaaa'),
    //                 const Divider(),
    //                 Expanded(
    //                   child: buildListFolders(mockFilesMobile),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //     const Divider(
    //       height: 0,
    //     ),
    //     SizedBox(
    //       height: 70,
    //       child: Row(
    //         children: [
    //           Expanded(
    //             child: buildPendingFiles([]),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.symmetric(horizontal: 16),
    //             child: TextButton.icon(
    //               onPressed: () {},
    //               icon: const Icon(Icons.send),
    //               label: const Text('Send'),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }

  Widget buildDeviceName(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: Text(
        name,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildListFolders(List<String> folders) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: folders.map((folder) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.folder,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(folder),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildPendingFiles(List<String> files) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Files to be sent:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: files.map((file) {
                  return Text(file);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
