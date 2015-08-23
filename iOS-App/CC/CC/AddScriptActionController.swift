//
//  AddScriptAction.swift
//  CC
//
//  Created by Tobias Schneider on 8/23/15.
//  Copyright © 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class AddScriptAction: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var direction: UISegmentedControl!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var speedTitle: UILabel!
    
    private var axis : CameraSlider.Axis?
    private var onCompleteCallback : ((ScriptAction)->())?
    private var duration = 0
    private var start = 0.0
    private var tapOutsideRecognizer : UITapGestureRecognizer? = nil
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // register gesture recognizer to get view touch events
        tapOutsideRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTapBehind:"))
        tapOutsideRecognizer!.numberOfTapsRequired = 1
        tapOutsideRecognizer!.cancelsTouchesInView = false
        tapOutsideRecognizer!.delegate = self
        self.view.window?.addGestureRecognizer(tapOutsideRecognizer!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // change popup title according to action type
        if self.axis == .MOVEMENT {
            self.popupTitle.text = "Add Linear Action"
            self.direction.setTitle("Left", forSegmentAtIndex: 0)
            self.direction.setTitle("Right", forSegmentAtIndex: 1)
            self.speedTitle.text = "Speed [mm/s]"
        }
        else if self.axis == .ROTATION {
            self.popupTitle.text = "Add Angular Action"
            self.direction.setTitle("CCW", forSegmentAtIndex: 0)
            self.direction.setTitle("CW", forSegmentAtIndex: 1)
            self.speedTitle.text = "Speed [°/s]"
        }
    }
    
    func setAxis(axis: CameraSlider.Axis){
       self.axis = axis
    }
    
    func setStart(start: Double){
        self.start = start
    }
    
    func onComplete(action: (ScriptAction)->()){
        self.onCompleteCallback = action
    }
    
    func addDuration(duration: Int){
        if self.duration + duration >= 0 {
            self.duration += duration
            durationLabel.text = self.duration.description
        }
    }
    
    
    /**************************************
    *               UI Actions            *
    **************************************/
    
    @IBAction func saveAndClose(sender: AnyObject) {
        var ccDirection : CameraSlider.Direction? = nil
        
        if self.axis == .MOVEMENT {
            if self.direction.selectedSegmentIndex == 0 {
                ccDirection = .LEFT
            }
            else if self.direction.selectedSegmentIndex == 1 {
                ccDirection = .RIGHT
            }
        }
        
        else if self.axis == .ROTATION {
            if self.direction.selectedSegmentIndex == 0 {
                ccDirection = .CCW
            }
            else if self.direction.selectedSegmentIndex == 1 {
                ccDirection = .CW
            }
        }
        
        if self.onCompleteCallback != nil{
            let action = ScriptAction(start: self.start, length: Double(self.duration), direction: ccDirection!, speed: self.speedSlider.value)
            self.onCompleteCallback!(action)
        }
        
        // unregister gesture listener otherwise we still get touches after view is dismissed
        self.view.window?.removeGestureRecognizer(self.tapOutsideRecognizer!)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            // we cannot unregister the gesture lister here, because the windows has already been destroyed
        })
    }
    @IBAction func durationMinus100(sender: AnyObject) {
        addDuration(-100)
    }
    @IBAction func durationMinus10(sender: AnyObject) {
        addDuration(-10)
    }
    @IBAction func durationMinus1(sender: AnyObject) {
        addDuration(-1)
    }
    @IBAction func durationPlus1(sender: AnyObject) {
        addDuration(1)
    }
    @IBAction func durationPlus10(sender: AnyObject) {
        addDuration(10)
    }
    @IBAction func durationPlus100(sender: AnyObject) {
        addDuration(100)
    }
    @IBAction func speedChanged(sender: AnyObject) {
        var speedText = ""
        if self.axis == .MOVEMENT {
            speedText = calculateLinearSpeed(sender.value)
        }
        else if self.axis == .ROTATION {
            speedText = calculateAngularSpeed(sender.value)
        }
        
        speedLabel.text = speedText
    }
    
    
    /*******************************
    *       speed references       *
    ********************************/
    func calculateLinearSpeed(speed: Float) -> String{
        let actualSpeed = speed * 40
        let speedText = NSString(format: "%02d", Int(actualSpeed)).description
        
        return speedText
    }
    
    func calculateAngularSpeed(speed: Float) -> String{
        let actualSpeed = speed * 250
        let speedText = NSString(format: "%03d", Int(actualSpeed)).description
        
        return speedText
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


}
