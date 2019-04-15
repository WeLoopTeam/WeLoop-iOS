//
//  ViewController.swift
//  WeLoop
//
//  Created by HHK1 on 04/04/2019.
//  Copyright (c) 2019 HHK1. All rights reserved.
//

import UIKit
import WeLoop

class ViewController: UIViewController {

    @IBOutlet weak var launchButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func launch(_ sender: Any) {
        WeLoop.invoke()
    }
    
    @IBAction func setInvocation(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            WeLoop.setInvocationMethod(.manual)
        case 1:
            WeLoop.setInvocationMethod(.shakeGesture)
        default:
            WeLoop.setInvocationMethod(.fab)
        }
    }
    
}

