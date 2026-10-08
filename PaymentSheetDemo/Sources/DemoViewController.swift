//
//  ViewController.swift
//  PaymentSheet
//
//  Created by Jack Tihon on 6/24/22.
//

import FinixPaymentSheet
import UIKit

// Provide your own Application Id
// This is a sample sandbox Application ID for testing
// For production, configure your credentials via the gear icon (settings)
let APPLICATION_ID = "APgPDQrLD52TYvqazjHJJchM"

// Branding assets for demo
let BRANDING_LOGO: UIImage? = #imageLiteral(resourceName: "FinixLogo")
let BRANDING_NAME = "Daphne's Corner"

// Theme options
enum ThemeOption: Int, CaseIterable {
    case defaultTheme
    case finixCheckoutTheme

    var title: String {
        switch self {
        case .defaultTheme: return "Default"
        case .finixCheckoutTheme: return "FinixCheckout"
        }
    }

    var theme: any ColorThemeProtocol {
        switch self {
        case .defaultTheme:
            return ColorTheme.default
        case .finixCheckoutTheme:
            return FinixCheckoutTheme1.default
        }
    }
}

/**
 This controller demonstrates usage of the PaymentSheet.
  It is expected to be pushed onto a navigation controller for the nav controller presentation styles
  */
class DemoViewController: UITableViewController {
    var paymentSDK: PaymentAction!

    // Configuration storage
    private let config = DemoConfiguration.shared

