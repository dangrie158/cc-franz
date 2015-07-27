//
//  FirstViewController.swift
//  CC
//
//  Created by Tobias Schneider on 4/28/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit
import CoreData

class LiveController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    /*******************************
    * instance methods / variables *
    ********************************/
    var updateRecordTimeTimer:NSTimer? = nil;
    var currentRecording:Recording? = nil
    var recordings = [NSManagedObject]()
    var managedContext : NSManagedObjectContext? = nil
    
    /*******************************
    *             outlets          *
    ********************************/
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var recordTimeView: FBLCDFontView!
    @IBOutlet weak var recordingsListView: UITableView!
    @IBOutlet weak var angularPositionView: FBLCDFontView!
    @IBOutlet weak var linearPositionView: FBLCDFontView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingsListView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
        
        self.recordTimeView.text = "00:00"
        self.angularPositionView.text = "360"
        self.linearPositionView.text = "000"
        
        recordButton.setStartListener(){
            
            //create a standart name for the recording
            let standartRecordingTitle = "Recording from " + NSDate().description
            self.currentRecording = Recording(withName: standartRecordingTitle)
            do{
                try CameraSlider.getInstance().startRecording(on: self.currentRecording!)
            }catch{
                print("Tried to record while already recoring, ignoring")
            }
            
            self.updateRecordTimeTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("updateRecordTimer"), userInfo: nil, repeats: true)
            
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // initialized globally
        self.managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"Recording")
        fetchRequest.relationshipKeyPathsForPrefetching = ["actions"]
        var fetchedResults : [NSManagedObject]? = nil
        
        do{
            try fetchedResults = self.managedContext!.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        }
        catch{
            print("Failed to load recordings from database.")
        }
        
        self.recordings = fetchedResults!
    }

    
    func updateRecordTimer() {
        let interval = NSDate().timeIntervalSinceDate((self.currentRecording?.startTime)!)
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
            
            let managedObject = recording.save(self.managedContext)
            self.recordings.append(managedObject)
            self.recordingsListView.reloadData()
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
    
    /*******************************
    *       table view protocol    *
    ********************************/

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return recordings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell?
            let recording = recordings[indexPath.row]
            cell?.backgroundColor = UIColor(red: 0.1529411, green: 0.1568627, blue: 0.1333333, alpha: 1.0)
            cell?.textLabel?.textColor = UIColor.lightGrayColor()
            cell?.preservesSuperviewLayoutMargins = false
            cell?.layoutMargins = UIEdgeInsetsZero
            cell?.separatorInset = UIEdgeInsetsZero
            cell!.textLabel!.text = recording.valueForKey("name") as? String
            
            return cell!
    }
    
    /**
    * set the tableView as editable
    */
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    /**
    * delete table rows
    */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // remove the deleted item from the model
            self.managedContext!.deleteObject(recordings[indexPath.row] as NSManagedObject)
            do{
                try self.managedContext!.save()
            }
            catch{
                print("Could not save")
            }
            recordings.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)

        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // get the recording object from the managed objects
        let selectedRecording = recordings[indexPath.row]
        let recording = Recording.getFromManagedObject(selectedRecording)
        // create new playback view controller
        let playbackScreenVC = Playback(nibName: "Playback", bundle: nil)
        // show the view controller
        playbackScreenVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        playbackScreenVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        playbackScreenVC.setRecording(recording)
        self.presentViewController(playbackScreenVC, animated: true, completion: nil)
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
    
    // hide the status bar for the whole view controller
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}