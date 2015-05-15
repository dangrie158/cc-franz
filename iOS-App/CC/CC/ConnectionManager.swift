//
//  ConnectionManager.swift
//  CC
//
//  Created by Daniel Grießhaber on 11/05/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class CameraSlider: NSObject, SRWebSocketDelegate {
    enum State{
        case DISCONNECTED
        case CONNECTING
        case CONNECTED
    }
    
    enum Direction{
        case RIGHT
        case LEFT
        case CCW
        case CW
    }
    
    /***********************
    * ConnectionManagement *
    ***********************/
    
    /*****************************
    * static methods / variables *
    ******************************/
    
    //the singleton instance itself
    static let instance = CameraSlider()
    
    //The Singleton instance getter
    static func getInstance() -> CameraSlider {
        return instance;
    }
    
    /*******************************
    * instance methods / variables *
    ********************************/
    private let controlAdress = "85.214.213.194:8080"
    private var currentConnectionState:State = .DISCONNECTED
    
    private var connectedCallback : ((SRWebSocket) -> Void)? = nil;
    private var disconnectedCallback : (() -> Void)? = nil;
    
    private var wsConnection:SRWebSocket?
    
    override init(){
        super.init()
        socketConnect()
    }

    /***********************
    * ConnectionManagement *
    ***********************/
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        println("Message: \(message)")
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        currentConnectionState = .CONNECTED
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        currentConnectionState = .DISCONNECTED
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        currentConnectionState = .DISCONNECTED
    }
    
    func socketConnect() {
        currentConnectionState = .CONNECTING
        wsConnection = SRWebSocket(URL: NSURL(scheme: "ws", host: controlAdress, path: "/"))
        wsConnection!.delegate = self
        wsConnection!.open()
    }
    
    func addOnConnectCallback( callback:(SRWebSocket)->Void ){
        connectedCallback = callback
    }
    
    func addOnDisconnectCallback( callback:()->Void ){
        disconnectedCallback = callback
    }
    
    private func setState(newState:State){
        let oldState = currentConnectionState
        switch newState {
        case .DISCONNECTED:
            if oldState == State.CONNECTED && disconnectedCallback != nil {
                disconnectedCallback!()
            }
        case .CONNECTING:
            if oldState != State.DISCONNECTED && disconnectedCallback != nil {
                disconnectedCallback!()
            }
        case .CONNECTED:
            if oldState != State.CONNECTED && connectedCallback != nil {
                connectedCallback!(wsConnection!)
            }
        }
        currentConnectionState = newState
    }
    
    /***********************
    *   Hardware Control   *
    ***********************/
    func eStop(){
        //handle eStop
    }
    
    func home(){
        //handle homing
    }
    
    func setSpeed(){
        
    }
    
    func move(direction: Direction, withSpeed speed: Float){
    }
    
    func rotate(direction: Direction, withSpeed speed: Float){
        move(direction, withSpeed: speed)
    }
    
}