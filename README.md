# FinixPaymentSheet Demo App

Demo app for the FinixPaymentSheet iOS SDK — payment tokenization for iOS with Swift and Objective-C support.

The SDK itself is distributed as a binary Swift package from [`finix-paymentsheet-ios-sdk`](https://github.com/finix-payments/finix-paymentsheet-ios-sdk). This repository contains only the demo app that consumes it.

## Installation

### Swift Package Manager

In Xcode, choose **File → Add Package Dependencies**, enter `https://github.com/finix-payments/finix-paymentsheet-ios-sdk`, and add the `FinixPaymentSheet` product to your app target.

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/finix-payments/finix-paymentsheet-ios-sdk.git", from: "1.0.12")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "FinixPaymentSheet", package: "finix-paymentsheet-ios-sdk")
        ]
    )
]
```

See the SDK repository's [tags](https://github.com/finix-payments/finix-paymentsheet-ios-sdk/tags) for available versions.

### Migrating from CocoaPods

CocoaPods is no longer published; v1.0.10 is the last pod release. Podfiles pinned to a `v1.0.x` tag of this repository keep resolving, but Podfiles that track `main` or the raw podspec URL no longer do. Remove the `FinixPaymentSheet` pod, run `pod install`, then add the Swift package as above — the module name is still `FinixPaymentSheet`, so imports don't change.

## SDK Integration

Once the package is added, the SDK is ready to use. **No bridging headers or additional setup required** - just import and start using.

### Swift Integration

**Step 1: Import the SDK**
```swift
import FinixPaymentSheet
```

**Step 2: Initialize in your view controller**
```swift
class YourViewController: UIViewController {
    var paymentAction: PaymentAction!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Create credentials
        let credentials = FinixCredentials(
            applicationId: "YOUR_APP_ID",
            environment: .Sandbox
        )

        // 2. Initialize PaymentAction
        paymentAction = PaymentAction(
            credentials: credentials,
            delegate: self
        )
    }

    func showPaymentSheet() {
        // 3. Create and present payment sheet
        let sheet = paymentAction.paymentSheet(style: .complete)
        paymentAction.present(from: self, paymentSheet: sheet, animated: true)
    }
}
```

**Step 3: Implement the delegate**
```swift
extension YourViewController: PaymentActionDelegate {
    func didSucceed(paymentController: PaymentInputController, instrument: TokenResponse) {
        print("✅ Token: \(instrument.id)")
        // Handle successful tokenization
    }

    func didCancel(paymentController: PaymentInputController) {
        // Handle cancellation
    }

    func didFail(paymentController: PaymentInputController, error: Error) {
        print("❌ Error: \(error.localizedDescription)")
        // Handle error
    }
}
```

### Objective-C Integration

**Step 1: Import the SDK**
```objective-c
// In your .m file
@import FinixPaymentSheet;
```

**Step 2: Initialize in your view controller**
```objective-c
// In your .h file
@interface YourViewController : UIViewController <PaymentActionDelegate>
@property (nonatomic, strong) PaymentAction *paymentAction;
@end

// In your .m file
@implementation YourViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1. Create credentials
    FinixCredentials *credentials = [[FinixCredentials alloc]
        initWithApplicationId:@"YOUR_APP_ID"
        environment:FinixAPIEndpointSandbox
        merchantId:nil];

    // 2. Initialize PaymentAction
    self.paymentAction = [[PaymentAction alloc]
        initWithCredentials:credentials
        delegate:self
        configuration:nil];
}

- (void)showPaymentSheet {
    // 3. Create payment sheet
    PaymentInputController *sheet = [self.paymentAction
        paymentSheetWithStyle:PaymentInputControllerStyleComplete
        showCancelButton:YES
        showCancelItem:YES];

    // 4. Present the sheet
    [self.paymentAction presentFrom:self paymentSheet:sheet animated:YES];
}
```

**Step 3: Implement the delegate**
```objective-c
#pragma mark - PaymentActionDelegate

- (void)didSucceedWithPaymentController:(PaymentInputController *)paymentController
                             instrument:(TokenResponse *)instrument {
    NSLog(@"✅ Token: %@", instrument.id);
    // Handle successful tokenization
}

- (void)didCancelWithPaymentController:(PaymentInputController *)paymentController {
    // Handle cancellation
}

- (void)didFailWithPaymentController:(PaymentInputController *)paymentController
                                error:(NSError *)error {
    NSLog(@"❌ Error: %@", error.localizedDescription);
    // Handle error
}
```

### Advanced Usage

**Custom Branding (Optional)**
```objective-c
UIImage *logo = [UIImage imageNamed:@"YourLogo"];
Branding *branding = [[Branding alloc]
    initWithImage:logo
    title:@"Your Company"];

Configuration *config = [[Configuration alloc]
    initWithTitle:@"Card Entry"
    branding:branding
    buttonTitle:@"Submit"
    enableCardScanning:YES];

PaymentAction *paymentAction = [[PaymentAction alloc]
    initWithCredentials:credentials
    delegate:self
    configuration:config];
```

**Bank Account (ACH) Payments**
```objective-c
PaymentInputController *bankSheet = [self.paymentAction
    bankPaymentSheetWithCancelButton:YES
    cancelItem:YES];

[self.paymentAction presentFrom:self paymentSheet:bankSheet animated:YES];
```

## Available Styles

- `PaymentInputControllerStyleComplete` - Full card entry with all fields
- `PaymentInputControllerStyleBasic` - Basic card entry
- `PaymentInputControllerStylePartial` - Partial card entry
- `PaymentInputControllerStyleMinimal` - Minimal card entry
- `PaymentInputControllerStyleBasicBank` - Bank account (ACH) entry

## Running the Demo

Open `PaymentSheetDemo.xcodeproj` and run the `PaymentSheetDemo` scheme. Xcode resolves the SDK from [`finix-paymentsheet-ios-sdk`](https://github.com/finix-payments/finix-paymentsheet-ios-sdk) up to the next minor version from 1.0.12, at the version pinned in `Package.resolved`; use **File → Packages → Update to Latest Package Versions** to pick up newer 1.0.x releases.

The demo covers UIKit, SwiftUI and Objective-C integrations:

- **[DemoViewController.swift](PaymentSheetDemo/Sources/DemoViewController.swift)** - UIKit (Swift)
- **[SwiftUIDemoView.swift](PaymentSheetDemo/Sources/SwiftUIDemoView.swift)** - SwiftUI
- **[ObjCDemoViewController.m](PaymentSheetDemo/Sources/ObjCDemoViewController.m)** - Objective-C, showing:
  - SDK initialization and configuration
  - Modal and push presentation styles
  - Card and bank account (ACH) payments
  - Custom branding and localization
  - Delegate implementation
  - Error handling

## Requirements

- iOS 15.0+ (the demo app itself targets iOS 15.6)
- Xcode 26.6+

## Support

- Email: developers@finix.com
- Docs: https://www.finix.com/docs/guides/payments/

## License

Apache License 2.0
