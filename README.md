# Finix Payment Sheet Release Notes

## Intro

This framework provides a Payment Sheet that you can use to tokenize credit cards. 
It provides a presenter or you can present the PaymentInputController yourself.

## Requirements

This requires:
  * iOS 11.0
  * Xcode 13 to use the XCFramework

## Usage

Link against the provided `FinixPaymentSheet.xcframework` directly by adding to your project.

The Demo project is set up to use the provided framework. It is commented to illustrate its usage.
   
## Setting up a payment sheet

See `DemoViewController.swift` for an example of presenting a payment sheet.

* initialize payment sdk with API credentials and branding configuration
* present payment sheet & register delegate
* handle response

## Changelog

See CHANGELOG for more details.
