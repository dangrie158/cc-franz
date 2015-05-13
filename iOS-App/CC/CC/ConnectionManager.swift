//
//  ConnectionManager.swift
//  CC
//
//  Created by Daniel Grießhaber on 11/05/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class ConnectionManager: NSObject, SRWebSocketDelegate {
    enum State{
        case DISCONNECTED
        case CONNECTING
        case CONNECTED
    }
    private var currentState:State = .DISCONNECTED
    
    private var connectedCallback : ((SRWebSocket) -> Void)? = nil;
    private var disconnectedCallback : (() -> Void)? = nil;
    
    private let controlAdress = "85.214.213.194:8080"
    
    private var wsConnection:SRWebSocket?
    
    override init(){
        super.init()
        socketConnect()
    }

    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        println("Message: \(message)")
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        currentState = .CONNECTED
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        currentState = .DISCONNECTED
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        currentState = .DISCONNECTED
    }
    
    func socketConnect() {
        currentState = .CONNECTING
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
        let oldState = currentState
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
        currentState = newState
    }
}