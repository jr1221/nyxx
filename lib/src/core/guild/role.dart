import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/core/discord_color.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/internal/interfaces/mentionable.dart';
import 'package:nyxx/src/typedefs.dart';
import 'package:nyxx/src/utils/builders/guild_builder.dart';

abstract class IRole implements SnowflakeEntity, Mentionable {
  /// Reference to client
  INyxx get client;

  /// Cacheable or guild attached to this role instance
  Cacheable<Snowflake, IGuild> get guild;

  /// The role's name.
  String get name;

  /// The role's color, 0 if no color.
  DiscordColor get color;

  /// The role's position.
  int get position;

  /// If the role is pinned in the user listing.
  bool get hoist;

  /// Whether or not the role is managed by an integration.
  bool get managed;

  /// Whether or not the role is mentionable.
  bool get mentionable;

  /// The role's permissions.
  IPermissions get permissions;

  /// Additional role data like if role is managed by integration or role is from server boosting.
  IRoleTags? get roleTags;

  /// Hash of role icon
  String? get iconHash;

  /// Emoji that represents role.
  /// For now emoji data is not validated and this can be any arbitrary string
  String? get iconEmoji;

  /// Mention of role. If role cannot be mentioned it returns name of role (@name)
  @override
  String get mention;

  /// Returns url to role icon
  String? iconURL({String format = "webp", int size = 128});

  /// Edits the role.
  Future<IRole> edit(RoleBuilder role, {String? auditReason});

  /// Deletes the role.
  Future<void> delete();
}

class Role extends SnowflakeEntity implements IRole {
  /// Reference to client
  @override
  final INyxx client;

  /// Cacheable or guild attached to this role instance
  @override
  late final Cacheable<Snowflake, IGuild> guild;

  /// The role's name.
  @override
  late final String name;

  /// The role's color, 0 if no color.
  @override
  late final DiscordColor color;

  /// The role's position.
  @override
  late final int position;

  /// If the role is pinned in the user listing.
  @override
  late final bool hoist;

  /// Whether or not the role is managed by an integration.
  @override
  late final bool managed;

  /// Whether or not the role is mentionable.
  @override
  late final bool mentionable;

  /// The role's permissions.
  @override
  late final IPermissions permissions;

  /// Additional role data like if role is managed by integration or role is from server boosting.
  @override
  late final IRoleTags? roleTags;

  /// Hash of role icon
  @override
  late final String? iconHash;

  /// Emoji that represents role.
  /// For now emoji data is not validated and this can be any arbitrary string
  @override
  late final String? iconEmoji;

  /// Mention of role. If role cannot be mentioned it returns name of role (@name)
  @override
  String get mention {
    String mentionString;

    if (mentionable) {
      if (id == guild.id) {
        mentionString = name;
      } else {
        mentionString = '<@&$id>';
      }
    } else {
      if (id == guild.id) {
        mentionString = name;
      } else {
        mentionString = '@$name';
      }
    }

    return mentionString;
  }

  /// Creates an instance of [Role]
  Role(this.client, RawApiMap raw, Snowflake guildId) : super(Snowflake(raw["id"])) {
    name = raw["name"] as String;
    position = raw["position"] as int;
    hoist = raw["hoist"] as bool;
    managed = raw["managed"] as bool;
    mentionable = raw["mentionable"] as bool? ?? false;
    permissions = Permissions(int.parse(raw["permissions"] as String));
    color = DiscordColor.fromInt(raw["color"] as int);
    guild = GuildCacheable(client, guildId);
    iconEmoji = raw["unicode_emoji"] as String?;
    iconHash = raw["icon"] as String?;

    if (raw["tags"] != null) {
      roleTags = RoleTags(raw["tags"] as RawApiMap);
    } else {
      roleTags = null;
    }
  }

  /// Returns url to role icon
  @override
  String? iconURL({String format = "webp", int size = 128}) {
    if (iconHash == null) {
      return null;
    }

    return client.httpEndpoints.getRoleIconUrl(id, iconHash!, format, size);
  }

