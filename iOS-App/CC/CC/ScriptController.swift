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
    var linearPinchGestureRecognizer : UIPinchGestureRecognizer? = nil
    var angularPinchGestureRecognizer : UIPinchGestureRecognizer? = nil
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // add gesture recognizer
        linearPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("handlePinchWithGestureRecognizer:"))
        angularPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("handlePinchWithGestureRecognizer:"))
        
        let linearTimelineViewFrame = CGRectMake(0.0, 0.0, linearScrollview.bounds.width, linearScrollview.frame.height)
        linearTimelineView = TimelineView(frame: linearTimelineViewFrame)
        linearScrollview.addSubview(linearTimelineView!)
        linearScrollview.contentSize = CGSize(width: linearScrollview.frame.width, height: linearTimelineView!.frame.height)
        linearScrollview.addGestureRecognizer(linearPinchGestureRecognizer!)
        
        let angularTimelineViewFrame = CGRectMake(0.0, 0.0, angularScrollview.bounds.width, angularScrollview.frame.height)
        angularTimelineView = TimelineView(frame: angularTimelineViewFrame)
        angularScrollview.addSubview(angularTimelineView!)
        angularScrollview.contentSize = CGSize(width: angularScrollview.frame.width, height: angularTimelineView!.frame.height)
        angularScrollview.addGestureRecognizer(angularPinchGestureRecognizer!)

        
        linearScrollview.delegate = self
        angularScrollview.delegate = self
        
        let yo = Script(withName: "yo")
        yo.addAction(ScriptAction(start: 0.0, length: 20.0, direction: .LEFT, speed: 10))
        yo.addAction(ScriptAction(start: 10.0, length: 5.0, direction: .CW, speed: 20))
        yo.addAction(ScriptAction(start: 80.0, length: 60.0, direction: .CCW, speed: 50))
        yo.addAction(ScriptAction(start: 40.0, length: 18.0, direction: .LEFT, speed: 5))
        yo.addAction(ScriptAction(start: 60.0, length: 30.0, direction: .RIGHT, speed: 2))
        yo.play(on: CameraSlider.getInstance()){
            print("ready done stuff")
        }
        
        linearTimelineView?.replaceScriptActionsInView(yo.linearActions)
        angularTimelineView?.replaceScriptActionsInView(yo.angularActions)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // hide the status bar for the whole view controller
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        linearTimelineView?.removeGestureRecognizer(linearPinchGestureRecognizer!)
        angularTimelineView?.removeGestureRecognizer(angularPinchGestureRecognizer!)
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
    
    func handlePinchWithGestureRecognizer(recognizer: UIPinchGestureRecognizer){

        // we do not distinct between linear and angular scroll view since we are
        // only interested in the y position
        let pinchCenter = recognizer.locationInView(linearScrollview).y
        let percentScrolledInTimeline = (linearTimelineView?.frame.size.height)!
        let contentOffset = linearScrollview.contentOffset.y * (recognizer.scale/2)
        
        print("location")
        print(recognizer.locationInView(linearTimelineView))
        
//        linearScrollview.setContentOffset(CGPoint(x: 0.0, y: pinchCenter), animated: true)
        
        linearTimelineView!.setScale(Double(recognizer.scale))
        angularTimelineView!.setScale(Double(recognizer.scale))
        let linearHeight = linearTimelineView?.frame.maxY
        let angularHeight = angularTimelineView?.frame.maxY
        if linearHeight > angularHeight{
            angularTimelineView!.frame.size.height = linearHeight!
            angularScrollview!.contentSize.height = linearHeight!
        }
        else{
            linearTimelineView!.frame.size.height = angularHeight!
            linearScrollview!.contentSize.height = angularHeight!
        }
        
        linearScrollview.setContentOffset(CGPoint(x: 0.0, y: contentOffset), animated: false)
        
    }

}

