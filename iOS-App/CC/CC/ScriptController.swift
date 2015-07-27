//
//  SecondViewController.swift
//  CC
//
//  Created by Tobias Schneider on 4/28/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class ScriptController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // hide the status bar for the whole view controller
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

