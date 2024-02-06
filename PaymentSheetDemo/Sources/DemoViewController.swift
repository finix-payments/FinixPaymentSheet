//
//  ViewController.swift
//  PaymentSheet
//
//  Created by Jack Tihon on 6/24/22.
//

import FinixPaymentSheet
import UIKit

// Provide your own Application Id
let APPLICATION_ID = "APgPDQrLD52TYvqazjHJJchM"

let BRANDING_LOGO: UIImage? = #imageLiteral(resourceName: "FinixLogo")
let BRANDING_NAME = "Daphne's Corner"

// NOTE: customize payment sheet colors.
// `default` theme can be copied and individual colors overriden
let customTheme: ColorTheme = {
    var myTheme: ColorTheme = .default

    myTheme.surface = .brown

    myTheme.label = .red
    myTheme.text = .green
    myTheme.container = .yellow
    myTheme.cancelButton = .magenta
    myTheme.cancelButtonText = .orange

    myTheme.tokenizeButton = .lightGray
    myTheme.tokenizeButtonText = .purple

    myTheme.errorLabel = .blue
    myTheme.logoText = .green
    return myTheme
}()

/**
 This controller demonstrates usage of the PaymentSheet.
  It is expected to be pushed onto a navigation controller for the nav controller presentation styles
  */
class DemoViewController: UITableViewController {
    var paymentSDK: PaymentAction!

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
        setupPaymentSDK()

        navigationItem.title = "Card Payment Sheet Demo"

        super.viewDidLoad()
        tableView.register(DemoCell.self, forCellReuseIdentifier: DemoCell.Identifier)
        tableView.register(DemoSwitchCell.self, forCellReuseIdentifier: DemoSwitchCell.Identifier)
    }

    // set up PaymentSDK
    private func setupPaymentSDK() {
        let credentials = FinixCredentials(applicationId: APPLICATION_ID, environment: .Sandbox)
        paymentSDK = .init(credentials: credentials)

        // Set up configuration
        paymentSDK.configuration = .init(title: "Card Entry", branding: branding, buttonTitle: "Tokenize")

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
            return DemoSwitch.allCases.count
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        DemoCellSection.allCases[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch DemoCellSection.allCases[indexPath.section] {
        case .configuration:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DemoSwitchCell.Identifier) as? DemoSwitchCell else {
                fatalError("Expected DemoCell")
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
            }
            cell.textLabel?.text = demoSwitch.title
            return cell
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
        }
    }

    // configuration
    private var showCountry: Bool = false
    private var showCancelButton: Bool = false
}

enum DemoCellSection: Int, CaseIterable {
    case modal
    case push
    case configuration
    case bank

    var title: String {
        switch self {
        case .modal:
            return "Modal Presentation"
        case .push:
            return "Push Presentation"
        case .configuration:
            return "Configuration"
        case .bank:
            return "Bank Modal Presentation"
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

    var title: String {
        switch self {
        case .showCancelButton:
            return "Show Cancel Button"
        case .showCountry:
            return "Show Country"
        }
    }
}

// MARK: PaymentSheet presentation

extension DemoViewController {
    // present a payment sheet modally
    private func modalPresentSheet(style: PaymentInputController.Style) {
        // prepare a payment sheet with configurable cancel button, navigation cancel item, and country selection
        let paymentController = paymentSDK.paymentSheet(style: style,
                                                        theme: customTheme,
                                                        showCancelButton: showCancelButton,
                                                        showCancelItem: true,
                                                        showCountry: showCountry)
        paymentController.delegate = self
        // present the configured payment controller
        paymentSDK.present(from: self, paymentSheet: paymentController)
    }

    // push a payment sheet onto the parent navigation controller
    private func navigationPushSheet(style: PaymentInputController.Style) {
        let paymentSheet = paymentSDK.paymentSheet(style: style,
                                                   theme: customTheme,
                                                   showCancelButton: showCancelButton,
                                                   showCancelItem: false,
                                                   showCountry: showCountry)
        paymentSheet.delegate = self
        navigationController?.pushViewController(paymentSheet, animated: true)
    }
}

// MARK: Bank PaymentSheet presentation

extension DemoViewController {
    private func modalPresentBankSheet() {
        // prepare a payment sheet with configurable cancel button, navigation cancel item, and country selection
        // optionally specify the default bank account type
        let paymentController = paymentSDK.bankPaymentSheet(showCancelButton: showCancelButton,
                                                            showCancelItem: true)
        paymentController.delegate = self
        // present the configured payment controller
        paymentSDK.present(from: self, paymentSheet: paymentController)
    }
}

// MARK: PaymentActionDelegate

extension DemoViewController: PaymentActionDelegate {
    // display result
    func didSucceed(paymentController: PaymentInputController, instrument: TokenResponse) {
        debugPrint("got TokenizedCard: \(paymentController),\(instrument)")

        let resultController = ResultViewController()
        resultController.result = .success(instrument)
        debugPrint("""
        Got a token response with:
                id: \(instrument.id)
                fingerprint: \(instrument.fingerprint)
                created: \(instrument.created)
                updated: \(instrument.updated)
                instrument: \(instrument.instrument)
                expires: \(instrument.expires)
                isoCurrency: \(instrument.isoCurrency)
        """)

        paymentController.navigationController?.pushViewController(resultController, animated: true)
    }

    func didCancel(paymentController _: PaymentInputController) {
        debugPrint("cancel tapped")
        dismiss(animated: true)
    }

    func didFail(paymentController: PaymentInputController, error: Error) {
        debugPrint("failed to process with error: \(error)")

        let resultController = ResultViewController()
        if let error = error as? FinixError {
            debugPrint("FinixError with \(error.message), code: \(error.code)")
        }
        resultController.result = .error(error)
        paymentController.navigationController?.pushViewController(resultController, animated: true)
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
