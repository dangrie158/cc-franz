//
//  FirstViewController.swift
//  CC
//
//  Created by Tobias Schneider on 4/28/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class LiveController: UIViewController{
    
    /*******************************
    * instance methods / variables *
    ********************************/
    var updateRecordTimeTimer:NSTimer? = nil;
    var currentRecording:Recording? = nil
    
    /*******************************
    *             outlets          *
    ********************************/
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var recordTimeView: FBLCDFontView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recordTimeView.text = "00:00"
        
        recordButton.setStartListener(){
            
            //create a standart name for the recording
            let standartRecordingTitle = "Recording from " + NSDate().description
            self.currentRecording = Recording(withName: standartRecordingTitle)
            do{
                try CameraSlider.getInstance().startRecording(on: self.currentRecording!)
            }catch{
                print("Tried to record while already recoring, ignoring")
            }
            
            self.updateRecordTimeTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("updateRecordTimer"), userInfo: nil, repeats: true)
            
            //reset the time
            self.recordTimeView.text = "00:00"
        }
        
        recordButton.setStopListener(){
            let recording = CameraSlider.getInstance().stopRecording()
            self.updateRecordTimeTimer?.invalidate()
            self.updateRecordTimeTimer = nil
        
            self.askUserForNameAndSave(recording);
            
            //reset the time display
            self.recordTimeView.text = "00:00"
        }
        
    }
    
    func updateRecordTimer() {
        let interval = NSDate().timeIntervalSinceDate((self.currentRecording?.startTime)!)
        print("test")
        if(interval < 60){
            self.recordTimeView.text = NSString(format: "%02d:%02d", Int(interval), Int(interval * 100) % 100) as String
        }else{
            self.recordTimeView.text = NSString(format: "%02d:%02d", Int(interval)/60, Int(interval) % 60) as String
        }
    }
    
    func askUserForNameAndSave(recording:Recording){
        //the textfield where the user can enter
        //a new name for the recording
        var newNameField:UITextField? = nil;
        
        //updates the name of the recording and saves the recording
        //this is the handler for the save button
        func saveRecording(action _: UIAlertAction!) {
            if(!newNameField!.text!.isEmpty){
                recording.name = (newNameField?.text)!
            }
            
            recording.save();
        }
        
        let alert = UIAlertController(title: "Save As", message: "Please enter the recordings name", preferredStyle: UIAlertControllerStyle.Alert)
        
        //add a cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        //add a save button
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: saveRecording))
        //add a text field here the user can enter a new name
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = recording.name
            //save the new created textfield so we can get access
            //to the entered text later
            newNameField = textField
        })
            
        //show the view controller
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func movementSpeedRelease(sender: HorizontalSlider) {
        let direction:CameraSlider.Direction = .LEFT
        CameraSlider.getInstance().move(direction, withSpeed: 0.0)
    }
    
    @IBAction func moventSpeedReleaseOutside(sender: HorizontalSlider) {
        self.movementSpeedRelease(sender)
    }
    
    
    
    @IBAction func movementSpeedChanged(sender: HorizontalSlider) {
        let direction : CameraSlider.Direction = sender.value >= 0 ? .RIGHT : .LEFT
        let speed = sender.value >= 0 ? sender.value : (sender.value * (-1))
        CameraSlider.getInstance().move(direction, withSpeed: speed)
    }
    @IBAction func rotationSpeedChanged(sender: HorizontalSlider) {
        let direction : CameraSlider.Direction = sender.value >= 0 ? .CW : .CCW
        let speed = sender.value >= 0 ? sender.value : (sender.value * (-1))
        CameraSlider.getInstance().rotate(direction, withSpeed: speed)
    }
    
    
    
}