//
//  SecondViewController.swift
//  CC
//
//  Created by Tobias Schneider on 4/28/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class ScriptController: UIViewController {

    @IBOutlet weak var linearScrollview: UIScrollView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let timelineViewFrame = CGRectMake(0.0, 0.0, linearScrollview.bounds.width, linearScrollview.frame.height)
        let timelineView = TimelineView(frame: timelineViewFrame)
        linearScrollview.addSubview(timelineView)
        linearScrollview.contentSize = CGSize(width: linearScrollview.frame.width, height: timelineView.frame.height)
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

