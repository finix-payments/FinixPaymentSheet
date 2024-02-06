Pod::Spec.new do |s|
  'This podspec provides an xcframework for FinixPaymentSheet'

  s.name                           = 'FinixPaymentSheet'
  s.version                        = '0.9'
  s.summary                        = 'FinixPaymentSheet provides a convenient card tokenization UI.'
  s.license                        = 'TODO'
#s.license                        = { :type => '', :file => 'LICENSE' }
  s.homepage                       = 'https://www.finix.com/docs/guides/payments/'
  s.authors                        = { 'Finix Payments' => 'developers@finix.com' }
  
  s.source                         = { :git => 'git@github.com:finix-payments/FinixPaymentSheet.git', :tag => "#{s.version}" }
  s.frameworks                     = 'Foundation', 'UIKit'
  s.requires_arc                   = true
  s.platform                       = :ios, "10.0"
  s.swift_version		               = '5.0'
#s.source_files                   = 'Sources/**/*.swift'
  s.vendored_frameworks           = 'FinixPaymentSheet.xcframework'
#s.ios.resource_bundle            = { '' => 'PaymentSheet/Resources/**/*.lproj' }
end
