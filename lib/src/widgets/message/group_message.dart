import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/bubble_rtl_alignment.dart';
import '../../models/emoji_enlargement_behavior.dart';
import '../../util.dart';
import '../state/inherited_chat_theme.dart';
import '../state/inherited_user.dart';
import 'file_message.dart';
import 'group_text_message.dart';
import 'image_message.dart';
import 'text_message.dart';
import 'user_avatar.dart';

/// Base widget for all message types in the chat. Renders bubbles around
/// messages and status. Sets maximum width for a message for
/// a nice look on larger screens.
class GroupMessage extends StatelessWidget {
  /// Creates a particular message from any message type.
  const GroupMessage({
    super.key,
    this.checkBoxBuilder,
    this.onCheckMessageTap,
    this.editing = false,
    this.audioMessageBuilder,
    this.avatarBuilder,
    this.bubbleBuilder,
    this.bubbleRtlAlignment,
    this.customMessageBuilder,
    this.customStatusBuilder,
    required this.emojiEnlargementBehavior,
    this.fileMessageBuilder,
    required this.hideBackgroundOnEmojiMessages,
    this.imageHeaders,
    this.imageMessageBuilder,
    required this.message,
    required this.messageWidth,
    this.nameBuilder,
    this.onAvatarTap,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onMessageShareTap,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    required this.roundBorder,
    required this.showAvatar,
    required this.showName,
    required this.showStatus,
    required this.showUserAvatars,
    this.textMessageBuilder,
    required this.textMessageOptions,
    required this.usePreviewData,
    this.userAgent,
    this.videoMessageBuilder,
  });

  /// Build an audio message inside predefined bubble.
  final Widget Function(types.AudioMessage, {required int messageWidth})?
      audioMessageBuilder;

  final Widget Function(types.Message)? checkBoxBuilder;

  /// Called when user taps on any message,editing.
  final void Function(BuildContext context, types.Message)? onCheckMessageTap;
  final bool editing;

  /// This is to allow custom user avatar builder
  /// By using this we can fetch newest user info based on id
  final Widget Function(String userId)? avatarBuilder;

  /// Customize the default bubble using this function. `child` is a content
  /// you should render inside your bubble, `message` is a current message
  /// (contains `author` inside) and `nextMessageInGroup` allows you to see
  /// if the message is a part of a group (messages are grouped when written
  /// in quick succession by the same author)
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// Determine the alignment of the bubble for RTL languages. Has no effect
  /// for the LTR languages.
  final BubbleRtlAlignment? bubbleRtlAlignment;

