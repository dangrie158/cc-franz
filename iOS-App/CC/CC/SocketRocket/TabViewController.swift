//
//  TabViewController.swift
//  CC
//
//  Created by Daniel Grießhaber on 19/06/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController{
    
    let connectionScreenVC = ConnectionScreen(nibName: "ConnectionScreen", bundle: nil)
        
    override func viewDidLoad() {
        connectionScreenVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        connectionScreenVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.tabBar.tintColor = UIColor(red: 0.392156, green: 0.850980, blue: 0.93725, alpha: 1.0)
        
        CameraSlider.getInstance().onDisconnect { () -> Void in
            self.presentViewController(self.connectionScreenVC, animated: true, completion: nil)
        }
        
        CameraSlider.getInstance().onConnect { (SRWebSocket socket) -> Void in
            self.connectionScreenVC.dismissViewControllerAnimated(true, completion: nil)
        }
        
        CameraSlider.getInstance().startConnecting()
    }
    
    override func viewDidAppear(animated: Bool) {
        // initially present loading screen,
        // since the app is disconnected at start
        self.presentViewController(self.connectionScreenVC, animated: true, completion: nil)
    }
    
}
