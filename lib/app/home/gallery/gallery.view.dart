import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unisync/app/home/gallery/gallery.cubit.dart';
import 'package:unisync/app/home/gallery/gallery.state.dart';
import 'package:unisync/components/widgets/clickable.dart';
import 'package:unisync/components/widgets/image.dart';
import 'package:unisync/utils/extensions/state.ext.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          TextButton.icon(
            onPressed: () {
              getCubit<GalleryCubit>().getGallery();
            },
            label: const Text('Reload'),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<GalleryCubit, GalleryState>(
        builder: (context, state) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
            ),
            itemCount: state.media.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: () {
                  if (state.media[index].$2 == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Clickable(
                    onTap: () {
                      getCubit<GalleryCubit>().saveImage(state.media[index].$1);
                    },
                    child: UImage.bytes(
                      state.media[index].$2!,
                      fit: BoxFit.cover,
                    ),
                  );
                }.call(),
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
