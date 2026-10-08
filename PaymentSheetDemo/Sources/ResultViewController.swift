//
//  ResultViewController.swift
//  FinixPaymentSheet
//
//  Created by Jack Tihon on 8/8/22.
//

import FinixPaymentSheet
import Foundation
import UIKit

enum TokenizationResult {
    case success(TokenizedResponse)
    case error(Error)
}

// Assumes this pushed onto a ``UINavigationController``.
class ResultViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Result"
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        view.addSubview(textView)
        let textViewConstraints: [NSLayoutConstraint] = [
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(textViewConstraints)
    }

    @objc func doneTapped(_: Any?) {
        // Handle both modal presentation and navigation push
        if let navController = navigationController {
            if navController.presentingViewController != nil {
                // Modal presentation: dismiss the entire modal
                navController.presentingViewController?.dismiss(animated: true)
            } else if let paymentControllerIndex = navController.viewControllers.firstIndex(where: { $0 is PaymentInputController }) {
                // Navigation push with PaymentInputController in stack: pop to before it
                if paymentControllerIndex > 0 {
                    navController.popToViewController(navController.viewControllers[paymentControllerIndex - 1], animated: true)
                } else {
                    navController.popToRootViewController(animated: true)
                }
            } else {
                // ResultViewController was pushed after modal dismiss - just pop back
                navController.popViewController(animated: true)
            }
        }
    }

    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        return textView
    }()

    var result: TokenizationResult? {
        didSet {
            switch result {
            case let .error(error):
                textView.text = error.localizedDescription
                navigationItem.title = "Error"
            case .success:
                // Use updateDisplay to include 3DS session ID if set
                updateDisplay()
            case .none:
                textView.text = nil
                navigationItem.title = nil
            }
        }
    }

    /// 3DS Session ID to display (set before or after result)
    @objc var threeDSSessionId: String? {
        didSet {
            updateDisplay()
        }
    }

    private func updateDisplay() {
        guard case let .success(response) = result else { return }

        var text = String(describing: response)
        if let sessionId = threeDSSessionId {
            text += "\n\n3DS Session ID: \(sessionId)"
            navigationItem.title = "Token + 3DS"
        } else {
            navigationItem.title = "Tokenize Response"
        }
        textView.text = text
    }

    // MARK: - Objective-C Compatibility

    @objc func setResult(success instrument: TokenizedResponse) {
        result = .success(instrument)
    }

    @objc func setResult(error: Error) {
        result = .error(error)
    }
}
