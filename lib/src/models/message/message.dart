import 'package:nyxx/src/builders/message/message.dart';
import 'package:nyxx/src/http/managers/message_manager.dart';
import 'package:nyxx/src/models/channel/thread.dart';
import 'package:nyxx/src/models/message/activity.dart';
import 'package:nyxx/src/models/message/attachment.dart';
import 'package:nyxx/src/models/message/channel_mention.dart';
import 'package:nyxx/src/models/message/embed.dart';
import 'package:nyxx/src/models/message/author.dart';
import 'package:nyxx/src/models/message/reference.dart';
import 'package:nyxx/src/models/message/reaction.dart';
import 'package:nyxx/src/models/message/role_subscription_data.dart';
import 'package:nyxx/src/models/snowflake.dart';
import 'package:nyxx/src/models/snowflake_entity/snowflake_entity.dart';
import 'package:nyxx/src/models/user/user.dart';
import 'package:nyxx/src/utils/flags.dart';

/// {@template partial_message}
/// A partial [Message] object.
/// {@endtemplate}
class PartialMessage extends SnowflakeEntity<Message> with SnowflakeEntityMixin<Message> {
  @override
  final MessageManager manager;

  /// The ID of the [Channel] the message was sent in.
  Snowflake get channelId => manager.channelId;

  /// {@macro partial_message}
  PartialMessage({required super.id, required this.manager});

  Future<Message> update(MessageUpdateBuilder builder) => manager.update(id, builder);

  // An often-used alias to update
  Future<Message> edit(MessageUpdateBuilder builder) => update(builder);

  Future<void> delete({String? auditLogReason}) => manager.delete(id, auditLogReason: auditLogReason);

  Future<void> crosspost() => manager.crosspost(id);

  Future<void> pin({String? auditLogReason}) => manager.pin(id, auditLogReason: auditLogReason);

  Future<void> unpin({String? auditLogReason}) => manager.unpin(id, auditLogReason: auditLogReason);
}

/// {@template message}
/// Represents a message sent in a [TextChannel].
///
/// Not all messages are sent by users. Messages can also be system messages such as the "message pinned" notice that is sent to a channel when a message is
/// pinned. Check [type] to see if a message is [MessageType.normal] or [MessageType.reply].
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#message-object
/// {@endtemplate}
class Message extends PartialMessage {
  /// The author of this message.
  ///
  /// This could be a [User] or a [Webhook].
  final MessageAuthor author;

  /// The content of the message.
  ///
  /// {@template message_content_intent_required}
  /// The message content intent is needed for this field to be non-empty.
  /// {@endtemplate}
  final String content;

  /// The time when this message was sent.
  final DateTime timestamp;

  /// The time when this message was last edited, or `null` if the message was never edited.
  final DateTime? editedTimestamp;

  /// Whether this was a TTS message.
  final bool isTts;

  /// Whether this message mentions everyone.
  final bool mentionsEveryone;

  /// A list of users specifically mentioned in this message.
  final List<User> mentions;

  // TODO
  //final List<Role> roleMentions;

  /// A list of channels specifically mentioned in this message.
  final List<ChannelMention> channelMentions;

  /// A list of files attached to this message.
  ///
  /// {@macro message_content_intent_required}
  final List<Attachment> attachments;

  /// A list of embeds in this message.
  ///
  /// {@macro message_content_intent_required}
  final List<Embed> embeds;

  /// A list of reactions to this message.
  final List<Reaction> reactions;

  /// A user-set value to validate a message was sent.
  ///
  /// This can be an [int] or a [String], set using [MessageBuilder.nonce].
  final dynamic /* int | String */ nonce;

  /// Whether this message is pinned.
  final bool isPinned;

  /// The ID of the webhook that sent this message if it was sent by a webhook, `null` otherwise.
  final Snowflake? webhookId;

  /// The type of this message.
  final MessageType type;

  /// Activity information if this message is related to Rich Presence, `null` otherwise.
  final MessageActivity? activity;

  // TODO
  //final PartialApplication? application;

  /// The ID of the [Application] that sent this message if it is an interaction or a webhook, `null` otherwise.
  final Snowflake? applicationId;

  /// Data showing the source of a crosspost, channel follow add, pin, or reply message.
  final MessageReference? reference;

  /// Any flags applied to this message.
  final MessageFlags flags;

  /// The message associated with [reference].
  final Message? referencedMessage;

  // TODO: Do we want to include the interaction field?

  /// The thread that was started from this message if any, `null` otherwise.
  final Thread? thread;

  // TODO
  //final List<MessageComponent> components;

  //TODO (the sticker_items field).
  //final List<Sticker>? stickers;

  /// A generally increasing integer (there may be gaps or duplicates) that represents the approximate position of this message in a thread.
  ///
  /// Can be used to estimate the relative position of the message in a thread in company with [Thread.totalMessagesSent] on parent thread
  final int? position;

  /// Data about the role subscription purchase that prompted this message if this is a [MessageType.roleSubscriptionPurchase] message.
  final RoleSubscriptionData? roleSubscriptionData;