  /// Edits the role.
  @override
  Future<IRole> edit(RoleBuilder role, {String? auditReason}) async => client.httpEndpoints.editRole(guild.id, id, role, auditReason: auditReason);

  /// Deletes the role.
  @override
  Future<void> delete() async => client.httpEndpoints.deleteRole(guild.id, id);
}

abstract class IRoleTags {
  /// Holds [Snowflake] of bot id if role is for bot user
  Snowflake? get botId;

  /// True if role is for server nitro boosting
  bool get nitroRole;

  /// Holds [Snowflake] of integration if role is part of twitch/other integration
  Snowflake? get integrationId;

  /// Returns true if role is for bot.
  bool get isBotRole;
}

/// Additional [Role] role tags which hold optional data about role
class RoleTags implements IRoleTags {
  /// Holds [Snowflake] of bot id if role is for bot user
  @override
  late final Snowflake? botId;

  /// True if role is for server nitro boosting
  @override
  late final bool nitroRole;

  /// Holds [Snowflake] of integration if role is part of twitch/other integration
  @override
  late final Snowflake? integrationId;

  /// Returns true if role is for bot.
  @override
  bool get isBotRole => botId != null;

  /// Creates an instance of [RoleTags]
  RoleTags(RawApiMap raw) {
    botId = raw["bot_id"] != null ? Snowflake(raw["bot_id"]) : null;
    nitroRole = raw["premium_subscriber"] != null ? raw["premium_subscriber"] as bool : false;
    integrationId = raw["integration_id"] != null ? Snowflake(raw["integration_id"]) : null;
  }
}

enum ApplicationRoleConnectionMetadataType {
  integerLessThanOrEqual(1),
  integerGreaterThanOrEqual(2),
  integerEqual(3),
  integerNotEqual(4),
  datetimeLessThanOrEqual(5),
  datetimeGreaterThanOrEqual(6),
  booleanEqual(7),
  booleanNotEqual(8);

  final int _value;
  const ApplicationRoleConnectionMetadataType(this._value);

  static ApplicationRoleConnectionMetadataType _fromValue(int value) => values.firstWhere((element) => element._value == value);
}

abstract class IApplicationRoleConnectionMetadata {
  /// The type of metadata value.
  ApplicationRoleConnectionMetadataType get type;

  /// Dictionary key for the metadata field (must be `a-z`, `0-9`, or `_` characters; 1-50 characters)
  String get key;

  /// Name of the metadata field (1-100 characters)
  String get name;

  /// Translations of the name.
  // TODO(Rapougnac): Move `Locale` enum from `nyxx_interactions` to `nyxx`.
  Object? get localizedNames;

  /// Description of the metadata field (1-200 characters).
  String get description;

  /// Translations of the description.
  Object? get localizedDescriptions;

  ApplicationRoleConnectionMetadataBuilder toBuilder();
}

class ApplicationRoleConnectionMetadata implements IApplicationRoleConnectionMetadata {
  @override
  late final ApplicationRoleConnectionMetadataType type;

  @override
  late final String key;

  @override
  late final String name;

  @override
  late final Object? localizedNames;

  @override
  late final String description;

  @override
  late final Object? localizedDescriptions;

  ApplicationRoleConnectionMetadata(RawApiMap raw) {
    type = ApplicationRoleConnectionMetadataType._fromValue(raw["type"] as int);
    key = raw["key"] as String;
    name = raw["name"] as String;
    localizedNames = raw["localized_names"];
    description = raw["description"] as String;
    localizedDescriptions = raw["localized_descriptions"];
  }

  @override
  ApplicationRoleConnectionMetadataBuilder toBuilder() => ApplicationRoleConnectionMetadataBuilder(
        key: key,
        name: name,
        description: description,
        type: type,
        localizedNames: localizedNames,
        localizedDescriptions: localizedDescriptions,
      );
}
