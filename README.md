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

---

## 3D Secure (3DS) Integration

3DS adds an extra layer of authentication for card payments, reducing fraud and enabling liability shift.

### Prerequisites

To enable 3DS, you need:

| Credential | Description | Example |
|------------|-------------|---------|
| `applicationId` | Your Finix Application ID | `APxxxxxxxxxxxxxxxxx` |
| `merchantId` | Your Finix Merchant ID | `MUxxxxxxxxxxxxxxxxx` |
| `apiUsername` | API username for authentication | `USxxxxxxxxxxxxxxxxx` |
| `apiPassword` | API password for authentication | Your password |

### Step 1: Configure Info.plist

Add a custom URL scheme for 3DS redirect handling:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.yourapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yourappscheme</string>
        </array>
    </dict>
</array>
```

### Step 2: Handle URL Redirects

**SceneDelegate (iOS 13+)**
```swift
import FinixPaymentSheet

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // Handle URL if app was launched via URL scheme
        if let urlContext = connectionOptions.urlContexts.first {
            PaymentAction.handleThreeDSRedirect(url: urlContext.url)
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        PaymentAction.handleThreeDSRedirect(url: url)
    }
}
```

**AppDelegate (iOS 12 or non-scene apps)**
```swift
import FinixPaymentSheet

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if PaymentAction.handleThreeDSRedirect(url: url) {
            return true
        }
        return false
    }
}
```

### Step 3: Configure PaymentAction with 3DS

```swift
import FinixPaymentSheet

class PaymentViewController: UIViewController {
    var paymentAction: PaymentAction!

    /// URL scheme must match Info.plist
    let redirectScheme = "yourappscheme"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPaymentSDK()
    }

    func setupPaymentSDK() {
        // 1. Create credentials with merchant ID
        let credentials = FinixCredentials(
            applicationId: "APxxxxxxxxxxxxxxxxx",
            environment: .Sandbox,
            merchantId: "MUxxxxxxxxxxxxxxxxx"
        )

        // 2. Create 3DS configuration
        let threeDSConfig = ThreeDSConfiguration(redirectScheme: redirectScheme)

        // 3. Create payment configuration with 3DS
        let configuration = PaymentInputController.Configuration(
            title: "Secure Payment",
            branding: PaymentInputController.Branding(image: yourLogo, title: "Your Store"),
            buttonTitle: "Pay $99.00",
            enableCardScanning: true,
            threeDSConfiguration: threeDSConfig,
            merchantId: "MUxxxxxxxxxxxxxxxxx",
            apiUsername: "USxxxxxxxxxxxxxxxxx",
            apiPassword: "your-api-password",
            amount: 9900,       // Amount in cents ($99.00)
            currency: "USD"
        )

        // 4. Initialize PaymentAction
        paymentAction = PaymentAction(credentials: credentials, configuration: configuration)
        paymentAction.delegate = self
    }

    func showPaymentSheet() {
        let sheet = paymentAction.paymentSheet(
            style: .complete,
            theme: FinixCheckoutTheme1.default,
            showCancelButton: true,
            showCancelItem: true,
            showCountry: false
        )
        paymentAction.present(from: self, paymentSheet: sheet, animated: true)
    }
}
```

### Step 4: Handle 3DS Response

```swift
extension PaymentViewController: PaymentActionDelegate {
    func didSucceed(paymentController: PaymentInputController, response: PaymentSheetResponse) {
        // Get token ID
        let tokenId = response.tokenizedResponse.id
        print("Token: \(tokenId)")

        // Check for 3DS response
        if let threeDSResponse = response.threeDSResponse {
            let sessionId = threeDSResponse.sessionId
            print("3DS Session: \(sessionId)")
            print("Liability Shift: \(threeDSResponse.liabilityShift)")

            // Use both token and 3DS session for authorization
            createAuthorization(tokenId: tokenId, threeDSSessionId: sessionId)
        } else {
            // 3DS was not performed (not enabled or not required)
            createAuthorization(tokenId: tokenId, threeDSSessionId: nil)
        }
    }

    func didCancel(paymentController: PaymentInputController) {
        dismiss(animated: true)
    }

    func didFail(paymentController: PaymentInputController, error: Error) {
        if let finixError = error as? FinixError {
            print("Finix Error: \(finixError.message), Code: \(finixError.code)")
        }
        // Show error to user
    }
}
```

### 3DS Response Properties

The `ThreeDSResponse` object contains:

| Property | Type | Description |
|----------|------|-------------|
| `sessionId` | `String` | 3DS session ID for authorization |
| `state` | `ThreeDSStatus` | Status: `.pending`, `.succeeded`, `.failed` |
| `authenticationType` | `ThreeDSAuthenticationType?` | How authentication completed |
| `liabilityShift` | `Bool` | Whether liability shifted to issuer |
| `cardholderAuthentication` | `String?` | CAVV cryptogram |
| `electronicCommerceIndicator` | `String?` | ECI value |
| `version` | `String?` | 3DS version (e.g., "2.2.0") |

### 3DS with Objective-C

```objective-c
@import FinixPaymentSheet;

