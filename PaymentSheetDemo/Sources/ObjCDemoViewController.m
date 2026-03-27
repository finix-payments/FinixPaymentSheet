//
//  ObjCDemoViewController.m
//  PaymentSheetDemo
//
//  Created by Israrul Haque on 3/26/26.
//

#import "ObjCDemoViewController.h"
#import "PaymentSheetDemo-Swift.h"

// Import the generated Swift header
@import FinixPaymentSheet;

// Application ID for demo
static NSString *const kApplicationId = @"APgPDQrLD52TYvqazjHJJchM";

// Cell identifiers
static NSString *const kDemoCellIdentifier = @"ObjCDemoCell";

// Section definitions
typedef NS_ENUM(NSInteger, ObjCDemoSection) {
    ObjCDemoSectionModal = 0,
    ObjCDemoSectionPush,
    ObjCDemoSectionBank,
    ObjCDemoSectionCount
};

// Row definitions for table view
typedef NS_ENUM(NSInteger, ObjCDemoRow) {
    ObjCDemoRowComplete = 0,
    ObjCDemoRowBasic,
    ObjCDemoRowPartial,
    ObjCDemoRowMinimal,
    ObjCDemoRowCount
};

@interface ObjCDemoViewController () <PaymentActionDelegate>

@property (nonatomic, strong) PaymentAction *paymentAction;
@property (nonatomic, strong) Branding *branding;

@end

@implementation ObjCDemoViewController

#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self setupPaymentSDK];
    }
    return self;
}

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleInsetGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Objective-C Demo";
}

#pragma mark - SDK Setup

- (void)setupPaymentSDK {
    // 1. Create credentials
    FinixCredentials *credentials = [[FinixCredentials alloc]
        initWithApplicationId:kApplicationId
        environment:FinixAPIEndpointSandbox];

    // 2. Create branding
    UIImage *logo = [UIImage imageNamed:@"FinixLogo"];
    self.branding = [[Branding alloc] initWithImage:logo title:@"Objective-C Demo"];

    // 3. Create configuration
    Configuration *config = [[Configuration alloc]
        initWithTitle:@"Card Entry (Objective-C)"
        branding:self.branding
        buttonTitle:@"Tokenize"];

    // 4. Initialize PaymentAction with delegate
    self.paymentAction = [[PaymentAction alloc]
        initWithCredentials:credentials
        delegate:self
        configuration:config];

    // 5. Optionally customize localization (using default English values)
    // You can override any string by providing custom values in the initializer
    Localization *localization = [[Localization alloc] initWithCardNumberInvalidCharacters:@"Card numbers can only contain 0-9."
                                                                          invalidCardNumber:@"Please enter valid card number."
                                                                       selectBankAccountType:@"Please select account type."
                                                                            invalidSelection:@"Invalid selection."
                                                                    expiryEnterMonthAndYear:@"Enter month and year."
                                                                    expiryInvalidCharacters:@"Invalid characters."
                                                                          expiryMonthRange:@"Month must be 1-12."
                                                                          expiryYearFormat:@"Enter year (YY)."
                                                                           expiryInThePast:@"Expiry in the past."
                                                                          regionEnterState:@"Enter state."
                                                                              invalidInput:@"Invalid characters."
                                                                    minimumLengthRequired:@"Minimum of %@ required."
                                                                                 nameTitle:@"Name"
                                                                              addressTitle:@"Address"
                                                                         addressLine2Title:@"Line 2"
                                                                                 cityTitle:@"City"
                                                                               regionTitle:@"State"
                                                                           postalCodeTitle:@"Postal Code"
                                                                           cardNumberTitle:@"Card Number"
                                                                           cardExpiryTitle:@"Expiry"
                                                                              cardCVVTitle:@"CVV/CVC"
                                                                    bankAccountNumberTitle:@"Account Number"
                                                                    bankRoutingNumberTitle:@"Routing Number"
                                                                       bankAccountTypeTitle:@"Account Type"
                                                                         countryRegionTitle:@"Country or Region"
                                                                           namePlaceholder:@"First Last"
                                                                        addressPlaceholder:@"123 Main Street"
                                                                   addressLine2Placeholder:@"#1"
                                                                           cityPlaceholder:@"City"
                                                                         regionPlaceholder:@"CA"
                                                                     postalCodePlaceholder:@"00000"
                                                                     cardNumberPlaceholder:@"0000 0000 0000 0000"
                                                                     cardExpiryPlaceholder:@"MM/YY"
                                                                        cardCVVPlaceholder:@"111"
                                                              bankAccountNumberPlaceholder:@"00000"
                                                              bankRoutingNumberPlaceholder:@"000000000"
                                                                 bankAccountTypePlaceholder:@"Checking/Savings"
                                                              bankAccountPersonalChecking:@"Personal Checking"
                                                               bankAccountPersonalSavings:@"Personal Savings"
                                                             bankAccountBusinessChecking:@"Business Checking"
                                                              bankAccountBusinessSavings:@"Business Savings"];
    self.paymentAction.localization = localization;

    NSLog(@"✅ PaymentAction configured in Objective-C");
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ObjCDemoSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case ObjCDemoSectionModal:
        case ObjCDemoSectionPush:
            return ObjCDemoRowCount;
        case ObjCDemoSectionBank:
            return 1;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case ObjCDemoSectionModal:
            return @"Modal Presentation (Objective-C)";
        case ObjCDemoSectionPush:
            return @"Push Presentation (Objective-C)";
        case ObjCDemoSectionBank:
            return @"Bank Modal Presentation (Objective-C)";
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"This demo is written entirely in Objective-C, demonstrating full compatibility with the FinixPaymentSheet SDK.";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Traditional Objective-C pattern: dequeue and manually create if needed
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDemoCellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kDemoCellIdentifier];
    }

    // Configure cell
    NSString *title = [self titleForRowAtIndexPath:indexPath];
    cell.textLabel.text = title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case ObjCDemoSectionModal:
            [self presentModalSheetWithStyle:[self styleForRow:indexPath.row]];
            break;

        case ObjCDemoSectionPush:
            [self pushSheetWithStyle:[self styleForRow:indexPath.row]];
            break;

        case ObjCDemoSectionBank:
            [self presentBankSheet];
            break;
    }
}

