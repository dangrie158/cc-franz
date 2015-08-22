//
//  SecondViewController.swift
//  CC
//
//  Created by Tobias Schneider on 4/28/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class ScriptController: UIViewController, UIScrollViewDelegate {

    /*******************************
    * instance methods / variables *
    ********************************/
    var linearTimelineView : TimelineView? = nil
    var angularTimelineView : TimelineView? = nil
    var linearPinchGestureRecognizer : UIPinchGestureRecognizer? = nil
    var angularPinchGestureRecognizer : UIPinchGestureRecognizer? = nil
    var currentScript : Script? = nil
    var playbackStartedTime : NSDate? = nil
    var updateRecordTimeTimer:NSTimer? = nil
    var pauseClickedTime : NSDate? = nil
    var scale : Double = 1.0
    
    /*******************************
    *             outlets          *
    ********************************/
    @IBOutlet weak var angularScrollview: UIScrollView!
    @IBOutlet weak var linearScrollview: UIScrollView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var elapsedTimeView: FBLCDFontView!
    
    
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
        
        currentScript = Script(withName: "yo")
        currentScript!.addAction(ScriptAction(start: 0.0, length: 10.0, direction: .LEFT, speed: 10))
        currentScript!.addAction(ScriptAction(start: 10.0, length: 5.0, direction: .CW, speed: 20))
        currentScript!.addAction(ScriptAction(start: 10.0, length: 5.0, direction: .CCW, speed: 50))
        currentScript!.addAction(ScriptAction(start: 15.0, length: 5.0, direction: .LEFT, speed: 5))
        currentScript!.addAction(ScriptAction(start: 20.0, length: 5.0, direction: .RIGHT, speed: 2))

        
        linearTimelineView?.replaceScriptActionsInView(currentScript!.linearActions)
        angularTimelineView?.replaceScriptActionsInView(currentScript!.angularActions)
        
        self.elapsedTimeView.text = "00:00"

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

       
        let oldScale = self.scale
        if (oldScale < 10 && oldScale > 0.1) || (oldScale > 10 && recognizer.scale < 1) || (oldScale < 0.1 && recognizer.scale > 1) {
            self.scale *= Double(((recognizer.scale - 1) * 0.1) + 1 )
        }
        
        print(self.scale)
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
    
    /*******************************
    *          view actions        *
    ********************************/
    
    @IBAction func stopPressed(sender: AnyObject) {
        playButton.enabled = true
        pauseButton.enabled = false
        stopButton.enabled = false
        
        //enable scrolling
        linearScrollview.userInteractionEnabled = true
        angularScrollview.userInteractionEnabled = true
        
        // clean up the values and stop the timer
        self.updateRecordTimeTimer?.invalidate()
        self.updateRecordTimeTimer = nil
        self.currentScript?.stop()
        // when we stop we also reset the text to 0
        // (which we do not do when the playback just finished and was not stopped by the user,
        // this way we emphasize the stop action)
        self.elapsedTimeView.text = "00:00"
        self.pauseClickedTime = nil
        
        //move the script to the top
        linearScrollview.setContentOffset(CGPoint(x:0, y: 0), animated: true)
    }

    @IBAction func playPressed(sender: AnyObject) {
        playButton.enabled = false
        pauseButton.enabled = true
        stopButton.enabled = true
        
        //disable scrolling
        linearScrollview.userInteractionEnabled = false
        angularScrollview.userInteractionEnabled = false
        
        // if we are at the start of a recording
        if self.pauseClickedTime == nil {
            // save the time when the playback has started
            self.playbackStartedTime = NSDate()
        }
        else{
            // otherwise calculate the time the playback was paused ...
            let timeSincePauseStarted = NSDate().timeIntervalSinceDate((self.pauseClickedTime)!)
            self.pauseClickedTime = nil
            // ... and add it to the starting time, to get the real playback time
            self.playbackStartedTime = self.playbackStartedTime?.dateByAddingTimeInterval(timeSincePauseStarted)
        }
        // start a timer to update the display of the playback time
        self.updateRecordTimeTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("updatePlayTimer"), userInfo: nil, repeats: true)
        // play the recording
        self.currentScript?.play(on: CameraSlider.getInstance()){
            // clean up after the playback has finished
            self.updateRecordTimeTimer?.invalidate()
            self.updateRecordTimeTimer = nil
            self.elapsedTimeView.text = self.formatTime((self.currentScript?.length)!)
        }
    }
    
    @IBAction func pausePressed(sender: AnyObject) {
        playButton.enabled = true
        pauseButton.enabled = false
        stopButton.enabled = true
        
        // save the date when the pausing began and stop the update timer
        self.pauseClickedTime = NSDate()
        self.updateRecordTimeTimer?.invalidate()
        self.updateRecordTimeTimer = nil
        // save the current action where we paused the playback to resume from this position later on
        self.currentScript?.pause()
    }
    
    // format an interval to a human readable string
    func formatTime(time : Double) -> String {
        if(time < 60){
            return NSString(format: "%02d:%02d", Int(time), Int(time * 100) % 100) as String
        }else{
            return NSString(format: "%02d:%02d", Int(time)/60, Int(time) % 60) as String
        }
    }
    
    // callback for the play timer
    func updatePlayTimer() {
        let interval = NSDate().timeIntervalSinceDate((self.playbackStartedTime)!)
        if(interval <= self.currentScript?.length){
            self.elapsedTimeView.text = formatTime(interval)
        }
        
        let startPoint : CGFloat = -1 * linearScrollview.frame.height / 2.0
        let currentPlaybackPoint = Double(startPoint) + (interval * self.scale)
        
        linearScrollview.contentOffset = CGPoint(x:0, y: currentPlaybackPoint)
    }
    
}

