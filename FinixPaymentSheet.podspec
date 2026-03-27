Pod::Spec.new do |s|
  # This podspec provides a prebuilt xcframework for FinixPaymentSheet
  # Includes full Objective-C and Swift support

  s.name                           = 'FinixPaymentSheet'
  s.version                           = '1.0.9'
  s.summary                        = 'FinixPaymentSheet provides a convenient card tokenization UI for iOS with full Objective-C support.'
  s.description                    = <<-DESC
                                      FinixPaymentSheet is a native iOS SDK that provides:
                                      - Card payment tokenization UI
                                      - Bank account (ACH) payment UI
                                      - Full Swift and Objective-C support
                                      - Customizable themes and localization
                                      - Multiple presentation styles (modal, push)
                                      - Secure token generation via Finix API
                                     DESC

  s.license                        = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.homepage                       = 'https://www.finix.com/docs/guides/payments/'
  s.authors                        = { 'Finix Payments' => 'developers@finix.com' }
  s.documentation_url              = 'https://github.com/finix-payments/FinixPaymentSheet'

  # Source configuration
  # Public GitHub repository containing the prebuilt xcframework
  s.source                         = {
    :git => 'https://github.com/finix-payments/FinixPaymentSheet.git',
    :tag => "v#{s.version}"
  }

  # Platform requirements
  s.platform                       = :ios, "12.0"
  s.ios.deployment_target          = '12.0'
  s.swift_version                  = '5.8'

  # Framework configuration
  # Path to xcframework in public FinixPaymentSheet repo
  s.vendored_frameworks            = 'FinixPaymentSheet.xcframework'
  s.frameworks                     = 'Foundation', 'UIKit'
  s.requires_arc                   = true

  # Module configuration for Swift/Objective-C interop
  s.module_name                    = 'FinixPaymentSheet'

  # Preserve paths for xcframework structure
  s.preserve_paths                 = 'FinixPaymentSheet.xcframework/**/*'

end
