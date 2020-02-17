//
//  WeLoopViewController.swift
//  WeLoop
//
//  Created by Henry Huck on 04/04/2019.
//

import Foundation
import UIKit
import WebKit

enum WeLoopWebAction: String, CaseIterable {
    case exit = "WeloopClosePanel"
    case getCapture = "WeloopGetCapture"
    case getCurrentUser = "GetCurrentUser"
    case setNotificationCount = "SetNotificationCount"
}

class WeLoopViewController: UIViewController {
    
    var url: URL?
    weak var webView: WKWebView!
    var window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    private var observation: NSKeyValueObservation?

    lazy var configuration: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        let userController = WKUserContentController()
        WeLoopWebAction.allCases.forEach({ userController.add(self, name: $0.rawValue)})
        config.userContentController = userController
        return config
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = true
        window.rootViewController = self
    }
    
    deinit {
        observation = nil
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        configureWebview()
        observeURLChanges()
        loadWeLoop()
    }

    private func configureWebview() {
        let webView = WKWebView(frame: view.bounds, configuration: self.configuration)
        self.webView = webView
        view.addSubview(webView)
        
        
        if #available(iOS 11.0, *) {
            let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: -bottomInset, right: 0)
        }
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        webView.allowsLinkPreview = false
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true;
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true;
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true;
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true;
        webView.scrollView.showsVerticalScrollIndicator = false
    }
    
    func loadWeLoop() {
        guard let url = url else { return }
        webView.alpha = 0
        webView.load(URLRequest(url: url))
    }
    
    @objc func back() {
        WeLoop.shared.closeWidget()
    }
    
    func sendScreenshot() {
        guard let imageData = WeLoop.shared.screenshot?.toBase64() else { return }
        webView?.evaluateJavaScript("getCapture('data:image/jpg;base64,\(imageData)')")
    }
    
    func sendCurrentUser() {
        guard let uuid = WeLoop.shared.apiKey, let token = WeLoop.shared.authenticationToken else { return }
        webView?.evaluateJavaScript("GetCurrentUser({ appGuid: \(uuid), token: \(token)})")
    }
}

extension WeLoopViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let name = WeLoopWebAction(rawValue: message.name) else { return }
        switch name {
        case .exit:
            back()
        case .getCapture:
           sendScreenshot()
        case .getCurrentUser:
            sendCurrentUser()
        case .setNotificationCount:
            guard let body = message.body as? [String: Any], let count = body["number"] as? Int else { return }
            WeLoop.shared.setNotificationBadge(count: count)
        }
    }
}

extension WeLoopViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

extension WeLoopViewController: WKNavigationDelegate {
    
    // Classic WKNavigationDelegate methods only work for full page loads, which is not the case inside a SPA
    // We force a reload  to /home when the widget  is closed, otherwise we'll see the actual widget.
    func observeURLChanges() {
        observation = webView.observe(\WKWebView.url, options: .new) { [weak self] _, change in
            if let newURL = change.newValue, newURL?.relativePath == "/" {
                    self?.loadWeLoop()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
         webView.alpha = 1
    }
}
