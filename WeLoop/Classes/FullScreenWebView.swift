//
//  FullScreenWebView.swift
//  Pods-WeLoop_Example
//
//  Created by Henry Huck on 24/04/2019.
//

import UIKit
import WebKit

class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        return .zero
    }
}