@implementation YourViewController

- (void)setupPaymentSDKWith3DS {
    // 1. Create credentials
    FinixCredentials *credentials = [[FinixCredentials alloc]
        initWithApplicationId:@"APxxxxxxxxxxxxxxxxx"
        environment:FinixAPIEndpointSandbox
        merchantId:@"MUxxxxxxxxxxxxxxxxx"];

    // 2. Create 3DS configuration
    ThreeDSConfiguration *threeDSConfig = [[ThreeDSConfiguration alloc]
        initWithRedirectScheme:@"yourappscheme"
        isEnabled:YES];

    // 3. Create branding
    Branding *branding = [[Branding alloc]
        initWithImage:[UIImage imageNamed:@"Logo"]
        title:@"Your Store"];

    // 4. Create configuration with 3DS
    Configuration *config = [[Configuration alloc]
        initWithTitle:@"Secure Payment"
        branding:branding
        buttonTitle:@"Pay $99.00"
        enableCardScanning:YES
        threeDSConfiguration:threeDSConfig
        merchantId:@"MUxxxxxxxxxxxxxxxxx"
        apiUsername:@"USxxxxxxxxxxxxxxxxx"
        apiPassword:@"your-api-password"
        amount:9900
        currency:@"USD"];

    // 5. Initialize PaymentAction
    self.paymentAction = [[PaymentAction alloc]
        initWithCredentials:credentials
        delegate:self
        configuration:config];
}

#pragma mark - PaymentActionDelegate

- (void)didSucceedWithPaymentController:(PaymentInputController *)paymentController
                               response:(PaymentSheetResponse *)response {
    NSLog(@"Token: %@", response.tokenizedResponse.id);

    if (response.threeDSResponse) {
        NSLog(@"3DS Session: %@", response.threeDSResponse.sessionId);
    }
}

@end
```

### 3DS Configuration Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `redirectScheme` | `String` | Required | URL scheme matching Info.plist |
| `isEnabled` | `Bool` | `true` | Runtime toggle for 3DS |

### PaymentInputController.Configuration (3DS Parameters)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `threeDSConfiguration` | `ThreeDSConfiguration?` | For 3DS | 3DS settings (nil disables 3DS) |
| `merchantId` | `String?` | For 3DS | Finix Merchant ID |
| `apiUsername` | `String?` | For 3DS | API username for 3DS auth |
| `apiPassword` | `String?` | For 3DS | API password for 3DS auth |
| `amount` | `Int` | For 3DS | Amount in cents |
| `currency` | `String` | For 3DS | ISO 4217 currency code |

---

## Running the Demo

Open `PaymentSheetDemo.xcodeproj` and run the `PaymentSheetDemo` scheme. Xcode resolves the SDK from [`finix-paymentsheet-ios-sdk`](https://github.com/finix-payments/finix-paymentsheet-ios-sdk) up to the next minor version from 1.0.12, at the version pinned in `Package.resolved`; use **File → Packages → Update to Latest Package Versions** to pick up newer 1.0.x releases.

### Configure Credentials

1. Run the app
2. Tap the gear icon in the navigation bar
3. Enter your Finix credentials:
   - **Application ID** - Required for tokenization
   - **Merchant ID** - Required for 3DS
   - **API Username** - Required for 3DS
   - **API Password** - Required for 3DS
4. Tap Save

### Demo Features

The demo covers UIKit, SwiftUI and Objective-C integrations:

- **[DemoViewController.swift](PaymentSheetDemo/Sources/DemoViewController.swift)** - UIKit (Swift) with 3DS toggle
- **[SwiftUIDemoView.swift](PaymentSheetDemo/Sources/SwiftUIDemoView.swift)** - SwiftUI with 3DS support
- **[ObjCDemoViewController.m](PaymentSheetDemo/Sources/ObjCDemoViewController.m)** - Objective-C integration
- **[ConfigurationViewController.swift](PaymentSheetDemo/Sources/ConfigurationViewController.swift)** - Credential management UI

Features demonstrated:
  - SDK initialization and configuration
  - Modal and push presentation styles
  - Card and bank account (ACH) payments
  - 3D Secure (3DS) authentication
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
