import '../feature/account/data/account_rx.dart';
import '../feature/account/data/security_rx.dart';
import '../feature/auth/data/forgot_password_rx.dart';
import '../feature/auth/data/login_rx.dart';
import '../feature/auth/data/logout_rx.dart';
import '../feature/auth/data/register_rx.dart';
import '../feature/business/data/business_rx.dart';
import '../feature/business/data/kyc_rx.dart';
import '../feature/business/data/verification_history_rx.dart';
import '../feature/dashboard/data/address_rx.dart';
import '../feature/dashboard/data/checkout_rx.dart';
import '../feature/dashboard/data/current_user_rx.dart';
import '../feature/dashboard/data/dashboard_rx.dart';
import '../feature/dashboard/data/location_child_rx.dart';
import '../feature/dashboard/data/location_division_rx.dart';
import '../feature/dashboard/data/order_rx.dart';
import '../feature/dashboard/data/payment_rx.dart';
import '../feature/dashboard/data/product_rx.dart';
import '../feature/dashboard/data/website_rx.dart';
import '../feature/dashboard/data/wholesale_cart_rx.dart';
import '../feature/finance/data/bank_rx.dart';
import '../feature/finance/data/withdrawal_list_rx.dart';
import '../feature/finance/data/withdrawal_options_rx.dart';
import '../feature/finance/data/wallet_transaction_rx.dart';
import '../feature/finance/data/wallet_balance_rx.dart';
import '../feature/finance/data/wallet_top_up_rx.dart';
import '../feature/finance/data/request_withdrawal_rx.dart';
import '../feature/notification/data/notification_rx.dart';
import '../feature/package/data/package_rx.dart';

LoginRx loginRxObj = LoginRx();

RegisterRx registerRxObj = RegisterRx();

LogoutRx logoutRxObj = LogoutRx();

ForgotPasswordRx forgotPasswordRxObj = ForgotPasswordRx();

AccountRx accountRxObj = AccountRx();

SecurityRx securityRxObj = SecurityRx();

DashboardRx dashboardRxObj = DashboardRx();

BusinessRx businessRxObj = BusinessRx();

PackageRx packageRxObj = PackageRx();

NotificationRx notificationRxObj = NotificationRx();

KycRx kycRxObj = KycRx();
VerificationHistoryRx verificationHistoryRxObj = VerificationHistoryRx();

MyProductRx myProductRxObj = MyProductRx();
OrderRx orderRxObj = OrderRx();
PaymentRx paymentRxObj = PaymentRx();
AddressRx addressRxObj = AddressRx();
CurrentUserRx currentUserRxObj = CurrentUserRx();
LocationChildRx locationChildRxObj = LocationChildRx();
LocationDivisionRx locationDivisionRxObj = LocationDivisionRx();
WebsiteRx websiteRxObj = WebsiteRx();
WholesaleCartRx wholesaleCartRxObj = WholesaleCartRx();
CheckoutRx checkoutRxObj = CheckoutRx();
BankRx bankRxObj = BankRx.instance;
WithdrawalOptionsRx withdrawalOptionsRxObj = WithdrawalOptionsRx.instance;
WithdrawalListRx withdrawalListRxObj = WithdrawalListRx.instance;
WalletTransactionRx walletTransactionRxObj = WalletTransactionRx.instance;
WalletBalanceRx walletBalanceRxObj = WalletBalanceRx.instance;
WalletTopUpRx walletTopUpRxObj = WalletTopUpRx.instance;
RequestWithdrawalRx requestWithdrawalRxObj = RequestWithdrawalRx.instance;
