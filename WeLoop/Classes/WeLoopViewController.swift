//
//  WeLoopViewController.swift
//  WeLoop
//
//  Created by Henry Huck on 04/04/2019.
//

import UIKit
import WebKit

enum WeLoopWebAction: String, CaseIterable {
    case exit = "WeloopClosePanel"
    case getCapture = "WeloopGetCapture"
    case response = "WeloopResponse"
    case generic = "WeloopIOS"
}

class WeLoopViewController: UIViewController {
    
    var url: URL?
    weak var webView: WKWebView!
    var window: UIWindow = UIWindow(frame: UIScreen.main.bounds)

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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        configureWebview()
    }

    private func configureWebview() {
        let webView = FullScreenWKWebView(frame: view.bounds, configuration: self.configuration)
        view.addSubview(webView)
    
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        webView.allowsLinkPreview = false
        webView.scrollView.delegate = self
        webView.scrollView.bounces = false
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true;
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true;
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true;
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true;
        
        webView.scrollView.showsVerticalScrollIndicator = false
        self.webView = webView
        loadWeLoop()
    }
    
    private func loadWeLoop() {
        guard let url = url else { return }
        webView.load(URLRequest(url: url))
    }
    
    @objc func back() {
        WeLoop.shared.closeWidget()
    }
    
    func sendScreenshot() {
        guard let imageData = WeLoop.shared.screenshot?.toBase64() else { return }
        webView?.evaluateJavaScript("getCapture('data:image/jpg;base64,\(imageData)')")
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
        default:
            break
        }
    }
}

extension WeLoopViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}
