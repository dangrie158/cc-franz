//
//  Playback.swift
//  CC
//
//  Created by Tobias Schneider on 7/26/15.
//  Copyright © 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class Playback: UIViewController, UIGestureRecognizerDelegate {
    
    /*******************************
    * instance methods / variables *
    ********************************/
    var activeRecording : Recording? = nil
    var playbackStartedTime : NSDate? = nil
    var updateRecordTimeTimer:NSTimer? = nil
    var currentRecordingActionIndex = 0
    var pauseClickedTime : NSDate? = nil
    
    /*******************************
    *             outlets          *
    ********************************/
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var elapsedTimeView: FBLCDFontView!
    @IBOutlet weak var totalTimeView: FBLCDFontView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // register gesture recognizer to get view touch events
        let tapOutsideRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTapBehind:"))
        tapOutsideRecognizer.numberOfTapsRequired = 1
        tapOutsideRecognizer.cancelsTouchesInView = false
        tapOutsideRecognizer.delegate = self
        self.view.window?.addGestureRecognizer(tapOutsideRecognizer)
    }
    
    override func viewDidLoad() {
        // update the UI to display current recording's name and set total time
        if(self.activeRecording != nil){
            titleView.text = self.activeRecording!.name
            totalTimeView.text = formatTime((self.activeRecording?.length)!)
        }
        // initially set time to 0
        elapsedTimeView.text = "00:00"

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // play button functionality
    @IBAction func playClicked(sender: AnyObject) {
        // disable the play button to avoid multiple playbacks
        playButton.enabled = false
        pauseButton.enabled = true
        stopButton.enabled = true
        // if we are at the start of a recording
        if(self.currentRecordingActionIndex == 0){
            // save the time when the playback has started
            self.playbackStartedTime = NSDate()
        }
        else{
            // otherwise calculate the time the playback was paused ...
            let timeSincePauseStarted = NSDate().timeIntervalSinceDate((self.pauseClickedTime)!)
            // ... and add it to the starting time, to get the real playback time
            self.playbackStartedTime = self.playbackStartedTime?.dateByAddingTimeInterval(timeSincePauseStarted)
        }
        // start a timer to update the display of the playback time
        self.updateRecordTimeTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("updatePlayTimer"), userInfo: nil, repeats: true)
        // play the recording
        self.activeRecording?.play(on: CameraSlider.getInstance(), actionIndex : self.currentRecordingActionIndex){
            // clean up after the playback has finished
            self.updateRecordTimeTimer?.invalidate()
            self.updateRecordTimeTimer = nil
            self.currentRecordingActionIndex = 0
            self.elapsedTimeView.text = self.formatTime((self.activeRecording?.length)!)
        }

    }
    
    // pause button functionality
    @IBAction func pauseClicked(sender: AnyObject) {
        playButton.enabled = true
        pauseButton.enabled = false
        stopButton.enabled = true
        // save the date when the pausing began and stop the update timer
        self.pauseClickedTime = NSDate()
        self.updateRecordTimeTimer?.invalidate()
        self.updateRecordTimeTimer = nil
        // save the current action where we paused the playback to resume from this position later on
        self.currentRecordingActionIndex = (self.activeRecording?.pause())!
    }
    
    // stop button functionality
    @IBAction func stopClicked(sender: AnyObject) {
        playButton.enabled = true
        pauseButton.enabled = false
        stopButton.enabled = false
        // clean up the values and stop the timer
        self.updateRecordTimeTimer?.invalidate()
        self.updateRecordTimeTimer = nil
        self.activeRecording?.stop()
        // when we stop we also reset the text to 0 
        // (which we do not do when the playback just finished and was not stopped by the user,
        // this way we emphasize the stop action)
        self.elapsedTimeView.text = "00:00"
        self.currentRecordingActionIndex = 0
    }
    
    
    /**************************************
    * UIGestureRecognizerDelegate methods *
    **************************************/
    
    func handleTapBehind(sender : UITapGestureRecognizer){
        if(sender.state == UIGestureRecognizerState.Ended){
            let rootView = self.view.window?.rootViewController?.view
            let location = sender.locationInView(rootView)
            // if touch was performed outside of frame --> dismiss the view
            if(!self.view.pointInside(self.view.convertPoint(location, fromView: rootView), withEvent: nil)){
                // unregister gesture listener otherwise we still get touches after view is dismissed
                self.view.window?.removeGestureRecognizer(sender)
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    // we cannot unregister the gesture lister here, because the windows has already been destroyed
                })
            }
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    // set the recording to play back
    func setRecording(recording : Recording){
        self.activeRecording = recording
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
        if(interval <= self.activeRecording?.length){
            self.elapsedTimeView.text = formatTime(interval)
        }
    }


    
}
