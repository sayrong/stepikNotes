//
//  AuthViewController.swift
//  Notes
//
//  Created by Dmitriy on 08/08/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit
import WebKit
import CocoaLumberjack

protocol AuthViewControllerDelegate: class {
    func handleTokenChanged(token: String?)
    func loadNotes()
}

class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let webView = WKWebView()
    private let clientId = ""
    private let clientSecret = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        guard let request = tokenGetRequest else { return }
        webView.load(request)
        webView.navigationDelegate = self
    }
    
    // MARK: Private
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

    private var tokenGetRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: "https://github.com/login/oauth/authorize") else { return nil }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "\(clientId)"),
            URLQueryItem(name: "scope", value: "gist")
        ]
        
        guard let url = urlComponents.url else { return nil }
        
        return URLRequest(url: url)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.loadNotes()
    }
    
    //Приходит срока вида access_token=e72e16c7e42f292c6912e7710c838347ae178b4a&token_type=bearer
    //Т.к. мы не указали application/json
    func parseAnswer(data: Data?) -> String? {
        if let data = data {
            if let string = String(data: data, encoding: .utf8) {
                if let accessTokenBlock = string.components(separatedBy: "&").first {
                    if accessTokenBlock.contains("access_token") {
                        let token = accessTokenBlock.components(separatedBy: "=")
                        if token.count == 2 {
                            return token[1]
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func getToken(code: String, completion: @escaping (String?)->()){
        guard var urlComponents = URLComponents(string: "https://github.com/login/oauth/access_token") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "client_id", value: "\(clientId)"),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "code", value: code)
        ]
        guard let url = urlComponents.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    print("Success")
                    completion(self.parseAnswer(data: data))
                default:
                    print("Status: \(response.statusCode)")
                }
            }
        }.resume()
    }
    
}




extension AuthViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == scheme {
            let targetString = url.absoluteString.replacingOccurrences(of: "#", with: "?")
            guard let components = URLComponents(string: targetString) else { return }
            
            if let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
                getToken(code: code) { token in
                    self.delegate?.handleTokenChanged(token: token)
                }
            }
        }
        defer {
            decisionHandler(.allow)
        }
    }
    
    //В случаем если сеть не доступна, или произошла какая-либо ошибка скрываем окно
    //Также сюда попадаем при получении scheme notes, т.к wkwebview не знаем как это обработать
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {

        DDLogError(error.localizedDescription)
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }

}

private let scheme = "notes" // схема для callback
