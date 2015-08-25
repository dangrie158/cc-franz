//
//  Script.swift
//  CC
//
//  Created by Tobias Schneider on 8/17/15.
//  Copyright © 2015 Tobias Schneider. All rights reserved.
//

import CoreData

class ScriptAction{
    var start: Double
    var length: Double
    var direction: CameraSlider.Direction
    var speed: Float
    var currentlyPlaying: Bool
    var stop: Double{
        get{
            return start + length
        }
    }

    init(start: Double, length: Double, direction: CameraSlider.Direction, speed: Float){
        self.start = start
        self.length = length
        self.direction = direction
        self.speed = speed
        self.currentlyPlaying = false
    }
}
class Script : NSObject{
    enum State{
        case PLAYING
        case PAUSED
        case STOPPED
    }
    
    var name: String = ""
    var length : Double{
        get{
            var totalLength = 0.0
            for action in self.linearActions + self.angularActions{
                if action.stop > totalLength{
                    totalLength = action.stop
                }
            }
            return totalLength
        }
    }
    var linearActions = [ScriptAction]()
    var angularActions = [ScriptAction]()
    var lastLinearAction : ScriptAction? = nil
    var lastAngularAction : ScriptAction? = nil
    var currentPlaybackState : State = .STOPPED
    var startTime : NSDate? = nil
    var pauseTime : NSDate? = nil
    var timer : NSTimer? = nil
    var receiver : CameraSlider? = nil
    var onFinish : (() -> ())? = nil
    
    /***********************
    *** Helper Functions ***
    ***********************/
    
    /***********************
    **** Main Functions ****
    ***********************/
    
    init(withName name: String){
        self.name = name;
    }
    
