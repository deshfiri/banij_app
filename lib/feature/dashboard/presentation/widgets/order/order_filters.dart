/// Server-side order filters (as sent to `DashboardProvider.fetchOrders`).
/// Immutable: build a new instance to change it.
class OrderFilters {
  final String? search;
  final String? source;
  final String? store;
  final String? status;
  final String? payment;
  final String? from;
  final String? to;
  final String? sort;
  final String? direction;

  const OrderFilters({
    this.search,
    this.source,
    this.store,
    this.status,
    this.payment,
    this.from,
    this.to,
    this.sort,
    this.direction,
  });

  /// From the map returned by `OrderAdvancedFilterSheet`'s onApply
  /// (keys: search, source, store, status, payment, from, to, sort, direction).
  factory OrderFilters.fromMap(Map<String, dynamic> map) => OrderFilters(
        search: map['search'],
        source: map['source'],
        store: map['store'],
        status: map['status'],
        payment: map['payment'],
        from: map['from'],
        to: map['to'],
        sort: map['sort'],
        direction: map['direction'],
      );

  /// Same filters with a different search value (null clears it).
  OrderFilters withSearch(String? value) => OrderFilters(
        search: value,
        source: source,
        store: store,
        status: status,
        payment: payment,
        from: from,
        to: to,
        sort: sort,
        direction: direction,
      );

  /// True when any advanced filter (besides search and sort) is set.
  bool get hasAdvanced =>
      source != null || store != null || status != null || payment != null || from != null || to != null;
}
