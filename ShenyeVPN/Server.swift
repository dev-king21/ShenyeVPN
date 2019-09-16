//
//  Server.swift
//  ShenyeVPN
//
//  Created by jsec1912 on 4/27/19.
//  Copyright © 2019 jsec1912. All rights reserved.
//

import Foundation

class Server {
    
    var id: Int
    var AccountName: String
    var Hostname: String
    var HubName: String
    var Port: Int
    var ca: String
    var crt: String
    var key: String
    var country: Int
    var listenerPort: Int
    var Master: String
    var Mask: String
    
    init(_id: Int, _account: String, _host: String, _hub: String, _port: Int, _ca: String, _crt: String, _key: String, _ctry: Int, _lport: Int, _master: String, _mask: String){
        self.id = _id
        self.AccountName = _account
        self.HubName = _hub
        self.Hostname = _host
        self.Port = _port
        self.ca = _ca
        self.crt = _crt
        self.key = _key
        self.country = _ctry
        self.listenerPort = _lport
        self.Master = _master
        self.Mask = _mask
    }
}