  /// {@macro message}
  Message({
    required super.id,
    required super.manager,
    required this.author,
    required this.content,
    required this.timestamp,
    required this.editedTimestamp,
    required this.isTts,
    required this.mentionsEveryone,
    required this.mentions,
    required this.channelMentions,
    required this.attachments,
    required this.embeds,
    required this.reactions,
    required this.nonce,
    required this.isPinned,
    required this.webhookId,
    required this.type,
    required this.activity,
    required this.applicationId,
    required this.reference,
    required this.flags,
    required this.referencedMessage,
    required this.thread,
    required this.position,
    required this.roleSubscriptionData,
  });
}

/// The type of a message.
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#message-object-message-types
enum MessageType {
  normal._(0),
  recipientAdd._(1),
  recipientRemove._(2),
  call._(3),
  channelNameChange._(4),
  channelIconChange._(5),
  channelPinnedMessage._(6),
  userJoin._(7),
  guildBoost._(8),
  guildBoostTier1._(9),
  guildBoostTier2._(10),
  guildBoostTier3._(11),
  channelFollowAdd._(12),
  guildDiscoveryDisqualified._(14),
  guildDiscoveryRequalified._(15),
  guildDiscoveryGracePeriodInitialWarning._(16),
  guildDiscoveryGracePeriodFinalWarning._(17),
  threadCreated._(18),
  reply._(19),
  chatInputCommand._(20),
  threadStarterMessage._(21),
  guildInviteReminder._(22),
  contextMenuCommand._(23),
  autoModerationAction._(24),
  roleSubscriptionPurchase._(25),
  interactionPremiumUpsell._(26),
  stageStart._(27),
  stageEnd._(28),
  stageSpeaker._(29),
  stageTopic._(31),
  guildApplicationPremiumSubscription._(32);

  /// The value of this [MessageType].
  final int value;

  const MessageType._(this.value);

  /// Parse a [MessageType] from an [int].
  ///
  /// [value] must be a valid [MessageType].
  factory MessageType.parse(int value) => MessageType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => throw FormatException('Unknown MessageType', value),
      );

  @override
  String toString() => 'MessageType($value)';
}

/// Flags that can be applied to a [Message].
///
/// External references:
/// * Discord API Reference: https://discord.com/developers/docs/resources/channel#message-object-message-flags
class MessageFlags extends Flags<MessageFlags> {
  /// This message has been published to subscribed channels (via Channel Following).
  static const crossposted = Flag<MessageFlags>.fromOffset(0);

  /// This message originated from a message in another channel (via Channel Following).
  static const isCrosspost = Flag<MessageFlags>.fromOffset(1);

  /// Do not include any embeds when serializing this message.
  static const suppressEmbeds = Flag<MessageFlags>.fromOffset(2);

  /// The source message for this crosspost has been deleted (via Channel Following).
  static const sourceMessageDeleted = Flag<MessageFlags>.fromOffset(3);

  /// This message came from the urgent message system.
  static const urgent = Flag<MessageFlags>.fromOffset(4);

  /// This message has an associated thread, with the same id as the message.
  static const hasThread = Flag<MessageFlags>.fromOffset(5);

  /// This message is only visible to the user who invoked the Interaction.
  static const ephemeral = Flag<MessageFlags>.fromOffset(6);

  /// This message is an Interaction Response and the bot is "thinking".
  static const loading = Flag<MessageFlags>.fromOffset(7);

  /// This message failed to mention some roles and add their members to the thread.
  static const failedToMentionSomeRolesInThread = Flag<MessageFlags>.fromOffset(8);

  /// This message will not trigger push and desktop notifications.
  static const suppressNotifications = Flag<MessageFlags>.fromOffset(12);

  /// Whether this set of flags has the [crossposted] flag set.
  bool get wasCrossposted => has(crossposted);

  /// Whether this set of flags has the [isCrosspost] flag set.
  bool get isACrosspost => has(isCrosspost);

  /// Whether this set of flags has the [suppressEmbeds] flag set.
  bool get suppressesEmbeds => has(suppressEmbeds);

  /// Whether this set of flags has the [sourceMessageDeleted] flag set.
  bool get sourceMessageWasDeleted => has(sourceMessageDeleted);

  /// Whether this set of flags has the [urgent] flag set.
  bool get isUrgent => has(urgent);

  /// Whether this set of flags has the [hasThread] flag set.
  bool get hasAThread => has(hasThread);

  /// Whether this set of flags has the [ephemeral] flag set.
  bool get isEphemeral => has(ephemeral);

  /// Whether this set of flags has the [loading] flag set.
  bool get isLoading => has(loading);

  /// Whether this set of flags has the [failedToMentionSomeRolesInThread] flag set.
  bool get didFailToMentionSomeRolesInThread => has(failedToMentionSomeRolesInThread);

  /// Whether this set of flags has the [suppressNotifications] flag set.
  bool get suppressesNotifications => has(suppressNotifications);

  /// Create a new [MessageFlags].
  const MessageFlags(super.value);
}
