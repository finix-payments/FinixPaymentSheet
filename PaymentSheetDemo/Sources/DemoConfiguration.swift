//
//  DemoConfiguration.swift
//  PaymentSheetDemo
//
//  Created by Israrul Haque on 2026-09-22.
//

import FinixPaymentSheet
import Foundation

// MARK: - Test Credentials

/// Preset test credentials for internal testing
/// These credentials are for the Finix QA/Sandbox environments only
enum TestCredentials {
    // Sandbox - pre-configured with sample Application ID for basic tokenization
    // 3DS credentials must be configured separately via settings
    static let sandbox = DemoEnvironmentConfig(
        applicationId: "APgPDQrLD52TYvqazjHJJchM",
        merchantId: "",
        apiUsername: "",
        apiPassword: "",
        amount: 9900
    )

    // Production - empty, user must configure
    static let production = DemoEnvironmentConfig(
        applicationId: "",
        merchantId: "",
        apiUsername: "",
        apiPassword: "",
        amount: 9900
    )
}

// MARK: - Per-Environment Configuration

/// Configuration for a specific environment
struct DemoEnvironmentConfig: Codable, Equatable {
    var applicationId: String
    var merchantId: String
    var apiUsername: String
    var apiPassword: String
    var amount: Int

    init(
        applicationId: String = "",
        merchantId: String = "",
        apiUsername: String = "",
        apiPassword: String = "",
        amount: Int = 0
    ) {
        self.applicationId = applicationId
        self.merchantId = merchantId
        self.apiUsername = apiUsername
        self.apiPassword = apiPassword
        self.amount = amount
    }

