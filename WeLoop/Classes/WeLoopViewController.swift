//
//  WeLoopViewController.swift
//  WeLoop
//
//  Created by Henry Huck on 04/04/2019.
//

import UIKit
import WebKit


private let margin: CGFloat = 16

private let weLoopScript = "WeloopIOS"
struct WeLoopWebAction {
    static let exit = "onClosePanel"
    static let onCapture = "onCapture"
}

class WeLoopViewController: UIViewController {
    
    let backButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
    var url: URL?
    weak var webView: WKWebView!
    
    lazy var configuration: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        let userController = WKUserContentController()
        userController.add(self, name: weLoopScript)
        config.userContentController = userController
        return config
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebview()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func configureWebview() {
        let webView = WKWebView(frame: view.bounds, configuration: self.configuration)
        view.addSubview(webView)
        webView.scrollView.delegate = self
        webView.allowsLinkPreview = false
        
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.webView = webView
        loadWeLoop()
    }
    
    private func loadWeLoop() {
        guard let url = url else { return }
        webView.load(URLRequest(url: url))
    }
    
    @objc func back() {
        WeLoop.close()
    }
}

extension WeLoopViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

extension WeLoopViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        guard let payload = message.body as? Dictionary<String, Any> else { return }
        
        if (payload[WeLoopWebAction.exit] != nil) {
            back()
        } else if let onCapture = payload[WeLoopWebAction.onCapture] {
            webView?.evaluateJavaScript("""
                getCapture('yolo')
            """, completionHandler: { (response, error) in
                print(response as Any)
                print(error as Any)
            })
        }
    }
}
