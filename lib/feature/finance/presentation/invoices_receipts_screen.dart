import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/empty_state_widget.dart';
import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/invoice_provider.dart';
import 'widgets/invoices/finance_list_cards.dart';

class InvoicesReceiptsScreen extends StatefulWidget {
  final String initialTab; // 'Invoices' or 'Receipts'

  const InvoicesReceiptsScreen({super.key, this.initialTab = 'Invoices'});

  static Future<void> open(
    BuildContext context, {
    String initialTab = 'Invoices',
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicesReceiptsScreen(initialTab: initialTab),
      ),
    );
  }

  @override
  State<InvoicesReceiptsScreen> createState() => _InvoicesReceiptsScreenState();
}

class _InvoicesReceiptsScreenState extends State<InvoicesReceiptsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'Receipts' ? 1 : 0,
    );
    _tabController.addListener(_loadSelectedTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadSelectedTab();
    });
  }

  void _loadSelectedTab() {
    if (_tabController.indexIsChanging) return;
    final provider = context.read<InvoiceProvider>();
    if (_tabController.index == 0) {
      provider.fetchInvoices();
    } else {
      provider.fetchReceipts();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_loadSelectedTab);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildList<T>({
    required bool isLoading,
    required String? error,
    required List<T> items,
    required String emptyMessage,
    required VoidCallback onRetry,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryOrange));
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 38.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
              UIHelper.verticalSpace(10.h),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColorsTheme.textMutedColor(context),
                ),
              ),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        message: emptyMessage,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      itemCount: items.length,
      itemBuilder: itemBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final query = _searchQuery.toLowerCase();
    final invoices = provider.invoiceResponse?.data ?? const [];
    final receipts = provider.receiptResponse?.data ?? const [];
    final filteredInvoices = invoices.where((invoice) {
      return (invoice.number ?? '').toLowerCase().contains(query) ||
          invoice.displayPurpose.toLowerCase().contains(query) ||
          invoice.displayStatus.toLowerCase().contains(query);
    }).toList();
    final filteredReceipts = receipts.where((receipt) {
      return receipt.displayNumber.toLowerCase().contains(query) ||
          receipt.displayGateway.toLowerCase().contains(query) ||
          receipt.displayStatus.toLowerCase().contains(query);
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'Invoices & Receipts',
              subtitle: 'B2B Wholesale Transactions & Billing',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    UIHelper.verticalSpace(14.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: AppColorsTheme.innerCardBg(context),
                          borderRadius: BorderRadius.circular(19.r),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          indicatorColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: primaryOrange,
                            borderRadius: BorderRadius.circular(17.r),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColorsTheme.textMutedColor(
                            context,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: const [
                            Tab(text: 'Invoices'),
                            Tab(text: 'Payment Receipts'),
                          ],
                        ),
                      ),
                    ),
                    UIHelper.verticalSpace(14.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          color: AppColorsTheme.cardBg(context),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppColorsTheme.borderColor(context),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: primaryOrange,
                              size: 20.sp,
                            ),
                            UIHelper.horizontalSpace(10.w),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  color: AppColorsTheme.textMainColor(context),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search invoices or receipts...',
                                  hintStyle: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColorsTheme.textMutedColor(
                                      context,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: Icon(
                                  Icons.clear_rounded,
                                  size: 18.sp,
                                  color: AppColorsTheme.textMutedColor(context),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    UIHelper.verticalSpace(14.h),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(
                            isLoading: provider.isLoadingInvoices,
                            error: provider.invoiceError,
                            items: filteredInvoices,
                            emptyMessage: query.isEmpty
                                ? 'No invoices found'
                                : 'No matching invoices found',
                            onRetry: () => provider.fetchInvoices(force: true),
                            itemBuilder: (context, index) => InvoiceListCard(invoice: filteredInvoices[index]),
                          ),
                          _buildList(
                            isLoading: provider.isLoadingReceipts,
                            error: provider.receiptError,
                            items: filteredReceipts,
                            emptyMessage: query.isEmpty
                                ? 'No receipts found'
                                : 'No matching receipts found',
                            onRetry: () => provider.fetchReceipts(force: true),
                            itemBuilder: (context, index) => ReceiptListCard(receipt: filteredReceipts[index]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
