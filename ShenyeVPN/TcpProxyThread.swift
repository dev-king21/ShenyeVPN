//
//  TcpProxyThread.swift
//  ShenyeVPN
//
//  Created by jsec1912 on 4/29/19.
//  Copyright © 2019 jsec1912. All rights reserved.
//

import Foundation
import Socket
import SSLService

class TcpProxyThread {
    
    static let bufferSize = 4096
    static let quitCommand: String = "QUIT"
    static let shutdownCommand: String = "SHUTDOWN"
    
    var tunnelHost: String
    var listenPort: Int, tunnelPort: Int
    var cert: String, key: String
    var session_id: Int = 0
    var is_last: Bool = false
    
    var listenSocket: Socket? = nil
    var continueRunningValue = true
    var connectedSockets = [Int32: Socket]()
    let socketLockQueue = DispatchQueue(label: "com.shenye.vpn.macos")
    var continueRunning: Bool {
        set(newValue) {
            socketLockQueue.sync {
                self.continueRunningValue = newValue
            }
        }
        get {
            return socketLockQueue.sync {
                self.continueRunningValue
            }
        }
    }

    init(_host: String, _lport: Int, _rport: Int, _cert: String, _key: String, _is_last: Bool) {
        self.tunnelHost = _host
        self.listenPort = _lport
        self.tunnelPort = _rport
        self.cert = _cert
        self.key = _key
        self.is_last = _is_last
    }
    
    deinit {
        for socket in connectedSockets.values {
            socket.close()
        }
        self.listenSocket?.close()
    }
    
    func run(){
        let queue = DispatchQueue(label: "com.shenye.vpn.macos", qos: .background)
        
        queue.async {
            do {
                try self.listenSocket = Socket.create(family: .inet, type: .datagram, proto: .udp)
                guard let socket = self.listenSocket else {
                    print("Unable to unwrap socket...")
                    return
                }
                
                try socket.listen(on: self.listenPort)
                if self.is_last {
                    TcpProxyService.started = true
                }
                repeat {
                    let newSocket = try socket.acceptClientConnection()
                    let tunnelSocket = self.createStealthSocket()
                    self.session_id += 1
                    self.localVPNConnection(socket: newSocket, remote_socket: tunnelSocket!)
                    
                    print("Accepted connection from: \(newSocket.remoteHostname) on port \(newSocket.remotePort)")
                    print("Socket Signature: \(String(describing: newSocket.signature?.description))")

                } while self.continueRunning

            } catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error...")
                    return
                }

                if self.continueRunning {

                    print("Error reported:\n \(socketError.description)")

                }
            }
        }
        //dispatchMain()
    }

    func localVPNConnection(socket: Socket, remote_socket: Socket) {
        relayData(from: socket, to: remote_socket)
        relayData(from: remote_socket, to: socket)
    }

    func shutdownThread() {
        
        self.continueRunning = false
        for socket in connectedSockets.values {
            self.socketLockQueue.sync { [unowned self, socket] in
                self.connectedSockets[socket.socketfd] = nil
                socket.close()
            }
        }
        
        DispatchQueue.main.sync {
            exit(0)
        }
        
    }
    
    func createStealthSocket() -> Socket?{
        
        let myConfig = SSLService.Configuration(withCACertificateDirectory: nil, usingCertificateFile: self.cert, withKeyFile: self.key)
        do {
            let socket = try Socket.create(family: .inet, type: .stream, proto: .tcp)
//            guard let re_socket = socket else {
//                fatalError("Could not create socket.")
//            }
            socket.delegate = try SSLService(usingConfiguration: myConfig)
            try socket.connect(to: self.tunnelHost, port: Int32(self.tunnelPort))
            return socket
        } catch let error {
            guard error is Socket.Error else {
                print("Unexpected error...")
                return nil
            }
        }
        return nil
    }
    
    func relayData(from: Socket, to: Socket){
        
        socketLockQueue.sync { [unowned self, from] in
            self.connectedSockets[from.socketfd] = from
        }
        let queue = DispatchQueue.global(qos: .default)
        
        queue.async { [unowned self, from] in
            
            var shouldKeepRunning = true
            var readData = Data(capacity: TcpProxyThread.bufferSize)
            do {
                repeat {
                    let bytesRead = try from.read(into: &readData)
                    if bytesRead > 0 {
                        try to.write(from: readData)
                    } else  {
                        shouldKeepRunning = false
                        break
                    }
                    
                    readData.count = 0
                    
                } while shouldKeepRunning
                
                print("Socket: \(from.remoteHostname):\(from.remotePort) closed...")
                from.close()
                
                self.socketLockQueue.sync { [unowned self, from] in
                    self.connectedSockets[from.socketfd] = nil
                }
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error by connection at \(from.remoteHostname):\(from.remotePort)...")
                    return
                }
                if self.continueRunning {
                    print("Error reported by connection at \(from.remoteHostname):\(from.remotePort):\n \(socketError.description)")
                }
            }
        }
    }
    
}
