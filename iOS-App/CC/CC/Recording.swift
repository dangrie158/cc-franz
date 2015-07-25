//
//  Recording.swift
//  CC
//
//  Created by Tobias Schneider on 6/20/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import CoreData

class Recording : NSManagedObject{
    

    class Action{
        private var message: String
        private var timeToNextMessage: Double
        
        init(message: String, timeToNextMessage: Double){
            self.message = message
            self.timeToNextMessage = timeToNextMessage
        }
    }
    
    var name: String = ""
    private var actions = [Action]()
    private var lastActionTime = NSDate()
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
    
    init(){
        super(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        self.name = (self.valueForKey("name") as? String)!
    }
    
    init(withName name: String){
        super.init()
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
     * the sime interval since the last action was added
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
    func play(on receiver: CameraSlider, actionIndex: Int = 0){
        if(actionIndex >= actions.count){
            return
        }
        // get the current action from the actions array
        let currentAction = actions[actionIndex]
        // send raw message to camera slider to perform said action
        receiver.sendRawMessage(currentAction.message)
        // wait until the next action happened while recording
        delay(currentAction.timeToNextMessage){
            // recursively call fuction
            self.play(on: receiver, actionIndex: actionIndex+1)
        }
    }
    
    /**
     * save the recording to the store
     */
    func save(){
        print(self.name)
    }

}
