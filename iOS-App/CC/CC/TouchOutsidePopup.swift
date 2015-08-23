//
//  TouchOutsidePopup.swift
//  CC
//
//  Created by Daniel Grießhaber on 23/08/15.
//  Copyright © 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class TouchOutsidePopup: UIViewController, UIGestureRecognizerDelegate{
    
    var tapOutsideRecognizer : UITapGestureRecognizer? = nil
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // register gesture recognizer to get view touch events
        tapOutsideRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTapBehind:"))
        tapOutsideRecognizer!.numberOfTapsRequired = 1
        tapOutsideRecognizer!.cancelsTouchesInView = false
        tapOutsideRecognizer!.delegate = self
        self.view.window?.addGestureRecognizer(tapOutsideRecognizer!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        //remove the gesture recognizer or else we will get gestures when the vew is already nil
        self.view.window?.removeGestureRecognizer(self.tapOutsideRecognizer!)
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