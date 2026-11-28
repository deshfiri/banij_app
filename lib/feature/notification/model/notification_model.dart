import 'dart:convert';

class NotificationResponseModel {
  final List<NotificationItemModel>? data;
  final int? unreadCount;
  final bool? success;
  final String? message;

  NotificationResponseModel({
    this.data,
    this.unreadCount,
    this.success,
    this.message,
  });

  factory NotificationResponseModel.fromRawJson(String str) =>
      NotificationResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NotificationResponseModel.fromJson(dynamic jsonInput) {
    if (jsonInput is List) {
      return NotificationResponseModel(
        data: List<NotificationItemModel>.from(
            jsonInput.map((x) => NotificationItemModel.fromJson(x))),
        success: true,
      );
    } else if (jsonInput is Map<String, dynamic>) {
      final dataList = jsonInput["data"] ?? jsonInput["notifications"] ?? [];
      return NotificationResponseModel(
        data: dataList is List
            ? List<NotificationItemModel>.from(
                dataList.map((x) => NotificationItemModel.fromJson(x)))
            : [],
        unreadCount: jsonInput["unread_count"] is int ? jsonInput["unread_count"] : null,
        success: jsonInput["success"] is bool ? jsonInput["success"] : true,
        message: jsonInput["message"] as String?,
      );
    }
    return NotificationResponseModel(data: []);
  }

  Map<String, dynamic> toJson() => {
        "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : [],
        if (unreadCount != null) "unread_count": unreadCount,
        if (success != null) "success": success,
        if (message != null) "message": message,
      };
}

class NotificationItemModel {
  final String? id;

  /// Server-side kind, e.g. `order_shipped` or a Laravel notification class
  /// name. Used to pick the category icon/colour; may be null.
  final String? type;
  final String? title;
  final String? description;
  final String? createdAtHuman;
  final String? createdAt;
  final String? readAt;
  final bool? isRead;

  NotificationItemModel({
    this.id,
    this.type,
    this.title,
    this.description,
    this.createdAtHuman,
    this.createdAt,
    this.readAt,
    this.isRead,
  });

  String? get message => description;
  String? get time => createdAtHuman ?? createdAt;

  factory NotificationItemModel.fromRawJson(String str) =>
      NotificationItemModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NotificationItemModel.fromJson(Map<String, dynamic> jsonMap) {
    // Laravel database notifications keep the payload in a nested `data` map;
    // flat responses keep it at the top level. Read top level first.
    final nested = jsonMap["data"] is Map ? jsonMap["data"] as Map : const {};
    String? pick(List<String> keys) {
      for (final key in keys) {
        final value = jsonMap[key] ?? nested[key];
        if (value != null && value.toString().trim().isNotEmpty) return value.toString();
      }
      return null;
    }

    return NotificationItemModel(
      id: jsonMap["id"]?.toString(),
      type: pick(["type", "category", "notification_type", "event"]),
      title: pick(["title", "subject"]) ?? 'Notification',
      description: pick(["description", "message", "body"]) ?? '',
      createdAtHuman: pick(["created_at_human", "time", "created_at"]) ?? '',
      createdAt: jsonMap["created_at"]?.toString() ?? '',
      readAt: jsonMap["read_at"]?.toString(),
      isRead: jsonMap["is_read"] is bool
          ? jsonMap["is_read"]
          : (jsonMap["read_at"] != null || jsonMap["isRead"] == true),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        if (type != null) "type": type,
        "title": title,
        "description": description,
        "created_at_human": createdAtHuman,
        "created_at": createdAt,
        "read_at": readAt,
        "is_read": isRead,
      };
}