    var hasBasicCredentials: Bool {
        !applicationId.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var has3DSCredentials: Bool {
        !merchantId.trimmingCharacters(in: .whitespaces).isEmpty &&
            !apiUsername.trimmingCharacters(in: .whitespaces).isEmpty &&
            !apiPassword.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

/// Container for all environment configurations
struct DemoAllEnvironmentConfigs: Codable {
    var configs: [String: DemoEnvironmentConfig]
    var selectedEnvironment: String

    init() {
        configs = [
            "sandbox": TestCredentials.sandbox,
            "production": DemoEnvironmentConfig(),
        ]
        selectedEnvironment = "sandbox"
    }

    func currentConfig() -> DemoEnvironmentConfig {
        configs[selectedEnvironment] ?? DemoEnvironmentConfig()
    }

    mutating func updateConfig(_ config: DemoEnvironmentConfig, for environment: String) {
        configs[environment.lowercased()] = config
    }

    var availableEnvironments: [String] {
        ["sandbox", "production"]
    }
}

// MARK: - Demo Configuration

/// Configuration storage for demo app credentials
/// Stores credentials separately for each environment
@objc final class DemoConfiguration: NSObject {
    @objc static let shared = DemoConfiguration()

    private let defaults = UserDefaults.standard
    private let storageKey = "demo_all_environment_configs"

    private var allConfigs: DemoAllEnvironmentConfigs

    override private init() {
        allConfigs = Self.load(from: defaults, key: storageKey)
        super.init()
    }

    // MARK: - Persistence

    private static func load(from defaults: UserDefaults, key: String) -> DemoAllEnvironmentConfigs {
        guard let data = defaults.data(forKey: key) else {
            return DemoAllEnvironmentConfigs()
        }

        do {
            return try JSONDecoder().decode(DemoAllEnvironmentConfigs.self, from: data)
        } catch {
            #if DEBUG
                print("[DemoConfig] Failed to decode: \(error)")
            #endif
            return DemoAllEnvironmentConfigs()
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(allConfigs)
            defaults.set(data, forKey: storageKey)
        } catch {
            #if DEBUG
                print("[DemoConfig] Failed to save: \(error)")
            #endif
        }
    }

    // MARK: - Current Environment Config

    private var currentConfig: DemoEnvironmentConfig {
        get {
            return allConfigs.currentConfig()
        }
        set {
            allConfigs.updateConfig(newValue, for: allConfigs.selectedEnvironment)
            save()
        }
    }

    // MARK: - Environment

    var environment: FinixAPIEndpoint {
        get {
            switch allConfigs.selectedEnvironment.lowercased() {
            case "sandbox": return .Sandbox
            case "production", "live": return .Live
            default: return .Sandbox
            }
        }
        set {
            switch newValue {
            case .Sandbox: allConfigs.selectedEnvironment = "sandbox"
            case .Live: allConfigs.selectedEnvironment = "production"
            @unknown default: allConfigs.selectedEnvironment = "sandbox"
            }
            save()
        }
    }

    // MARK: - Properties (per-environment)

    var applicationId: String {
        get {
            let storedId = currentConfig.applicationId
            // Use default APPLICATION_ID for sandbox if not configured
            if storedId.isEmpty && allConfigs.selectedEnvironment == "sandbox" {
                return "APgPDQrLD52TYvqazjHJJchM"
            }
            return storedId
        }
        set {
            var config = currentConfig
            config.applicationId = newValue
            currentConfig = config
        }
    }

    var merchantId: String {
        get { currentConfig.merchantId }
        set {
            var config = currentConfig
            config.merchantId = newValue
            currentConfig = config
        }
    }

    var apiUsername: String {
        get { currentConfig.apiUsername }
        set {
            var config = currentConfig
            config.apiUsername = newValue
            currentConfig = config
        }
    }

    var apiPassword: String {
        get { currentConfig.apiPassword }
        set {
            var config = currentConfig
            config.apiPassword = newValue
            currentConfig = config
        }
    }

    var amount: Int {
        get { currentConfig.amount }
        set {
            var config = currentConfig
            config.amount = newValue
            currentConfig = config
        }
    }

    // MARK: - Validation

    @objc var hasBasicCredentials: Bool {
        // Use the applicationId property which includes fallback for sandbox
        !applicationId.trimmingCharacters(in: .whitespaces).isEmpty
    }

    @objc var has3DSCredentials: Bool {
        currentConfig.has3DSCredentials
    }

    @objc var isFullyConfigured: Bool {
        hasBasicCredentials && has3DSCredentials
    }

    // MARK: - Convenience

    @objc var finixCredentials: FinixCredentials {
        FinixCredentials(
            applicationId: applicationId,
            environment: environment,
            merchantId: merchantId.isEmpty ? nil : merchantId
        )
    }

    /// Creates ThreeDSConfiguration if 3DS credentials are available and enabled
    /// - Parameters:
    ///   - redirectScheme: Custom URL scheme for 3DS redirect
    ///   - isEnabled: Whether 3DS is enabled (nil configuration disables 3DS)
    @objc func threeDSConfiguration(redirectScheme: String, isEnabled: Bool = true) -> ThreeDSConfiguration? {
        guard has3DSCredentials, isEnabled else {
            return nil
        }

        return ThreeDSConfiguration(redirectScheme: redirectScheme)
    }

    /// Objective-C compatible configuration builder with 3DS support
    @objc func paymentConfiguration(
        title: String?,
        branding: PaymentInputController.Branding,
        buttonTitle: String,
        enableCardScanning: Bool,
        redirectScheme: String
    ) -> PaymentInputController.Configuration {
        // Convert empty strings to nil for optional credentials
        let merchantIdValue = merchantId.isEmpty ? nil : merchantId
        let apiUsernameValue = apiUsername.isEmpty ? nil : apiUsername
        let apiPasswordValue = apiPassword.isEmpty ? nil : apiPassword

        return PaymentInputController.Configuration(
            title: title,
            branding: branding,
            buttonTitle: buttonTitle,
            enableCardScanning: enableCardScanning,
            threeDSConfiguration: threeDSConfiguration(redirectScheme: redirectScheme),
            merchantId: merchantIdValue,
            apiUsername: apiUsernameValue,
            apiPassword: apiPasswordValue,
            amount: amount > 0 ? amount : 9900,
            currency: "USD"
        )
    }

    // MARK: - Reset

    func clearAll() {
        allConfigs = DemoAllEnvironmentConfigs()
        save()
    }

    func clearCurrentEnvironment() {
        currentConfig = DemoEnvironmentConfig()
    }
}
