//
//  Recording.swift
//  CC
//
//  Created by Tobias Schneider on 6/20/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

class Recording{

    class Action{
        private var message: String
        private var timeToNextMessage: Double
        
        init(message: String, timeToNextMessage: Double){
            self.message = message
            self.timeToNextMessage = timeToNextMessage
        }
    }
    
    var name: String = ""
    var actions = [Action]()
    
    /***********************
    *** Helper Functions ***
    ***********************/
    func delay(delay:Double, closure:()->()) {
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
    func addAction(action: Action){
        actions.append(action)
    }
    // play recording via camera slider
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

}
