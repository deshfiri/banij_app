import 'dart:convert';

class MyWebsitesResponseModel {
  final List<WebsiteItemModel>? data;
  final List<WebsiteAllocationModel>? allocations;
  final EntitlementModel? entitlement;
  final bool? success;
  final String? message;

  MyWebsitesResponseModel({
    this.data,
    this.allocations,
    this.entitlement,
    this.success,
    this.message,
  });

  factory MyWebsitesResponseModel.fromRawJson(String str) =>
      MyWebsitesResponseModel.fromJson(json.decode(str));

  factory MyWebsitesResponseModel.fromJson(dynamic jsonInput) {
    if (jsonInput is String) {
      return MyWebsitesResponseModel.fromRawJson(jsonInput);
    }
    if (jsonInput is! Map<String, dynamic>) {
      return MyWebsitesResponseModel(data: [], allocations: []);
    }

    final rawData = jsonInput['data'];
    List<WebsiteItemModel> dataList = [];
    if (rawData is List) {
      dataList = rawData.map((x) => WebsiteItemModel.fromJson(x)).toList();
    }

    final rawAllocations = jsonInput['allocations'];
    List<WebsiteAllocationModel> allocList = [];
    if (rawAllocations is List) {
      allocList = rawAllocations.map((x) => WebsiteAllocationModel.fromJson(x)).toList();
    }

    return MyWebsitesResponseModel(
      success: jsonInput['success'] is bool ? jsonInput['success'] : true,
      message: jsonInput['message']?.toString(),
      data: dataList,
      allocations: allocList,
      entitlement: jsonInput['entitlement'] != null
          ? EntitlementModel.fromJson(jsonInput['entitlement'])
          : null,
    );
  }
}

class WebsiteItemModel {
  final String? id;
  final String? name;
  final String? host;
  final String? status;
  final String? statusLabel;
  final dynamic isLive;
  final String? connectionHealth;
  final String? lastSyncedAt;
  final String? outstandingCharges;
  final String? createdAt;

  WebsiteItemModel({
    this.id,
    this.name,
    this.host,
    this.status,
    this.statusLabel,
    this.isLive,
    this.connectionHealth,
    this.lastSyncedAt,
    this.outstandingCharges,
    this.createdAt,
  });

  factory WebsiteItemModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return WebsiteItemModel();
    return WebsiteItemModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? json['host']?.toString(),
      host: json['host']?.toString(),
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString() ?? 'Active',
      isLive: json['is_live'],
      connectionHealth: json['connection_health']?.toString(),
      lastSyncedAt: json['last_synced_at']?.toString(),
      outstandingCharges: json['outstanding_charges']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class WebsiteAllocationModel {
  final String? id;
  final String? slot;
  final String? name;
  final String? domainName;
  final String? partnerName;
  final String? packageName;
  final String? status;
  final String? statusLabel;
  final String? statusTone;
  final WebsiteRefModel? website;

  WebsiteAllocationModel({
    this.id,
    this.slot,
    this.name,
    this.domainName,
    this.partnerName,
    this.packageName,
    this.status,
    this.statusLabel,
    this.statusTone,
    this.website,
  });

  factory WebsiteAllocationModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return WebsiteAllocationModel();
    return WebsiteAllocationModel(
      id: json['id']?.toString(),
      slot: json['slot']?.toString(),
      name: json['name']?.toString() ?? json['domain_name']?.toString(),
      domainName: json['domain_name']?.toString(),
      partnerName: json['partner_name']?.toString(),
      packageName: json['package_name']?.toString(),
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString() ?? 'Active',
      statusTone: json['status_tone']?.toString(),
      website: json['website'] != null ? WebsiteRefModel.fromJson(json['website']) : null,
    );
  }
}

class WebsiteRefModel {
  final String? id;
  final String? host;
  final String? url;

  WebsiteRefModel({this.id, this.host, this.url});

  factory WebsiteRefModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return WebsiteRefModel();
    return WebsiteRefModel(
      id: json['id']?.toString(),
      host: json['host']?.toString(),
      url: json['url']?.toString(),
    );
  }
}

class EntitlementModel {
  final bool? allowed;
  final bool? expired;
  final int? limit;
  final int? used;
  final int? remaining;

  EntitlementModel({
    this.allowed,
    this.expired,
    this.limit,
    this.used,
    this.remaining,
  });

  factory EntitlementModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return EntitlementModel();
    return EntitlementModel(
      allowed: json['allowed'] is bool ? json['allowed'] : null,
      expired: json['expired'] is bool ? json['expired'] : null,
      limit: json['limit'] is int ? json['limit'] : null,
      used: json['used'] is int ? json['used'] : null,
      remaining: json['remaining'] is int ? json['remaining'] : null,
    );
  }
}
