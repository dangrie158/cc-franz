//
//  Recording.swift
//  CC
//
//  Created by Tobias Schneider on 6/20/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import CoreData

class Action{
    private var message: String
    private var timeToNextMessage: Double
    
    init(message: String, timeToNextMessage: Double){
        self.message = message
        self.timeToNextMessage = timeToNextMessage
    }
}
class Recording{
    enum State{
        case PLAYING
        case PAUSED
        case STOPPED
    }
    
    var name: String = ""
    var length : Double{
        get{
            var totalLength = 0.0
            for action in self.actions{
                totalLength += action.timeToNextMessage
            }
            return totalLength
        }
    }
    private var actions = [Action]()
    private var lastActionTime = NSDate()
    private var currentActionIndex = 0
    private var currentPlaybackState : State = .STOPPED
    let startTime = NSDate()
    
    /***********************
    *** Helper Functions ***
    ***********************/
    private func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    /***********************
    **** Main Functions ****
    ***********************/
    
    init(withName name: String){
        self.name = name;
    }
    
    /**
     * add a precomposed action element to the recoding
     */
    func addAction(action: Action){
        //also set the time since the last message here
        //so we can use both addAction function interchangeably
        lastActionTime = NSDate()
        actions.append(action)
    }
    
    /**
     * add an Action to the recording and automatically set
     * the time interval since the last action was added
     */
    func addAction(withStringAction action: String){
        //calculate the time since the last action occurred
        let timeOfAction = NSDate()
        let timeSinceLastAction = timeOfAction.timeIntervalSinceDate(lastActionTime)
        let newAction = Action(message: action, timeToNextMessage: timeSinceLastAction)
        
        self.addAction(newAction)
    }
    
    /**
     * play recording via camera slider
     */
    func play(on receiver: CameraSlider, actionIndex: Int = 0, onFinish : () -> ()){
        self.currentPlaybackState = .PLAYING
        // if we reach the last action call the callback and stop processing
        if(actionIndex >= actions.count){
            onFinish()
            return
        }
        // get the current action from the actions array
        let currentAction = actions[actionIndex]
        // send raw message to camera slider to perform said action
        receiver.sendRawMessage(currentAction.message)
        // wait until the next action happened while recording
        delay(currentAction.timeToNextMessage){
            // recursively call fuction
            if(self.currentPlaybackState == .PLAYING){
                self.currentActionIndex = actionIndex+1
                self.play(on: receiver, actionIndex: actionIndex+1, onFinish: onFinish)
            }
        }
    }
    
    /**
    * pause recording via camera slider
    */
    func pause() -> Int{
        self.currentPlaybackState = .PAUSED
        return currentActionIndex
    }
    
    /**
    * stop recording via camera slider
    */
    func stop(){
        self.currentPlaybackState = .STOPPED
        currentActionIndex = 0
    }
    
    /**
     * save the recording to the store and return the managed object of the recording
     */
    
    func save(managedContext : NSManagedObjectContext!) -> NSManagedObject{

        let recordingEntity =  NSEntityDescription.entityForName("Recording",
            inManagedObjectContext:
            managedContext)
        
        let actionEntity = NSEntityDescription.entityForName("Action", inManagedObjectContext: managedContext)
        // create new managedObject to save the recording
        let recording = NSManagedObject(entity: recordingEntity!,
            insertIntoManagedObjectContext:managedContext)
        // set the name of the recording
        recording.setValue(self.name, forKey: "name")
        var actionSet = recording.valueForKeyPath("actions") as! NSOrderedSet
        // get mutable copy to modify
        let actionItems = actionSet.mutableCopy() as! NSMutableOrderedSet
        // fill in the action entities
        for action in self.actions{
            let managedAction = NSManagedObject(entity: actionEntity!, insertIntoManagedObjectContext: managedContext)
            managedAction.setValue(action.message, forKey: "message")
            managedAction.setValue(action.timeToNextMessage, forKey: "timeToNextAction")
            
            actionItems.addObject(managedAction)
        }
        // set the relationship between the recording and the actions
        actionSet = actionItems.copy() as! NSOrderedSet
        recording.setValue(actionSet, forKeyPath: "actions")
        // save the new state of the managedContext
        do{
            try managedContext.save()
        }
        catch{
            print("Could not save")
        }
        
        return recording
    }
    
    /**
    * create a new recording from a managedObject
    */
    static func getFromManagedObject(managedObject : NSManagedObject) -> Recording{
        let name = managedObject.valueForKey("name") as! String
        let recording = Recording(withName: name)
        let actionSet = managedObject.valueForKeyPath("actions") as! NSOrderedSet
        
        // fill recording with the actions
        for action in actionSet{
            let message = action.valueForKey("message") as! String
            let timeToNextAction = action.valueForKey("timeToNextAction") as! Double
            let action = Action(message: message, timeToNextMessage: timeToNextAction)
            recording.addAction(action)
        }
        
        return recording
    }

}
