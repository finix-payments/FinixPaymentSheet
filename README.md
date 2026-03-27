# FinixPaymentSheet iOS SDK

Payment tokenization SDK for iOS with Swift and Objective-C support.

## Installation

### Option 1: Latest Version (Recommended)

Add to your `Podfile`:

```ruby
pod 'FinixPaymentSheet', :git => 'https://github.com/finix-payments/FinixPaymentSheet.git', :tag => 'v1.0.9'
```

### Option 2: Direct Podspec URL

```ruby
pod 'FinixPaymentSheet', :podspec => 'https://raw.githubusercontent.com/finix-payments/FinixPaymentSheet/main/FinixPaymentSheet.podspec'
```

Then run:
```bash
pod install
```

### Available Versions

See [Releases](https://github.com/finix-payments/FinixPaymentSheet/releases) for all versions.

To use a specific version:
```ruby
pod 'FinixPaymentSheet', :git => 'https://github.com/finix-payments/FinixPaymentSheet.git', :tag => 'v1.0.9'
```

## SDK Integration

After running `pod install`, the SDK is ready to use. **No bridging headers or additional setup required** - just import and start using.

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
    func paymentAction(_ action: PaymentAction, didSucceedWith response: TokenResponse) {
        print("✅ Token: \(response.id)")
        // Handle successful tokenization
    }

    func paymentAction(_ action: PaymentAction, didFailWith error: Error) {
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
        environment:FinixAPIEndpointSandbox];

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

- (void)paymentAction:(PaymentAction *)action
       didSucceedWith:(TokenResponse *)response {
    NSLog(@"✅ Token: %@", response.id);
    // Handle successful tokenization
}

- (void)paymentAction:(PaymentAction *)action
         didFailWith:(NSError *)error {
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
    buttonTitle:@"Submit"];

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

## Demo Implementation

A complete Objective-C demo implementation is available in this repository:

- **[ObjCDemoViewController.m](PaymentSheetDemo/Sources/ObjCDemoViewController.m)** - Full working example showing:
  - SDK initialization and configuration
  - Modal and push presentation styles
  - Card and bank account (ACH) payments
  - Custom branding and localization
  - Delegate implementation
  - Error handling

This demo shows real-world usage patterns and best practices for integrating the SDK in Objective-C projects.

## Requirements

- iOS 12.0+
- Xcode 14.0+

## Support

- Email: developers@finix.com
- Docs: https://www.finix.com/docs/guides/payments/

## License

Apache License 2.0