    /**
    * add a precomposed action element to the recoding
    */
    func addAction(action: ScriptAction){
        if action.direction == .LEFT || action.direction == .RIGHT {
            linearActions.append(action)
        }
        else if action.direction == .CW || action.direction == .CCW {
            angularActions.append(action)
        }
    }
    
    
    /**
    * play script via camera slider
    */
    func play(on receiver: CameraSlider, onFinish : () -> ()){
        // offset the playback time by the time we paused
        if self.currentPlaybackState == .PAUSED{
            let pausedTime = NSDate().timeIntervalSinceDate(self.pauseTime!)
            self.startTime = self.startTime?.dateByAddingTimeInterval(pausedTime)
        }
        else{
            self.startTime = NSDate()
        }
        // start the timer to govern the scripts
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("updatePlaybackScriptActions"), userInfo: nil, repeats: true)
        self.currentPlaybackState = .PLAYING
        self.receiver = receiver
        self.onFinish = onFinish

    }
    
    /**
    * pause script via camera slider
    */
    func pause(){
        self.stop()
        self.currentPlaybackState = .PAUSED
        // save the date when paused
        self.pauseTime = NSDate()
    }
    
    /**
    * stop script via camera slider
    */
    func stop(){
        self.timer?.invalidate()
        self.timer = nil
        self.currentPlaybackState = .STOPPED
        // stop all slider movement
        self.receiver?.stopAll()
        // clear all current playing flags
        for action in self.linearActions + self.angularActions{
            action.currentlyPlaying = false
        }
    }
    
    func updatePlaybackScriptActions(){
        let playingTime = NSDate().timeIntervalSinceDate(self.startTime!)
        var angularAction : ScriptAction? = nil
        var linearAction : ScriptAction? = nil
        
        for action in self.angularActions{
            // check if we are currently in this action
            if action.start <= playingTime && action.stop > playingTime && action.currentlyPlaying == false {
                // save this action as the action to be sent
                angularAction = action
            }
            // check if we left a script action block that is not stopped yet and if we do not have a new action
            else if action.stop < playingTime && angularAction == nil && action.currentlyPlaying == true {
                // create a new action to stop all angular movement
                angularAction = ScriptAction(start: 0, length: 0, direction: .CW, speed: 0)
            }
        }
        for action in self.linearActions {
            // check if we are currently in this action
            if action.start <= playingTime && action.stop > playingTime && action.currentlyPlaying == false {
                // save this action as the action to be sent
                linearAction = action
            }
                // check if we left a script action block that is not stopped yet and if we do not have a new action
            else if action.stop < playingTime && linearAction == nil && action.currentlyPlaying == true {
                // create a new action to stop all linear movement
                linearAction = ScriptAction(start: 0, length: 0, direction: .LEFT, speed: 0)
            }
        }
        // compose messages and send them
        if angularAction != nil {
            if lastAngularAction != nil{
                lastAngularAction?.currentlyPlaying = false
            }
            
            angularAction?.currentlyPlaying = !(angularAction!.currentlyPlaying)
            self.receiver!.rotate(angularAction!.direction, withSpeed: angularAction!.speed, forceSending: true)
            //save the last action to later reset the playing state
            lastAngularAction = angularAction
        }
        
        if linearAction != nil {
            if lastLinearAction != nil{
                lastLinearAction?.currentlyPlaying = false;
            }
            
            linearAction?.currentlyPlaying = !(linearAction!.currentlyPlaying)
            self.receiver!.move(linearAction!.direction, withSpeed: linearAction!.speed, forceSending: true)
            //save the last action to later reset the playing state
            lastLinearAction = linearAction
        }
        
        if playingTime > self.length {
            self.timer?.invalidate();
            self.timer = nil
            if self.onFinish != nil {
                self.onFinish!()
            }
        }
    }
    
    /**
    * save the script to the store and return the managed object of the script
    */
    
    func save(managedContext : NSManagedObjectContext!) -> NSManagedObject{
        
        let scriptEntity =  NSEntityDescription.entityForName("Script",
            inManagedObjectContext:
            managedContext)
        
        let actionEntity = NSEntityDescription.entityForName("ScriptAction", inManagedObjectContext: managedContext)
        // create new managedObject to save the script
        let script = NSManagedObject(entity: scriptEntity!,
            insertIntoManagedObjectContext:managedContext)
        // set the name of the script
        script.setValue(self.name, forKey: "name")
        var scriptActionSet = script.valueForKeyPath("actions") as! NSOrderedSet
        // get mutable copy to modify
        let scriptActionItems = scriptActionSet.mutableCopy() as! NSMutableOrderedSet
        // fill in the action entities
        for action in self.linearActions + self.angularActions {
            let managedAction = NSManagedObject(entity: actionEntity!, insertIntoManagedObjectContext: managedContext)
            managedAction.setValue(action.start, forKey: "start")
            managedAction.setValue(action.length, forKey: "length")
            managedAction.setValue(action.speed, forKey: "speed")
            managedAction.setValue(action.direction.hashValue, forKey: "direction")
            
            scriptActionItems.addObject(managedAction)
        }
        // set the relationship between the script and the scriptActions
        scriptActionSet = scriptActionItems.copy() as! NSOrderedSet
        script.setValue(scriptActionSet, forKeyPath: "actions")
        // save the new state of the managedContext
        do{
            try managedContext.save()
        }
        catch{
            print("Could not save")
        }
        
        return script
    }
    
    /**
    * create a new script from a managedObject
    */
    static func getFromManagedObject(managedObject : NSManagedObject) -> Script{
        let name = managedObject.valueForKey("name") as! String
        let script = Script(withName: name)
        let actionSet = managedObject.valueForKeyPath("actions") as! NSOrderedSet
        
        // fill script with the actions
        for action in actionSet{
            let start = action.valueForKey("start") as! Double
            let length = action.valueForKey("length") as! Double
            let speed = action.valueForKey("speed") as! Float
            var direction : CameraSlider.Direction? = nil
            switch action.valueForKey("direction") as! Int{
            case CameraSlider.Direction.LEFT.hashValue :
                direction = .LEFT
            case CameraSlider.Direction.RIGHT.hashValue :
                direction = .RIGHT
            case CameraSlider.Direction.CW.hashValue :
                direction = .CW
            case CameraSlider.Direction.CCW.hashValue :
                direction = .CCW
            default :
                direction = .LEFT
            }

            let scriptAction = ScriptAction(start: start, length: length, direction: direction!, speed: speed)
            script.addAction(scriptAction)
        }
        
        return script
    }
}