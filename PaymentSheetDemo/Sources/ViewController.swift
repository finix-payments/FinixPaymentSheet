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

class ViewController: UIViewController {
    var paymentSDK: PaymentAction!

    override func viewDidLoad() {
        let credentials = FinixCredentials(applicationId: APPLICATION_ID)
        paymentSDK = .init(credentials: credentials)

        // Provide your own branding
        let logo: UIImage? = #imageLiteral(resourceName: "FinixLogo")
        let branding: PaymentInputController.Branding = .init(image: logo, title: "Daphne’s Corner")

        // Set up configuration
        paymentSDK.configuration = .init(title: "Card Entry", branding: branding, buttonTitle: "Tokenize", showsCancelButton: true)

        // Designate a delegate
        paymentSDK.delegate = self
        super.viewDidLoad()
    }

    // Present the Payment sheet with the provided presenter
    @IBAction func paymentSheetButtonTapped(_: Any) {
        let paymentController = paymentSDK.paymentSheet()
        paymentSDK.present(from: self, paymentSheet: paymentController)
    }

    // Present the Payment Sheet with your own navgiation
    @IBAction func navigationPushTapped(_: Any) {
        let paymentSheet = paymentSDK.paymentSheet()
        paymentSheet.delegate = self
        let navigationController = UINavigationController(rootViewController: paymentSheet)

        present(navigationController, animated: true)
    }
}

extension ViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            self.paymentSheetButtonTapped("Show Me!")
        }
    }
}

extension ViewController: PaymentActionDelegate {
    func didSucceed(paymentController: PaymentInputController, instrument: TokenResponse) {
        debugPrint("got TokenizedCard: \(paymentController),\(instrument)")
        let successAlert = UIAlertController(title: "Card Tokenized", message: "Card is \(instrument)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        successAlert.addAction(okAction)

        let presenting = paymentController.presentingViewController
        paymentController.dismiss(animated: true) {
            presenting?.present(successAlert, animated: true)
        }
    }

    func didCancel(paymentController _: PaymentInputController) {
        debugPrint("cancel tapped")
        dismiss(animated: true)
    }

    func didFail(paymentController: PaymentInputController, error: Error) {
        debugPrint("failed to process with error: \(error)")

        let failureAlert = UIAlertController(title: "Card Tokenized",
                                             message: "Card failed: \(error)",
                                             preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        failureAlert.addAction(okAction)

        let presenting = paymentController.presentingViewController
        paymentController.dismiss(animated: true) {
            presenting?.present(failureAlert, animated: true)
        }
    }
}
