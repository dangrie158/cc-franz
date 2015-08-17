//
//  SecondViewController.swift
//  CC
//
//  Created by Tobias Schneider on 4/28/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class ScriptController: UIViewController, UIScrollViewDelegate {

    
    @IBOutlet weak var angularScrollview: UIScrollView!
    @IBOutlet weak var linearScrollview: UIScrollView!
    var linearTimelineView : TimelineView? = nil
    var angularTimelineView : TimelineView? = nil
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let linearTimelineViewFrame = CGRectMake(0.0, 0.0, linearScrollview.bounds.width, linearScrollview.frame.height)
        linearTimelineView = TimelineView(frame: linearTimelineViewFrame)
        linearScrollview.addSubview(linearTimelineView!)
        linearScrollview.contentSize = CGSize(width: linearScrollview.frame.width, height: linearTimelineView!.frame.height)
        
        let angularTimelineViewFrame = CGRectMake(0.0, 0.0, angularScrollview.bounds.width, angularScrollview.frame.height)
        angularTimelineView = TimelineView(frame: angularTimelineViewFrame)
        angularScrollview.addSubview(angularTimelineView!)
        angularScrollview.contentSize = CGSize(width: angularScrollview.frame.width, height: angularTimelineView!.frame.height)
        // Do any additional setup after loading the view, typically from a nib.
        
        linearScrollview.delegate = self
        angularScrollview.delegate = self
        
        let yo = Script(withName: "yo")
        yo.addAction(ScriptAction(start: 0.0, length: 5.0, direction: .LEFT, speed: 10))
        yo.addAction(ScriptAction(start: 3.0, length: 5.0, direction: .CW, speed: 20))
        yo.addAction(ScriptAction(start: 12.0, length: 8.0, direction: .CCW, speed: 50))
        yo.addAction(ScriptAction(start: 20.0, length: 3.0, direction: .LEFT, speed: 5))
        yo.addAction(ScriptAction(start: 28.0, length: 1.0, direction: .RIGHT, speed: 2))
        yo.play(on: CameraSlider.getInstance()){
            print("ready done stuff")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // hide the status bar for the whole view controller
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // synchronize the scroll position between the angular and linear scrollview
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == linearScrollview{
            angularScrollview.contentOffset = linearScrollview.contentOffset
        }
        else {
            linearScrollview.contentOffset = angularScrollview.contentOffset
        }
    }

}

