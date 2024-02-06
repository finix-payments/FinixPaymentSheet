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
    case success(TokenResponse)
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
        navigationController?.presentingViewController?.dismiss(animated: true)
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
            case let .success(response):
                textView.text = String(describing: response)
                navigationItem.title = "Tokenize Response"
            case .none:
                textView.text = nil
                navigationItem.title = nil
            }
        }
    }
}