    // Provide your own branding
    // NOTE: provide both light and dark appearances!
    private let branding: PaymentInputController.Branding = .init(image: BRANDING_LOGO, title: BRANDING_NAME)

    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Card Payment Sheet Demo"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(openConfiguration)
        )

        tableView.register(DemoCell.self, forCellReuseIdentifier: DemoCell.Identifier)
        tableView.register(DemoSwitchCell.self, forCellReuseIdentifier: DemoSwitchCell.Identifier)

        setupPaymentSDK()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Configuration

    @objc private func openConfiguration() {
        let configVC = ConfigurationViewController { [weak self] in
            self?.setupPaymentSDK()
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(configVC, animated: true)
    }

    // set up PaymentSDK
    private func setupPaymentSDK() {
        // Use credentials from configuration
        let credentials = config.finixCredentials
        paymentSDK = .init(credentials: credentials)

        // Convert empty strings to nil for optional credentials
        let merchantId = config.merchantId.isEmpty ? nil : config.merchantId
        let apiUsername = config.apiUsername.isEmpty ? nil : config.apiUsername
        let apiPassword = config.apiPassword.isEmpty ? nil : config.apiPassword

        // Set up configuration with card scanning and 3DS
        paymentSDK.configuration = PaymentInputController.Configuration(
            title: "Card Entry",
            branding: branding,
            buttonTitle: "Tokenize",
            enableCardScanning: enableCardScanning,
            threeDSConfiguration: threeDSConfiguration,
            merchantId: merchantId,
            apiUsername: apiUsername,
            apiPassword: apiPassword,
            amount: 9900, // $99.00 for testing
            currency: "USD"
        )

        /** NOTE: to provide your own customized text (e.g. localization), you may override the default localization.
          E.g
          .
         ```
         var localization = PaymentInputController.Localization()
         localization.nameTitle = "名称"
         localization.addressTitle = "地址"
         paymentSDK.localization = localization
         ```
         **/

        // Designate a delegate
        paymentSDK.delegate = self
    }

    override func numberOfSections(in _: UITableView) -> Int {
        DemoCellSection.allCases.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch DemoCellSection.allCases[section] {
        case .modal, .push:
            return RowStyle.allCases.count
        case .bank:
            return BankStyle.allCases.count
        case .configuration:
            return DemoSwitch.allCases.count + 1 // +1 for theme selector
        case .swiftui, .objc:
            return 1
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        DemoCellSection.allCases[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch DemoCellSection.allCases[indexPath.section] {
        case .configuration:
            // Check if this is the theme selector row (last row)
            if indexPath.row == DemoSwitch.allCases.count {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "ThemeCell")
                cell.selectionStyle = .none
                cell.textLabel?.text = "Theme"

                let segmentedControl = UISegmentedControl(items: ThemeOption.allCases.map(\.title))
                segmentedControl.selectedSegmentIndex = selectedTheme.rawValue
                segmentedControl.addTarget(self, action: #selector(themeSegmentedControlChanged(_:)), for: .valueChanged)
                segmentedControl.translatesAutoresizingMaskIntoConstraints = false

                cell.contentView.addSubview(segmentedControl)
                NSLayoutConstraint.activate([
                    segmentedControl.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    segmentedControl.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    segmentedControl.widthAnchor.constraint(equalToConstant: 220),
                ])

                return cell
            } else {
                // Switch cells
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DemoSwitchCell.Identifier) as? DemoSwitchCell else {
                    fatalError("Expected DemoSwitchCell")
                }
                cell.selectionStyle = .none
                let demoSwitch = DemoSwitch.allCases[indexPath.row]
                switch demoSwitch {
                case .showCountry:
                    cell.switchControl.isOn = showCountry
                    cell.switchControl.addTarget(self, action: #selector(showCountryValueChanged(_:)), for: .valueChanged)
                case .showCancelButton:
                    cell.switchControl.isOn = showCancelButton
                    cell.switchControl.addTarget(self, action: #selector(showCancelButtonValueChanged(_:)), for: .valueChanged)
                case .enableCardScanning:
                    cell.switchControl.isOn = enableCardScanning
                    cell.switchControl.addTarget(self, action: #selector(enableCardScanningValueChanged(_:)), for: .valueChanged)
                case .enable3DS:
                    cell.switchControl.isOn = enable3DS
                    cell.switchControl.addTarget(self, action: #selector(enable3DSValueChanged(_:)), for: .valueChanged)
                }
                cell.textLabel?.text = demoSwitch.title
                return cell
            }
        case .modal, .push:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DemoCell.Identifier) as? DemoCell else {
                fatalError("Expected DemoCell")
            }
            cell.textLabel?.text = RowStyle.allCases[indexPath.row].title
            return cell
        case .bank:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DemoCell.Identifier) as? DemoCell else {
                fatalError("Expected DemoCell")
            }
            cell.textLabel?.text = "Bank"
            return cell
        case .swiftui:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DemoCell.Identifier) as? DemoCell else {
                fatalError("Expected DemoCell")
            }
            cell.textLabel?.text = "Open SwiftUI Demo"
            cell.accessoryType = .disclosureIndicator
            return cell
        case .objc:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DemoCell.Identifier) as? DemoCell else {
                fatalError("Expected DemoCell")
            }
            cell.textLabel?.text = "Open Objective-C Demo"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // trigger action
        let style: PaymentInputController.Style
        let row = indexPath.row
        switch RowStyle.allCases[row] {
        case .complete:
            style = .complete
        case .basic:
            style = .basic
        case .partial:
            style = .partial
        case .minimal:
            style = .minimal
        }

        switch DemoCellSection.allCases[indexPath.section] {
        case .modal:
            modalPresentSheet(style: style)
        case .push:
            navigationPushSheet(style: style)
        case .configuration:
            return
        case .bank:
            modalPresentBankSheet()
        case .swiftui:
            if #available(iOS 15.0, *) {
                openSwiftUIDemo()
            }
        case .objc:
            openObjCDemo()
        }
    }

    // configuration
    private var showCountry: Bool = false
    private var showCancelButton: Bool = false
    private var enableCardScanning: Bool = true
    private var enable3DS: Bool = false // 3DS disabled by default
    private var selectedTheme: ThemeOption = .finixCheckoutTheme

    private var customTheme: any ColorThemeProtocol {
        selectedTheme.theme
    }

    /// URL scheme for 3DS redirect (must match Info.plist)
    private let threeDSRedirectScheme = "finixpaymentsheetdemo"

    /// Create 3DS configuration with current enabled state
    private var threeDSConfiguration: ThreeDSConfiguration? {
        config.threeDSConfiguration(redirectScheme: threeDSRedirectScheme, isEnabled: enable3DS)
    }
}

enum DemoCellSection: Int, CaseIterable {
    case modal
    case push
    case configuration
    case bank
    case swiftui
    case objc

    var title: String {
        switch self {
        case .modal:
            return "Modal Presentation"
        case .push:
            return "Push Presentation"
        case .configuration:
            return "Configuration"
        case .swiftui:
            return "SwiftUI Demo"
        case .bank:
            return "Bank Modal Presentation"
        case .objc:
            return "Objective-C Integration"
        }
    }
}

enum RowStyle: Int, CaseIterable {
    case complete
    case basic
    case partial
    case minimal

    var title: String {
        switch self {
        case .complete:
            return "complete"
        case .basic:
            return "basic"
        case .partial:
            return "partial"
        case .minimal:
            return "minimal"
        }
    }
}

enum BankStyle: Int, CaseIterable {
    case basic

    var title: String {
        switch self {
        case .basic:
            return "Bank"
        }
    }
}

enum DemoSwitch: Int, CaseIterable {
    case showCountry
    case showCancelButton
    case enableCardScanning
    case enable3DS

    var title: String {
        switch self {
        case .showCancelButton:
            return "Show Cancel Button"
        case .showCountry:
            return "Show Country"
        case .enableCardScanning:
            return "Enable Card Scanning"
        case .enable3DS:
            return "Enable 3DS"
        }
    }
}

enum DemoSelector: Int, CaseIterable {
    case themeSelector

    var title: String {
        switch self {
        case .themeSelector:
            return "Theme"
        }
    }
}

// MARK: PaymentSheet presentation

extension DemoViewController {
    // present a payment sheet modally
    private func modalPresentSheet(style: PaymentInputController.Style) {
        // Check if Application ID is configured
        guard config.hasBasicCredentials else {
            showMissingApplicationIdAlert()
            return
        }

        // prepare a payment sheet with configurable cancel button, navigation cancel item, and country selection
        let paymentController = paymentSDK.paymentSheet(style: style,
                                                        theme: customTheme,
                                                        showCancelButton: showCancelButton,
                                                        showCancelItem: true,
                                                        showCountry: showCountry)
        paymentController.delegate = self
        // present the configured payment controller
        paymentSDK.present(from: self, paymentSheet: paymentController, animated: true)
    }

    // push a payment sheet onto the parent navigation controller
    private func navigationPushSheet(style: PaymentInputController.Style) {
        // Check if Application ID is configured
        guard config.hasBasicCredentials else {
            showMissingApplicationIdAlert()
            return
        }

        let paymentSheet = paymentSDK.paymentSheet(style: style,
                                                   theme: customTheme,
                                                   showCancelButton: showCancelButton,
                                                   showCancelItem: false,
                                                   showCountry: showCountry)
        paymentSheet.delegate = self
        navigationController?.pushViewController(paymentSheet, animated: true)
    }

    private func showMissingApplicationIdAlert() {
        let alert = UIAlertController(
            title: "Application ID Required",
            message: "Please configure your Application ID to use payment tokenization.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Configure", style: .default) { [weak self] _ in
            self?.openConfiguration()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: Bank PaymentSheet presentation

extension DemoViewController {
    private func modalPresentBankSheet() {
        // Check if Application ID is configured
        guard config.hasBasicCredentials else {
            showMissingApplicationIdAlert()
            return
        }

        // prepare a payment sheet with configurable cancel button, navigation cancel item, and country selection
        // optionally specify the default bank account type
        let paymentController = paymentSDK.bankPaymentSheet(showCancelButton: showCancelButton,
                                                            showCancelItem: true)
        paymentController.delegate = self
        // present the configured payment controller
        paymentSDK.present(from: self, paymentSheet: paymentController, animated: true)
    }
}

// MARK: PaymentActionDelegate

extension DemoViewController: PaymentActionDelegate {
    func didSucceed(paymentController: PaymentInputController, response: PaymentSheetResponse) {
        debugPrint("got PaymentSheetResponse: \(paymentController),\(response)")

        let resultController = ResultViewController()
        resultController.result = .success(response.tokenizedResponse)

        // Check for 3DS response
        if let threeDSResponse = response.threeDSResponse {
            resultController.threeDSSessionId = threeDSResponse.sessionId
            debugPrint("Token: \(response.tokenizedResponse.id), 3DS Session: \(threeDSResponse.sessionId)")
        } else {
            debugPrint("Token: \(response.tokenizedResponse.id)")
        }

        // Check if presented modally - dismiss first then show result
        if paymentController.presentingViewController != nil {
            dismiss(animated: true) { [weak self] in
                self?.navigationController?.pushViewController(resultController, animated: true)
            }
        } else {
            // Push presentation - just push the result
            paymentController.navigationController?.pushViewController(resultController, animated: true)
        }
    }

    func didCancel(paymentController _: PaymentInputController) {
        debugPrint("cancel tapped")
        dismiss(animated: true)
    }

    func didFail(paymentController: PaymentInputController, error: Error) {
        debugPrint("failed to process with error: \(error)")

        let resultController = ResultViewController()
        if let finixError = error as? FinixError {
            debugPrint("FinixError: \(finixError.message), code: \(finixError.code)")
        }
        resultController.result = .error(error)

        // Check if presented modally - dismiss first then show result
        if paymentController.presentingViewController != nil {
            dismiss(animated: true) { [weak self] in
                self?.navigationController?.pushViewController(resultController, animated: true)
            }
        } else {
            // Push presentation - just push the result
            paymentController.navigationController?.pushViewController(resultController, animated: true)
        }
    }
}

extension DemoViewController {
    @IBAction
    func showCountryValueChanged(_ switchView: UISwitch) {
        showCountry = switchView.isOn
    }

    @IBAction
    func showCancelButtonValueChanged(_ switchView: UISwitch) {
        showCancelButton = switchView.isOn
    }

    @IBAction
    func enableCardScanningValueChanged(_ switchView: UISwitch) {
        enableCardScanning = switchView.isOn
        updatePaymentSDKConfiguration()
    }

    @IBAction
    func enable3DSValueChanged(_ switchView: UISwitch) {
        // Check if 3DS credentials are configured when enabling
        if switchView.isOn && !config.has3DSCredentials {
            // Show alert and revert switch
            switchView.setOn(false, animated: true)
            show3DSConfigurationAlert()
            return
        }

        enable3DS = switchView.isOn
        updatePaymentSDKConfiguration()
    }

    private func show3DSConfigurationAlert() {
        let alert = UIAlertController(
            title: "3DS Configuration Required",
            message: "Please configure your Merchant ID, API Username, and API Password to enable 3DS.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Configure", style: .default) { [weak self] _ in
            self?.openConfiguration()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func updatePaymentSDKConfiguration() {
        // Convert empty strings to nil for optional credentials
        let merchantId = config.merchantId.isEmpty ? nil : config.merchantId
        let apiUsername = config.apiUsername.isEmpty ? nil : config.apiUsername
        let apiPassword = config.apiPassword.isEmpty ? nil : config.apiPassword

        // Update the PaymentSDK configuration
        paymentSDK.configuration = PaymentInputController.Configuration(
            title: "Card Entry",
            branding: branding,
            buttonTitle: "Tokenize",
            enableCardScanning: enableCardScanning,
            threeDSConfiguration: threeDSConfiguration,
            merchantId: merchantId,
            apiUsername: apiUsername,
            apiPassword: apiPassword,
            amount: 9900, // $99.00 for testing
            currency: "USD"
        )
    }

    @objc
    func themeSegmentedControlChanged(_ segmentedControl: UISegmentedControl) {
        selectedTheme = ThemeOption(rawValue: segmentedControl.selectedSegmentIndex) ?? .finixCheckoutTheme
    }

    @available(iOS 15.0, *)
    private func openSwiftUIDemo() {
        let swiftuiDemo = SwiftUIDemoViewController()
        navigationController?.pushViewController(swiftuiDemo, animated: true)
    }

    private func openObjCDemo() {
        let objcDemo = ObjCDemoViewController()
        navigationController?.pushViewController(objcDemo, animated: true)
    }
}

// MARK: TableCellIdentifier

protocol TableCellIdentifiable: AnyObject {
    static var Identifier: String { get }
}

extension UITableViewCell: TableCellIdentifiable {
    static var Identifier: String { String(describing: Self.self) }
}

// MARK: DemoCell

class DemoCell: UITableViewCell {
    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: DemoSwitchCell

class DemoSwitchCell: UITableViewCell {
    let switchControl: UISwitch = .init()

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        accessoryView = switchControl
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        switchControl.removeTarget(nil, action: nil, for: .valueChanged)
    }
}