  /// Build a custom message inside predefined bubble.
  final Widget Function(types.CustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// Build a custom status widgets.
  final Widget Function(types.Message message, {required BuildContext context})?
      customStatusBuilder;

  /// Controls the enlargement behavior of the emojis in the
  /// [types.TextMessage].
  /// Defaults to [EmojiEnlargementBehavior.multi].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Build a file message inside predefined bubble.
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Hide background for messages containing only emojis.
  final bool hideBackgroundOnEmojiMessages;

  /// See [Chat.imageHeaders].
  final Map<String, String>? imageHeaders;

  /// Build an image message inside predefined bubble.
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  /// Any message type.
  final types.Message message;

  /// Maximum message width.
  final int messageWidth;

  /// See [TextMessage.nameBuilder].
  final Widget Function(String userId)? nameBuilder;

  /// See [UserAvatar.onAvatarTap].
  final void Function(types.User)? onAvatarTap;

  /// Called when user double taps on any message.
  final void Function(BuildContext context, types.Message)? onMessageDoubleTap;

  /// Called when user makes a long press on any message.
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// Called when user makes a long press on status icon in any message.
  final void Function(BuildContext context, types.Message)?
      onMessageStatusLongPress;

  /// Called when user taps on status icon in any message.
  final void Function(BuildContext context, types.Message)? onMessageStatusTap;

  /// Called when user taps on any message.
  final void Function(BuildContext context, types.Message)? onMessageTap;

  /// Called when user taps on any message.
  final void Function(BuildContext context, types.Message)? onMessageShareTap;

  /// Called when the message's visibility changes.
  final void Function(types.Message, bool visible)? onMessageVisibilityChanged;

  /// See [TextMessage.onPreviewDataFetched].
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Rounds border of the message to visually group messages together.
  final bool roundBorder;

  /// Show user avatar for the received message. Useful for a group chat.
  final bool showAvatar;

  /// See [TextMessage.showName].
  final bool showName;

  /// Show message's status.
  final bool showStatus;

  /// Show user avatars for received messages. Useful for a group chat.
  final bool showUserAvatars;

  /// Build a text message inside predefined bubble.
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// See [TextMessage.options].
  final TextMessageOptions textMessageOptions;

  /// See [TextMessage.usePreviewData].
  final bool usePreviewData;

  /// See [TextMessage.userAgent].
  final String? userAgent;

  /// Build an audio message inside predefined bubble.
  final Widget Function(types.VideoMessage, {required int messageWidth})?
      videoMessageBuilder;

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final user = InheritedUser.of(context).user;
    final enlargeEmojis =
        emojiEnlargementBehavior != EmojiEnlargementBehavior.never &&
            message is types.TextMessage &&
            isConsistsOfEmojis(
              emojiEnlargementBehavior,
              message as types.TextMessage,
            );
    final messageBorderRadius =
        InheritedChatTheme.of(context).theme.messageBorderRadius;
    final borderRadius = BorderRadius.circular(messageBorderRadius);

    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsetsDirectional.only(
        top: 20,
        bottom: 20,
        end: 10,
        start: 15,
      ),
      color: message.repliedMessage != null
          ? Theme.of(context).cardColor
          : const Color(0xFFE8E8E8),
      child: GestureDetector(
        onDoubleTap: () =>
            editing ? null : onMessageDoubleTap?.call(context, message),
        onLongPress: () =>
            editing ? null : onMessageLongPress?.call(context, message),
        onTap: () => editing
            ? onCheckMessageTap?.call(context, message)
            : onMessageTap?.call(context, message),
        child: Column(children: [
          CustomPaint(
            painter: VerticalLinePainter(
              color: message.repliedMessage != null
                  ? Theme.of(context).dividerColor
                  : Colors.transparent,
              width: 1,
              paddingTop: 50,
              paddingLeft: 20,
              paddingBottom: 35,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              textDirection: null,
              children: [
                checkBoxBuilder != null
                    ? Visibility(
                        visible: editing,
                        child: checkBoxBuilder!(message),
                      )
                    : Container(),
                Visibility(
                  visible: editing,
                  child: const Spacer(),
                ),
                if (showUserAvatars) _avatarBuilder(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: messageWidth.toDouble(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      onMessageVisibilityChanged != null
                          ? VisibilityDetector(
                              key: Key(message.id),
                              onVisibilityChanged: (visibilityInfo) =>
                                  onMessageVisibilityChanged!(
                                message,
                                visibilityInfo.visibleFraction > 0.1,
                              ),
                              child: _bubbleBuilder(
                                context,
                                borderRadius
                                    .resolve(Directionality.of(context)),
                                false,
                                enlargeEmojis,
                              ),
                            )
                          : _bubbleBuilder(
                              context,
                              borderRadius.resolve(Directionality.of(context)),
                              false,
                              enlargeEmojis,
                            ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => onMessageShareTap?.call(
                    context,
                    message,
                  ),
                  child: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),
          if (message.repliedMessage != null)
            const Padding(padding: EdgeInsets.only(top: 20)),
          if (message.repliedMessage != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              textDirection: null,
              children: [
                if (showUserAvatars) _replyAvatarBuilder(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: messageWidth.toDouble(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onDoubleTap: () => onMessageDoubleTap?.call(
                          context,
                          message,
                        ),
                        onLongPress: () => onMessageLongPress?.call(
                          context,
                          message,
                        ),
                        onTap: () => onMessageTap?.call(
                          context,
                          message.repliedMessage!,
                        ),
                        child: onMessageVisibilityChanged != null
                            ? VisibilityDetector(
                                key: Key(message.repliedMessage!.id),
                                onVisibilityChanged: (visibilityInfo) =>
                                    onMessageVisibilityChanged!(
                                  message.repliedMessage!,
                                  visibilityInfo.visibleFraction > 0.1,
                                ),
                                child: _replyBubbleBuilder(
                                  context,
                                  borderRadius
                                      .resolve(Directionality.of(context)),
                                  false,
                                  enlargeEmojis,
                                ),
                              )
                            : _replyBubbleBuilder(
                                context,
                                borderRadius
                                    .resolve(Directionality.of(context)),
                                false,
                                enlargeEmojis,
                              ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
        ]),
      ),
    );
  }

  Widget _avatarBuilder() => showAvatar
      ? avatarBuilder?.call(message.author.id) ??
          UserAvatar(
            author: message.author,
            bubbleRtlAlignment: bubbleRtlAlignment,
            imageHeaders: imageHeaders,
            onAvatarTap: onAvatarTap,
          )
      : const SizedBox(width: 40);

  Widget _replyAvatarBuilder() => showAvatar
      ? avatarBuilder?.call(message.repliedMessage!.author.id) ??
          UserAvatar(
            author: message.repliedMessage!.author,
            bubbleRtlAlignment: bubbleRtlAlignment,
            imageHeaders: imageHeaders,
            onAvatarTap: onAvatarTap,
          )
      : const SizedBox(width: 40);

  Widget _bubbleBuilder(
    BuildContext context,
    BorderRadius borderRadius,
    bool currentUserIsAuthor,
    bool enlargeEmojis,
  ) =>
      bubbleBuilder != null
          ? bubbleBuilder!(
              _messageBuilder(),
              message: message,
              nextMessageInGroup: roundBorder,
            )
          : enlargeEmojis && hideBackgroundOnEmojiMessages
              ? _messageBuilder()
              : Container(
                  decoration: message.type == types.MessageType.image
                      ? BoxDecoration(
                          borderRadius: borderRadius,
                          color: !currentUserIsAuthor ||
                                  message.type == types.MessageType.image
                              ? InheritedChatTheme.of(context)
                                  .theme
                                  .secondaryColor
                              : InheritedChatTheme.of(context)
                                  .theme
                                  .primaryColor,
                        )
                      : null,
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: _messageBuilder(),
                  ),
                );

  Widget _replyBubbleBuilder(
    BuildContext context,
    BorderRadius borderRadius,
    bool currentUserIsAuthor,
    bool enlargeEmojis,
  ) =>
      bubbleBuilder != null
          ? bubbleBuilder!(
              _replyMessageBuilder(),
              message: message.repliedMessage!,
              nextMessageInGroup: roundBorder,
            )
          : enlargeEmojis && hideBackgroundOnEmojiMessages
              ? _replyMessageBuilder()
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: !currentUserIsAuthor ||
                            message.repliedMessage!.type ==
                                types.MessageType.image
                        ? InheritedChatTheme.of(context).theme.secondaryColor
                        : InheritedChatTheme.of(context).theme.primaryColor,
                  ),
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: _replyMessageBuilder(),
                  ),
                );

  Widget _messageBuilder() {
    switch (message.type) {
      case types.MessageType.audio:
        final audioMessage = message as types.AudioMessage;
        return audioMessageBuilder != null
            ? audioMessageBuilder!(audioMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.custom:
        final customMessage = message as types.CustomMessage;
        return customMessageBuilder != null
            ? customMessageBuilder!(customMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.file:
        final fileMessage = message as types.FileMessage;
        return fileMessageBuilder != null
            ? fileMessageBuilder!(fileMessage, messageWidth: messageWidth)
            : FileMessage(message: fileMessage);
      case types.MessageType.image:
        final imageMessage = message as types.ImageMessage;
        return imageMessageBuilder != null
            ? imageMessageBuilder!(imageMessage, messageWidth: messageWidth)
            : ImageMessage(
                imageHeaders: imageHeaders,
                message: imageMessage,
                messageWidth: messageWidth,
              );
      case types.MessageType.text:
        final textMessage = message as types.TextMessage;
        return textMessageBuilder != null
            ? textMessageBuilder!(
                textMessage,
                messageWidth: messageWidth,
                showName: showName,
              )
            : GroupTextMessage(
                emojiEnlargementBehavior: emojiEnlargementBehavior,
                hideBackgroundOnEmojiMessages: hideBackgroundOnEmojiMessages,
                message: textMessage,
                nameBuilder: nameBuilder,
                onPreviewDataFetched: onPreviewDataFetched,
                options: textMessageOptions,
                showName: showName,
                usePreviewData: usePreviewData,
                userAgent: userAgent,
              );
      case types.MessageType.video:
        final videoMessage = message as types.VideoMessage;
        return videoMessageBuilder != null
            ? videoMessageBuilder!(videoMessage, messageWidth: messageWidth)
            : const SizedBox();
      default:
        return const SizedBox();
    }
  }

  Widget _replyMessageBuilder() {
    switch (message.repliedMessage!.type) {
      case types.MessageType.audio:
        final audioMessage = message.repliedMessage! as types.AudioMessage;
        return audioMessageBuilder != null
            ? audioMessageBuilder!(audioMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.custom:
        final customMessage = message.repliedMessage! as types.CustomMessage;
        return customMessageBuilder != null
            ? customMessageBuilder!(customMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.file:
        final fileMessage = message.repliedMessage! as types.FileMessage;
        return fileMessageBuilder != null
            ? fileMessageBuilder!(fileMessage, messageWidth: messageWidth)
            : FileMessage(message: fileMessage);
      case types.MessageType.image:
        final imageMessage = message.repliedMessage! as types.ImageMessage;
        return imageMessageBuilder != null
            ? imageMessageBuilder!(imageMessage, messageWidth: messageWidth)
            : ImageMessage(
                imageHeaders: imageHeaders,
                message: imageMessage,
                messageWidth: messageWidth,
              );
      case types.MessageType.text:
        final textMessage = message.repliedMessage! as types.TextMessage;
        return textMessageBuilder != null
            ? textMessageBuilder!(
                textMessage,
                messageWidth: messageWidth,
                showName: showName,
              )
            : GroupTextMessage(
                emojiEnlargementBehavior: emojiEnlargementBehavior,
                hideBackgroundOnEmojiMessages: hideBackgroundOnEmojiMessages,
                message: textMessage,
                nameBuilder: nameBuilder,
                onPreviewDataFetched: onPreviewDataFetched,
                options: textMessageOptions,
                showName: showName,
                usePreviewData: usePreviewData,
                userAgent: userAgent,
              );
      case types.MessageType.video:
        final videoMessage = message.repliedMessage! as types.VideoMessage;
        return videoMessageBuilder != null
            ? videoMessageBuilder!(videoMessage, messageWidth: messageWidth)
            : const SizedBox();
      default:
        return const SizedBox();
    }
  }
}

class VerticalLinePainter extends CustomPainter {
  VerticalLinePainter({
    this.color = Colors.grey,
    this.width = 1,
    this.paddingLeft = 0,
    this.paddingTop = 0,
    this.paddingBottom = 0,
  });

  final Color color;

  final double width;

  final double paddingLeft;

  final double paddingTop;

  final double paddingBottom;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.style = PaintingStyle.fill;
    paint.color = color;
    final path = Path();
    path.moveTo(paddingLeft, paddingTop); //左上点
    path.lineTo(paddingLeft, size.height + paddingTop - paddingBottom); //左下点
    path.lineTo(
      width + paddingLeft,
      size.height + paddingTop - paddingBottom,
    ); //右下点
    path.lineTo(width + paddingLeft, paddingTop); //右上点
    path.close();
    canvas.drawPath(path, paint);
  }

  ///有变化刷新
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
