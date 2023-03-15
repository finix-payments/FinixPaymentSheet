Pod::Spec.new do |s|
  'This podspec provides an xcframework for FinixPaymentSheet'

  s.name                           = 'FinixPaymentSheet'
  s.version                        = '0.9.4.2'
  s.summary                        = 'FinixPaymentSheet provides a convenient card tokenization UI.'
  s.license                        = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.homepage                       = 'https://www.finix.com/docs/guides/payments/'
  s.authors                        = { 'Finix Payments' => 'developers@finix.com' }
  
  s.source                         = { :git => 'git@github.com:finix-payments/FinixPaymentSheet.git', :tag => "v#{s.version}" }
  s.frameworks                     = 'Foundation', 'UIKit'
  s.requires_arc                   = true
  s.platform                       = :ios, "10.0"
  s.swift_version		               = '5.3'
  s.vendored_frameworks           = 'FinixPaymentSheet.xcframework'
# s.ios.resource_bundle            = { '' => 'FinixPaymentSheet/Resources/**/*.lproj' }
end
