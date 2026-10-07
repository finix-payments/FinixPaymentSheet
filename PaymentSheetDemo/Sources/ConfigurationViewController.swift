//
//  ConfigurationViewController.swift
//  PaymentSheetDemo
//
//  Created by Israrul Haque on 2026-09-22.
//

import FinixPaymentSheet
import UIKit

/// View controller for configuring demo app credentials
/// Users must provide their own Finix API credentials
class ConfigurationViewController: UITableViewController {
    // MARK: - Properties

    private let config = DemoConfiguration.shared
    private var onSave: (() -> Void)?

    // MARK: - Text Fields

    private lazy var applicationIdField: UITextField = createTextField(
        placeholder: "APxxxxxxxxxxxxxxxxx",
        text: config.applicationId,
        keyboardType: .asciiCapable
    )

    private lazy var merchantIdField: UITextField = createTextField(
        placeholder: "MUxxxxxxxxxxxxxxxxx",
        text: config.merchantId,
        keyboardType: .asciiCapable
    )

    private lazy var apiUsernameField: UITextField = createTextField(
        placeholder: "USxxxxxxxxxxxxxxxxx",
        text: config.apiUsername,
        keyboardType: .asciiCapable
    )

    private lazy var apiPasswordField: UITextField = createTextField(
        placeholder: "API Password",
        text: config.apiPassword,
        keyboardType: .asciiCapable,
        isSecure: true
    )

    private lazy var environmentSegment: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Live", "Sandbox"])
        control.selectedSegmentIndex = segmentIndex(for: config.environment)
        control.addTarget(self, action: #selector(environmentChanged), for: .valueChanged)
        return control
    }()

    // MARK: - Environment Mapping

    private func segmentIndex(for endpoint: FinixAPIEndpoint) -> Int {
        switch endpoint {
        case .Live: return 0
        case .Sandbox: return 1
        @unknown default: return 1
        }
    }

    private func endpoint(for segmentIndex: Int) -> FinixAPIEndpoint {
        switch segmentIndex {
        case 0: return .Live
        case 1: return .Sandbox
        default: return .Sandbox
        }
    }

    // MARK: - Sections

    private enum Section: Int, CaseIterable {
        case environment
        case credentials
        case threeDSCredentials
        case actions

        var title: String? {
            switch self {
            case .environment: return "Environment"
            case .credentials: return "Application Credentials"
            case .threeDSCredentials: return "3DS Credentials (Optional)"
            case .actions: return nil
            }
        }

        var footer: String? {
            switch self {
            case .environment:
                return "Select the Finix environment to use."
            case .credentials:
                return "Enter your Finix Application ID. Get this from your Finix Dashboard."
            case .threeDSCredentials:
                return "Required for 3DS authentication. Enter your Merchant ID and API credentials."
            case .actions:
                return nil
            }
        }

        var rowCount: Int {
            switch self {
            case .environment: return 1
            case .credentials: return 1
            case .threeDSCredentials: return 3
            case .actions: return 1
            }
        }
    }

    // MARK: - Initialization

    init(onSave: (() -> Void)? = nil) {
        self.onSave = onSave
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Configuration"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.keyboardDismissMode = .interactive

        // Set initial field editability based on environment
        updateFieldEditability()
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        saveConfiguration()

        if config.hasBasicCredentials {
            navigationController?.popViewController(animated: true)
            onSave?()
        } else {
            showAlert(
                title: "Missing Credentials",
                message: "Please enter at least the Application ID to continue."
            )
        }
    }

    private func saveConfiguration() {
        config.applicationId = applicationIdField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        config.merchantId = merchantIdField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        config.apiUsername = apiUsernameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        config.apiPassword = apiPasswordField.text ?? ""
        config.environment = endpoint(for: environmentSegment.selectedSegmentIndex)
    }

    @objc private func environmentChanged() {
        // Save current fields to current environment before switching
        saveConfiguration()

        // Switch environment
        config.environment = endpoint(for: environmentSegment.selectedSegmentIndex)

        // Reload fields with new environment's values
        reloadFieldsFromConfig()

        // Update field editability based on environment
        updateFieldEditability()

        // Reload table to update footer text
        tableView.reloadData()
    }

    private func updateFieldEditability() {
        // All fields are editable
        applicationIdField.isEnabled = true
        merchantIdField.isEnabled = true
        apiUsernameField.isEnabled = true
        apiPasswordField.isEnabled = true

        applicationIdField.textColor = .label
        merchantIdField.textColor = .label
        apiUsernameField.textColor = .label
        apiPasswordField.textColor = .label
    }

    @objc private func clearTapped() {
        let alert = UIAlertController(
            title: "Clear Configuration",
            message: "Are you sure you want to clear credentials for this environment?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.clearConfiguration()
        })
        present(alert, animated: true)
    }

    private func clearConfiguration() {
        config.clearCurrentEnvironment()
        reloadFieldsFromConfig()
    }

    private func reloadFieldsFromConfig() {
        applicationIdField.text = config.applicationId
        merchantIdField.text = config.merchantId
        apiUsernameField.text = config.apiUsername
        apiPasswordField.text = config.apiPassword
    }

    // MARK: - Helpers

    private func createTextField(
        placeholder: String,
        text: String,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false
    ) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.text = text
        field.keyboardType = keyboardType
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.isSecureTextEntry = isSecure
        field.clearButtonMode = .whileEditing
        field.font = .systemFont(ofSize: 16)
        return field
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in _: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        Section.allCases[section].rowCount
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section.allCases[section].title
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        Section.allCases[section].footer
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = .none

        let section = Section.allCases[indexPath.section]

        switch section {
        case .environment:
            cell.contentView.addSubview(environmentSegment)
            environmentSegment.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                environmentSegment.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                environmentSegment.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                environmentSegment.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            ])

        case .credentials:
            configureTextFieldCell(cell, label: "Application ID", textField: applicationIdField)

        case .threeDSCredentials:
            switch indexPath.row {
            case 0:
                configureTextFieldCell(cell, label: "Merchant ID", textField: merchantIdField)
            case 1:
                configureTextFieldCell(cell, label: "API Username", textField: apiUsernameField)
            case 2:
                configureTextFieldCell(cell, label: "API Password", textField: apiPasswordField)
            default:
                break
            }

        case .actions:
            cell.selectionStyle = .default
            cell.textLabel?.text = "Clear All"
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.textAlignment = .center
        }

        return cell
    }

    private func configureTextFieldCell(_ cell: UITableViewCell, label: String, textField: UITextField) {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 14, weight: .medium)
        labelView.textColor = .secondaryLabel
        labelView.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [labelView, textField])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
        ])
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let section = Section.allCases[indexPath.section]
        guard section == .actions else { return }

        clearTapped()
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = Section.allCases[indexPath.section]
        switch section {
        case .credentials, .threeDSCredentials:
            return 60
        default:
            return 44
        }
    }
}
