//
//  ViewController.swift
//  WeLoop
//
//  Created by HHK1 on 04/04/2019.
//  Copyright (c) 2019 HHK1. All rights reserved.
//

import UIKit
@testable import WeLoop

class ViewController: UIViewController {

    @IBOutlet weak var invocationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var launchButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        invocationSegmentedControl.selectedSegmentIndex = WeLoop.shared.invocationMethod.rawValue
    }

    @IBAction func launch(_ sender: Any) {
        WeLoop.invoke()
    }
    
    @IBAction func setInvocation(_ sender: UISegmentedControl) {
        guard let method = WeLoopInvocation(rawValue: sender.selectedSegmentIndex) else { return }
        WeLoop.set(invocationMethod: method)
    }
}

