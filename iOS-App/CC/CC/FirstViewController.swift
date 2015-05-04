//
//  FirstViewController.swift
//  CC
//
//  Created by Tobias Schneider on 4/28/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, SRWebSocketDelegate{

    var timer:NSTimer? = NSTimer()
    var counter:Int = 0
    var socketio:SRWebSocket?
    
    @IBOutlet weak var timeElappsedTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketConnect()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendMessage(){
        counter += 1
        timeElappsedTextfield.text = String(counter)
    }

    @IBAction func moveLeftStart(sender: AnyObject) {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("sendMessage"), userInfo: nil, repeats: true)
    }
    
    @IBAction func moveLeftStop(sender: AnyObject) {
        if let z = timer?.valid{
            timer!.invalidate()
        }
        timer = nil
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        println("Message: \(message)")
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        socketio?.send("Hallo WebSocket")
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {

    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        
    }
    
    func socketConnect() {
        socketio = SRWebSocket(URL: NSURL(scheme: "ws", host: "85.214.213.194:8080", path: "/"))
        socketio!.delegate = self
        socketio!.open()
        
        
    }
    


}