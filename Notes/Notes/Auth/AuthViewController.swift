//
//  AuthViewController.swift
//  Notes
//
//  Created by Dmitriy on 08/08/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit
import WebKit

protocol AuthViewControllerDelegate: class {
    func handleTokenChanged(token: String?)
    func loadNotes()
}

protocol AuthViewProtocol: class {
    var webView: WKWebView { get }
    func dismiss()
}

protocol AuthPresenterProtocol: WKNavigationDelegate {
    func startAuth()
}

class AuthViewController: UIViewController, AuthViewProtocol {
    
    private weak var delegate: AuthViewControllerDelegate!
    private var presenter: AuthPresenterProtocol!
    private(set) var webView = WKWebView()
    
    convenience init(delegate: AuthViewControllerDelegate){
        self.init()
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presenter = AuthViewPresenter(view: self, delegate: delegate)
        webView.navigationDelegate = presenter
        presenter.startAuth()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.loadNotes()
    }
    
    func dismiss() {
        if Thread.isMainThread {
            self.dismiss(animated: true, completion: nil)
        } else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}