#pragma mark - Helper Methods

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case ObjCDemoSectionModal:
        case ObjCDemoSectionPush:
            return [self titleForStyle:[self styleForRow:indexPath.row]];

        case ObjCDemoSectionBank:
            return @"Bank Account";

        default:
            return @"";
    }
}

- (NSString *)titleForStyle:(PaymentInputControllerStyle)style {
    switch (style) {
        case PaymentInputControllerStyleComplete:
            return @"Complete";
        case PaymentInputControllerStyleBasic:
            return @"Basic";
        case PaymentInputControllerStylePartial:
            return @"Partial";
        case PaymentInputControllerStyleMinimal:
            return @"Minimal";
        case PaymentInputControllerStyleBasicBank:
            return @"Basic Bank";
        default:
            return @"Unknown";
    }
}

- (PaymentInputControllerStyle)styleForRow:(NSInteger)row {
    switch (row) {
        case ObjCDemoRowComplete:
            return PaymentInputControllerStyleComplete;
        case ObjCDemoRowBasic:
            return PaymentInputControllerStyleBasic;
        case ObjCDemoRowPartial:
            return PaymentInputControllerStylePartial;
        case ObjCDemoRowMinimal:
            return PaymentInputControllerStyleMinimal;
        default:
            return PaymentInputControllerStyleComplete;
    }
}

#pragma mark - Payment Sheet Presentation

- (void)presentModalSheetWithStyle:(PaymentInputControllerStyle)style {
    NSLog(@"📱 Presenting modal payment sheet with style: %ld", (long)style);

    // Create payment sheet using Objective-C compatible method
    PaymentInputController *paymentSheet = [self.paymentAction
        paymentSheetWithStyle:style
        showCancelButton:YES
        showCancelItem:YES];

    // Present modally (delegate is set internally)
    [self.paymentAction presentFrom:self
                       paymentSheet:paymentSheet
                           animated:YES];
}

- (void)pushSheetWithStyle:(PaymentInputControllerStyle)style {
    NSLog(@"📱 Pushing payment sheet with style: %ld", (long)style);

    // Create payment sheet using Objective-C compatible method
    PaymentInputController *paymentSheet = [self.paymentAction
        paymentSheetWithStyle:style
        showCancelButton:NO
        showCancelItem:NO];

    // Set delegate for push presentation
    paymentSheet.delegate = self;

    // Push onto navigation stack
    [self.navigationController pushViewController:paymentSheet animated:YES];
}

- (void)presentBankSheet {
    NSLog(@"🏦 Presenting bank payment sheet");

    // Create bank payment sheet using Objective-C compatible method
    PaymentInputController *paymentSheet = [self.paymentAction
        bankPaymentSheetWithCancelButton:YES
        cancelItem:YES];

    // Present modally (delegate is set internally)
    [self.paymentAction presentFrom:self
                       paymentSheet:paymentSheet
                           animated:YES];
}

#pragma mark - PaymentActionDelegate

- (void)didSucceedWithPaymentController:(PaymentInputController *)paymentController
                             instrument:(TokenResponse *)instrument {
    NSLog(@"✅ Payment succeeded!");
    NSLog(@"   Token ID: %@", instrument.id);
    NSLog(@"   Fingerprint: %@", instrument.fingerprint);
    NSLog(@"   Instrument Type: %ld", (long)instrument.instrument);
    NSLog(@"   Currency: %ld", (long)instrument.isoCurrency);
    NSLog(@"   Created: %@", instrument.created);
    NSLog(@"   Expires: %@", instrument.expires);

    // Create result view controller
    ResultViewController *resultController = [[ResultViewController alloc] init];
    [resultController setResultWithSuccess:instrument];

    // Push result controller
    [paymentController.navigationController pushViewController:resultController animated:YES];
}

- (void)didCancelWithPaymentController:(PaymentInputController *)paymentController {
    NSLog(@"❌ Payment cancelled by user");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didFailWithPaymentController:(PaymentInputController *)paymentController
                                error:(NSError *)error {
    NSLog(@"⚠️ Payment failed with error: %@", error.localizedDescription);

    // Create result view controller
    ResultViewController *resultController = [[ResultViewController alloc] init];
    [resultController setResultWithError:error];

    // Push result controller
    [paymentController.navigationController pushViewController:resultController animated:YES];
}

@end
