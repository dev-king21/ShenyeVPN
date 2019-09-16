//
//  TcpProxyService.swift
//  ShenyeVPN
//
//  Created by jsec1912 on 4/29/19.
//  Copyright © 2019 jsec1912. All rights reserved.
//

import Foundation

class TcpProxyService {
    
    var proxyList = [TcpProxyThread]()
    static var started: Bool = false
    
    init(cert: String, key: String){
        proxyList.removeAll()
        var idx: Int = 1
        
        for  srv in MainViewController.selectedServerList
        {
            let ssl_proxy = TcpProxyThread(_host: srv.Hostname, _lport: srv.listenerPort, _rport: srv.Port,
                                       _cert: cert, _key: key, _is_last: idx == MainViewController.selectedServerList.count )
            proxyList.append(ssl_proxy)
            ssl_proxy.run();
            idx += 1
        }
    }
    
    func stop() {
        TcpProxyService.started = false;
        if proxyList.count == 0 {
            return
        }
        
        for ssl_proxy in proxyList{
            ssl_proxy.shutdownThread()
        }
        
        proxyList.removeAll()
    }
}
