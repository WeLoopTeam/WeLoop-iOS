//
//  WeLoopViewController.swift
//  WeLoop
//
//  Created by Henry Huck on 04/04/2019.
//

import UIKit
import WebKit


private let margin: CGFloat = 16

class WeLoopViewController: UIViewController {
    
    let backButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
    var url: URL?
    weak var webview: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        addBackButton()
        configureWebview()
    }
    
    private func addBackButton() {
        view.addSubview(backButton)
        
        if #available(iOS 11, *) {
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: margin).isActive = true
        } else {
            backButton.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor, constant: margin).isActive = true
        }
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin).isActive = true
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(WeLoopViewController.back), for: .touchUpInside)
    }
    
    private func configureWebview() {
        
        let webView = WKWebView(frame: view.bounds, configuration: .init())
        view.addSubview(webView)
        self.webview = webView
      
        webview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        loadWeLoop()
    }
    
    private func loadWeLoop() {
        let request = URLRequest(url: url!)
        webview.load(request)
    }

    @objc func back() {
        UIApplication.shared.delegate?.window??.rootViewController = WeLoop.shared.previousViewController
    }
}
