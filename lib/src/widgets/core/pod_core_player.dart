part of 'package:pod_player/src/pod_player.dart';

class _PodCoreVideoPlayer extends StatelessWidget {
  final VideoPlayerController videoPlayerCtr;
  final double videoAspectRatio;
  final String tag;

  const _PodCoreVideoPlayer({
    required this.videoPlayerCtr,
    required this.videoAspectRatio,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final podCtr = Get.find<PodGetXVideoController>(tag: tag);
    return Builder(
      builder: (ctrx) {
        return RawKeyboardListener(
          autofocus: true,
          focusNode:
              (podCtr.isFullScreen ? FocusNode() : podCtr.keyboardFocusWeb) ??
                  FocusNode(),
          onKey: (value) => podCtr.onKeyBoardEvents(
            event: value,
            appContext: ctrx,
            tag: tag,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: videoAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VideoPlayer(videoPlayerCtr),
                      GetBuilder<PodGetXVideoController>(
                        tag: tag,
                        id: 'closed-captions',
                        builder: (podCtr) {
                          if (!podCtr.isClosedCaptionEnabled) {
                            return const SizedBox.shrink();
                          }
                          return ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: videoPlayerCtr,
                            builder: (context, value, _) {
                              final caption = value.caption.text;
                              if (caption.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Positioned(
                                left: 32,
                                right: 32,
                                bottom: 24,
                                child: IgnorePointer(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.78),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        child: Text(
                                          caption,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            height: 1.25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              GetBuilder<PodGetXVideoController>(
                tag: tag,
                id: 'podVideoState',
                builder: (_) => GetBuilder<PodGetXVideoController>(
                  tag: tag,
                  id: 'video-progress',
                  builder: (podCtr) {
                    if (podCtr.videoThumbnail == null) {
                      return const SizedBox();
                    }

                    if (podCtr.podVideoState == PodVideoState.paused &&
                        podCtr.videoPosition == Duration.zero) {
                      return SizedBox.expand(
                        child: TweenAnimationBuilder<double>(
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: child,
                          ),
                          tween: Tween<double>(begin: 0.7, end: 1),
                          duration: const Duration(milliseconds: 400),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              image: podCtr.videoThumbnail,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              _VideoOverlays(tag: tag),
              IgnorePointer(
                child: GetBuilder<PodGetXVideoController>(
                  tag: tag,
                  id: 'podVideoState',
                  builder: (podCtr) {
                    final loadingWidget = podCtr.onLoading?.call(context) ??
                        const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.transparent,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );

                    if (kIsWeb) {
                      switch (podCtr.podVideoState) {
                        case PodVideoState.loading:
                          return loadingWidget;
                        case PodVideoState.paused:
                          return const Center(
                            child: Icon(
                              Icons.play_arrow,
                              size: 45,
                              color: Colors.white,
                            ),
                          );
                        case PodVideoState.playing:
                          return Center(
                            child: TweenAnimationBuilder<double>(
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: child,
                              ),
                              tween: Tween<double>(begin: 1, end: 0),
                              duration: const Duration(seconds: 1),
                              child: const Icon(
                                Icons.pause,
                                size: 45,
                                color: Colors.white,
                              ),
                            ),
                          );
                        case PodVideoState.error:
                          return const SizedBox();
                      }
                    } else {
                      if (podCtr.podVideoState == PodVideoState.loading) {
                        return loadingWidget;
                      }
                      return const SizedBox();
                    }
                  },
                ),
              ),
              if (!kIsWeb)
                GetBuilder<PodGetXVideoController>(
                  tag: tag,
                  id: 'full-screen',
                  builder: (podCtr) => podCtr.isFullScreen
                      ? const SizedBox()
                      : GetBuilder<PodGetXVideoController>(
                          tag: tag,
                          id: 'overlay',
                          builder: (podCtr) => podCtr.isOverlayVisible ||
                                  !podCtr.alwaysShowProgressBar
                              ? const SizedBox()
                              : Align(
                                  alignment: Alignment.bottomCenter,
                                  child: PodProgressBar(
                                    tag: tag,
                                    alignment: Alignment.bottomCenter,
                                    podProgressBarConfig:
                                        podCtr.podProgressBarConfig,
                                  ),
                                ),
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ClosedCaptionButton extends StatelessWidget {
  final String tag;
  final Color color;

  const _ClosedCaptionButton({
    required this.tag,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PodGetXVideoController>(
      tag: tag,
      id: 'closed-captions',
      builder: (podCtr) => MaterialIconButton(
        toolTipMesg: podCtr.podPlayerLabels.closedCaptions,
        color: color,
        onPressed: podCtr.toggleClosedCaptions,
        child: Icon(
          podCtr.isClosedCaptionEnabled
              ? Icons.closed_caption
              : Icons.closed_caption_disabled,
        ),
      ),
    );
  }
}
