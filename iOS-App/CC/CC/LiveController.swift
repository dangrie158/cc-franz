//
//  FirstViewController.swift
//  CC
//
//  Created by Tobias Schneider on 4/28/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class LiveController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recording = Recording();
//        for index in 1...5000{
//            recording.addAction(Recording.Action(message: "hallo dani " + String(index), timeToNextMessage: 0.001 * Double(index)))
//        }
//        
//        recording.play(on: CameraSlider.getInstance())
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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