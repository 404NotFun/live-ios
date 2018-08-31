//
//  RoomHandler.swift
//  live-ext
//
//  Created by Jason Tsai on 2018/8/30.
//  Copyright © 2018年 io.ltebean. All rights reserved.
//

import Foundation
import SocketIO

class RoomHandler {
    static let shared = RoomHandler()
    
    var room: Room!
    
    let socket = SocketIOClient(socketURL: URL(string: Config.serverUrl)!, config: [.log(true), .forceWebsockets(true)])
    
    func createRoom(title: String, key: String) {
        room = Room(dict: [
            "title": title as AnyObject,
            "key": key as AnyObject
            ])
        
        socket.connect()
        socket.once("connect") {[weak self] data, ack in
            guard let this = self else {
                return
            }
            this.socket.emit("create_room", this.room.toDict())
        }
    }
}
