//
//  SecondViewController.swift
//  CC
//
//  Created by Tobias Schneider on 4/28/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import CoreData

class ScriptController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate{
    
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
    var lastRecognizerScale = 1.0
    var startYContentOffset = 0.0
    var managedContext : NSManagedObjectContext? = nil
    var scripts = [NSManagedObject]()
    var currentScriptChanged = false
    
    /*******************************
    *             outlets          *
    ********************************/
    @IBOutlet weak var angularScrollview: UIScrollView!
    @IBOutlet weak var linearScrollview: UIScrollView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var elapsedTimeView: FBLCDFontView!
    @IBOutlet weak var scriptsListView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scriptsListView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
    }
    
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
        
        //observe the content height to syncronize the scrollviews
        linearTimelineView!.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
        angularTimelineView!.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)

        linearScrollview.delegate = self
        angularScrollview.delegate = self
        linearTimelineView?.onLongPressItem(handleScriptActionLongpress)
        angularTimelineView?.onLongPressItem(handleScriptActionLongpress)
        
        

        self.elapsedTimeView.text = "00:00"

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // initialized globally
        self.managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"Script")
        fetchRequest.relationshipKeyPathsForPrefetching = ["actions"]
        var fetchedResults : [NSManagedObject]? = nil
        
        do{
            try fetchedResults = self.managedContext!.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        }
        catch{
            print("Failed to load scripts from database.")
        }
        
        self.scripts = fetchedResults!
        if self.currentScript == nil {
            newScript(false)
        }
        else {
            updateCurrentScript(self.currentScript!)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // update the UI
    func updateCurrentScript(script: Script){
        self.currentScriptChanged = false
        self.currentScript = script
        linearTimelineView?.replaceScriptActionsInView(currentScript!.linearActions)
        angularTimelineView?.replaceScriptActionsInView(currentScript!.angularActions)
    }

    // hide the status bar for the whole view controller
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        linearTimelineView?.removeGestureRecognizer(linearPinchGestureRecognizer!)
        angularTimelineView?.removeGestureRecognizer(angularPinchGestureRecognizer!)
    }
    
    /*******************************
    *      scroll view protocol    *
    ********************************/
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
        if recognizer.state == UIGestureRecognizerState.Ended {
            self.lastRecognizerScale = 1.0
            return
        }
        
        //temporarly remove the observers since we already know we are changing them
        linearTimelineView!.removeObserver(self, forKeyPath: "frame")
        angularTimelineView!.removeObserver(self, forKeyPath: "frame")
        
        if recognizer.state == UIGestureRecognizerState.Began {
            // we do not distinct between linear and angular scroll view since we are
            // only interested in the y position
            self.startYContentOffset = Double(linearScrollview.contentOffset.y)
        }
        
        self.scale = self.scale + (Double(recognizer.scale) - self.lastRecognizerScale)
        
        self.scale = min(self.scale, 3)
        self.scale = max(self.scale, 0.5)
        
        linearTimelineView!.setScale(Double(self.scale))
        angularTimelineView!.setScale(Double(self.scale))
        linearTimelineView?.setNeedsLayout()
        linearTimelineView?.setNeedsDisplay()
        angularTimelineView?.setNeedsLayout()
        angularTimelineView?.setNeedsDisplay()
        
        //syncronize the two scroll view heights
        let linearHeight = linearTimelineView?.bounds.maxY
        print("linearHeight: \(linearHeight)")
        let angularHeight = angularTimelineView?.bounds.maxY
        print("angularHeight: \(angularHeight)")
        if linearHeight > angularHeight{
            angularTimelineView!.frame.size.height = linearHeight!
            angularScrollview!.contentSize.height = linearHeight!
            print("angular content height: \(angularScrollview.contentSize.height)")
        }
        else{
            linearTimelineView!.frame.size.height = angularHeight!
            linearScrollview!.contentSize.height = angularHeight!
            print("linear content height: \(angularScrollview.contentSize.height)")
        }
        
        self.lastRecognizerScale = Double(recognizer.scale)
        linearTimelineView!.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
        angularTimelineView!.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        //temporarly remove the observers to prevent infinite loop
        linearTimelineView!.removeObserver(self, forKeyPath: "frame")
        angularTimelineView!.removeObserver(self, forKeyPath: "frame")
        
        if (keyPath == "frame")
        {
            //contentSize of either scrollview changed
            if object === self.linearTimelineView{
                self.angularTimelineView?.frame.size.height = self.linearTimelineView!.bounds.size.height
            }else if object === self.angularTimelineView{
                self.linearTimelineView?.frame.size.height = self.angularTimelineView!.bounds.size.height
            }
        }
        
        linearTimelineView!.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
        linearTimelineView?.setNeedsDisplay()
        linearTimelineView?.setNeedsLayout()
        angularTimelineView!.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
        angularTimelineView?.setNeedsDisplay()
        angularTimelineView?.setNeedsLayout()
    }
    
    func handleScriptActionLongpress(item: TimelineItemView){
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Edit Script Action", message: "", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add first option action
        let editAction: UIAlertAction = UIAlertAction(title: "Edit", style: .Default) { action -> Void in
            print("edit")
            
        }
        actionSheetController.addAction(editAction)
        
        //Create and add a second option action
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .Destructive) { action -> Void in
            for var i = 0; i < self.currentScript!.linearActions.count; i += 1 {
                if self.currentScript!.linearActions[i] === item.scriptAction {
                    self.currentScript!.linearActions.removeAtIndex(i)
                }
            }
            
            for var i = 0; i < self.currentScript!.angularActions.count; i += 1 {
                if self.currentScript!.angularActions[i] === item.scriptAction {
                    self.currentScript!.angularActions.removeAtIndex(i)
                }
            }
            
            self.updateCurrentScript(self.currentScript!)
        }
        actionSheetController.addAction(deleteAction)
        
        //We need to provide a popover sourceView when using it on iPad
        actionSheetController.popoverPresentationController?.sourceView = item
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)

    }
    
    /*******************************
    *          view actions        *
    ********************************/
    
    func showAddActionViewController(forAxis type: CameraSlider.Axis){
        // create new playback view controller
        let AddActionVC = AddScriptAction(nibName: "AddScriptAction", bundle: nil)
        // show the view controller
        AddActionVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        AddActionVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        AddActionVC.setAxis(type)
        AddActionVC.setStart((self.currentScript?.length)!)
        AddActionVC.onComplete { (action: ScriptAction) -> () in
            self.currentScript?.addAction(action)
            self.updateCurrentScript(self.currentScript!)
            self.currentScriptChanged = true
        }
        self.presentViewController(AddActionVC, animated: true, completion: nil)
    }
    
    @IBAction func addLinearAction(sender: AnyObject) {
        showAddActionViewController(forAxis: .MOVEMENT)
    }
    
    @IBAction func addAngularAction(sender: AnyObject) {
        showAddActionViewController(forAxis: .ROTATION)
    }
    
    
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
    // and scoll position update
    func updatePlayTimer() {
        let interval = NSDate().timeIntervalSinceDate((self.playbackStartedTime)!)
        if(interval <= self.currentScript?.length){
            self.elapsedTimeView.text = formatTime(interval)
        }
        
        let startPoint : CGFloat = -1 * linearScrollview.frame.height / 2.0
        let currentPlaybackPoint = Double(startPoint) + (interval * self.scale)
        
        linearScrollview.setContentOffset(CGPoint(x:0, y: currentPlaybackPoint), animated: false);
    }
    
    @IBAction func newButtonPressed(sender: AnyObject) {
        newScript()
    }
    
    func newScript(askToSave: Bool = true) {
        func createNewScript(action _: UIAlertAction?){
            self.currentScript = Script(withName: NSDate().description)
            updateCurrentScript(currentScript!)
        }
        
        if askToSave && currentScriptChanged {
            let alert = UIAlertController(title: "New Script", message: "Do you want to create a new script?", preferredStyle: UIAlertControllerStyle.Alert)
        
            //add a cancel button
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            //add a new script button
            alert.addAction(UIAlertAction(title: "New Script", style: UIAlertActionStyle.Default, handler: createNewScript))
            
            //show the view controller
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else{
            createNewScript(action: nil)
        }
        
    }
    
    
    @IBAction func saveScript(sender: AnyObject) {
        askUserForNameAndSave(self.currentScript!)
    }
    
    // save script
    func askUserForNameAndSave(script:Script){
        //the textfield where the user can enter
        //a new name for the script
        var newNameField:UITextField? = nil;
        
        //updates the name of the script and saves the script
        //this is the handler for the save button
        func saveScript(action _: UIAlertAction!) {
            if(!newNameField!.text!.isEmpty){
                script.name = (newNameField?.text)!
            }
            
            let managedObject = script.save(self.managedContext)
            self.scripts.append(managedObject)
            self.scriptsListView.reloadData()
        }
        
        let alert = UIAlertController(title: "Save As", message: "Please enter the recordings name", preferredStyle: UIAlertControllerStyle.Alert)
        
        //add a cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        //add a save button
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: saveScript))
        //add a text field here the user can enter a new name
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = script.name
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
        return scripts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell?
        let script = scripts[indexPath.row]
        cell?.backgroundColor = UIColor(red: 0.1529411, green: 0.1568627, blue: 0.1333333, alpha: 1.0)
        cell?.textLabel?.textColor = UIColor.lightGrayColor()
        cell?.preservesSuperviewLayoutMargins = false
        cell?.layoutMargins = UIEdgeInsetsZero
        cell?.separatorInset = UIEdgeInsetsZero
        cell!.textLabel!.text = script.valueForKey("name") as? String
        
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
            self.managedContext!.deleteObject(scripts[indexPath.row] as NSManagedObject)
            do{
                try self.managedContext!.save()
            }
            catch{
                print("Could not save")
            }
            scripts.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // get the recording object from the managed objects
        let selectedScript = scripts[indexPath.row]
        let script = Script.getFromManagedObject(selectedScript)
        updateCurrentScript(script)
    }


    
}

