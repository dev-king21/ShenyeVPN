//
//  MainViewController.swift
//  ShenyeVPN
//
//  Created by jsec1912 on 4/27/19.
//  Copyright © 2019 jsec1912. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON
import NetworkExtension
import TunnelKit

private let ca = OpenVPN.CryptoContainer(pem: """
-----BEGIN CERTIFICATE-----
MIID+jCCAuKgAwIBAgIBADANBgkqhkiG9w0BAQsFADB8MSMwIQYDVQQDDBp2cG4z
NTQ1NzA3MTEuc29mdGV0aGVyLm5ldDEjMCEGA1UECgwadnBuMzU0NTcwNzExLnNv
ZnRldGhlci5uZXQxIzAhBgNVBAsMGnZwbjM1NDU3MDcxMS5zb2Z0ZXRoZXIubmV0
MQswCQYDVQQGEwJVUzAeFw0xOTA1MTAwODAyMjFaFw0zNzEyMzEwODAyMjFaMHwx
IzAhBgNVBAMMGnZwbjM1NDU3MDcxMS5zb2Z0ZXRoZXIubmV0MSMwIQYDVQQKDBp2
cG4zNTQ1NzA3MTEuc29mdGV0aGVyLm5ldDEjMCEGA1UECwwadnBuMzU0NTcwNzEx
LnNvZnRldGhlci5uZXQxCzAJBgNVBAYTAlVTMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAuHeRj8Jf1u/NQr/UY2qRClML/Tt5I3ECPss61+FCQE5KLe5p
YTFGcT2Zeu1P8BfcNfnIkwhidETmepiTiCLJOwv3Y3KWVJ9Qt7xnjT0xX1WWJV+e
4OoeuzqQgXlDj9j8KXyapCDzb0fyqenHvpzAVvIRD/gOlm/HEHoc0ofLRMulcH6z
AshcPcDOCIeIwVBfRWsCiB7zW6uA8/JSXe7dXAzd6cg6zZ26MH33JV18x5uxj/WQ
R7hhF8VeluiM++aNy6elrQe+/700Fzgatl8q1N2nv+qO7DmWjD3TIeEEyfJt1fTE
xBqjLDaUedw+Yy7sRgCwDcUZCibHD8mfbPhL7wIDAQABo4GGMIGDMA8GA1UdEwEB
/wQFMAMBAf8wCwYDVR0PBAQDAgH2MGMGA1UdJQRcMFoGCCsGAQUFBwMBBggrBgEF
BQcDAgYIKwYBBQUHAwMGCCsGAQUFBwMEBggrBgEFBQcDBQYIKwYBBQUHAwYGCCsG
AQUFBwMHBggrBgEFBQcDCAYIKwYBBQUHAwkwDQYJKoZIhvcNAQELBQADggEBAJCG
s7I9XQ7H+NVABRoV81GKSRK2amNTydLaTNyt/Hg5LH3ljKaxWUQr1IELsfuqTRTF
uI1xLen3J9j16/LWe8vXc5ZqMRMjgJZtF9dFBLZhC1AQtvpcvk69gaN9wEu/ZoUi
KhNddkzQO5nUNPzWHXI0pW5h9jkltlP9Tit2/cqhaMn50HScgx3Q4//2i/reZ+QF
KINMYf57TEUpmET+yx2/Jkui69JbbmV/qdC1wVaGxyzO+d+H+PPDiblxp2QgvvOl
jHnvfbzRaNpAajDUGAKuG+lVAY2Y9WXUDFaRbKqdlR0lbS1+UQ+fXSbn1Pg+ZsV0
AHNrLukHylSmGegq8g0=
-----END CERTIFICATE-----
""")
private let crt = OpenVPN.CryptoContainer(pem: """
-----BEGIN CERTIFICATE-----
MIID1jCCAr6gAwIBAgIBADANBgkqhkiG9w0BAQsFADBqMR0wGwYDVQQDDBQxMTE1
MDcxMDIwODE2MDgxNzkwNzEdMBsGA1UECgwUMTExNTA3MTAyMDgxNjA4MTc5MDcx
HTAbBgNVBAsMFDExMTUwNzEwMjA4MTYwODE3OTA3MQswCQYDVQQGEwJVUzAeFw0x
OTA2MDEwMTI3MjNaFw0zNzEyMzEwMTI3MjNaMGoxHTAbBgNVBAMMFDExMTUwNzEw
MjA4MTYwODE3OTA3MR0wGwYDVQQKDBQxMTE1MDcxMDIwODE2MDgxNzkwNzEdMBsG
A1UECwwUMTExNTA3MTAyMDgxNjA4MTc5MDcxCzAJBgNVBAYTAlVTMIIBIjANBgkq
hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvI57YyGdhcAFvYMFHyMZeAY/3/ApClBl
a9ndvsYZAi3irqpLy2ddD18Q38uZzpgRlzQss3z75aohKXjl6nq2yN7aslHR1nTr
whMdLlu0UVJ8nmC9zuQoaeHHgzO6pIdJyL0FUwtgFgQusnEsMXNRgiUumj5Nsqja
malhtTR6OltLTdldCyeQtWIxKDwP8CLTIN/x4exLrcj5xZ5JajPsByQRvDwrwt6N
JU7srUOv9KtG1MAQ2+xxtdJkr9QHvUwIBk0Mi5RUzYsRF3Q6/9JecxNCshGVW9QR
wOs9nqXF5xECz2VzF2sDM81oEfhkWtJFPY8a3/XgDBsN3AhuP7tWZwIDAQABo4GG
MIGDMA8GA1UdEwEB/wQFMAMBAf8wCwYDVR0PBAQDAgH2MGMGA1UdJQRcMFoGCCsG
AQUFBwMBBggrBgEFBQcDAgYIKwYBBQUHAwMGCCsGAQUFBwMEBggrBgEFBQcDBQYI
KwYBBQUHAwYGCCsGAQUFBwMHBggrBgEFBQcDCAYIKwYBBQUHAwkwDQYJKoZIhvcN
AQELBQADggEBAETUh0tYHfHxiuwplqqMH4CYHC1Jiig9ZHQX4IWF6j3z/dyvPfzg
SGM1/m9NrxT+XXtoWDsBc6TktYZCX4f3sRkDPiraA5NnSl/7GFQKUBzj2nj9tMmE
1u9TMDx5JP5G3ut/Y8UEXFYm2ofSuunf1oLcZVE0l1Q3iw8UDm0BDWCc2EgKo8sE
sBzU7wOEdVoy6Agz1kM2+Leqv8j9qD5KjO99kE5c7pOmW2U4Szrqy0WC9xIKgBlR
UFKTirYtDBRm9sreN8jMNdOntEAA/jChAmqtyUm6hrRjozU9bnTarXelR8AYZpzR
i105WmBs62TSySU/YRiSGtp65ueINJx9SpE=
-----END CERTIFICATE-----
""")

private let key = OpenVPN.CryptoContainer(pem: """
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC8jntjIZ2FwAW9
gwUfIxl4Bj/f8CkKUGVr2d2+xhkCLeKuqkvLZ10PXxDfy5nOmBGXNCyzfPvlqiEp
eOXqerbI3tqyUdHWdOvCEx0uW7RRUnyeYL3O5Chp4ceDM7qkh0nIvQVTC2AWBC6y
cSwxc1GCJS6aPk2yqNqZqWG1NHo6W0tN2V0LJ5C1YjEoPA/wItMg3/Hh7EutyPnF
nklqM+wHJBG8PCvC3o0lTuytQ6/0q0bUwBDb7HG10mSv1Ae9TAgGTQyLlFTNixEX
dDr/0l5zE0KyEZVb1BHA6z2epcXnEQLPZXMXawMzzWgR+GRa0kU9jxrf9eAMGw3c
CG4/u1ZnAgMBAAECggEAQ7WunUR++n6gEROxjSLfjHhCC7qEIk4IfZg4xr8AUAYG
Ns60dRBjHJf4yUSlsMhu2KtFuhaRpkFXszrU5US3yp4sToiPH8HQv1p5yiHoOKO0
WHNI9bh8wrjvGjBDP73NQyaNeOrG0GEkG7QEOKW+iUus1nq1EAkOpstqaNW1Zqqw
A6jIlGF9DM0Rd7qQvUKK5S9ZOZbWiNbwEkn+1bNIo3SqDdsrBsSrQUDf3vmCYMff
KG7reQ+bfRjCsSXsyQVMldf7wLhrC34CMBqVZ+vZsh5V+SDUvTdkNOgUTLIqeQCs
mEM3Jj5kkkjYwbnm552YX4VSkUfNs801KfzHnTmacQKBgQDmIeBwhz0tOPesdpbD
2/yooqmn7+DERjhTmkFFs1jaGoxexYvDfnyVbyD+q66e1UIEOL5EVhvLk+/xcOcK
TNaHOrNi5u1L705rHI4kjQwIEQy7Z40vbi8nigChX4TENZsnAnyQOJLVO8ce2y18
7a5DNf0Q3xwxq3QHwy7bn7BwNQKBgQDRwEA8legnakrRONXqjK8NMOOzFLOGia8N
wcgr0D5Q67rcmTaLL5DUS0q+bZAXhAdht4Flv6xw/0S5JeZggTXDVXBEDtGXaa4K
+BV6ILLIfgDIsdko99iidfYmR0hDVuDx31EwkPErBkJXocIsT3BIovmjl6g9y7lw
wKcU/FE3qwKBgEaOal51yDbeOWlB7pVcFAmr3XIkpHfow4o2R/7TrtEnxJOl42Tr
mczDBo2uG1qNLbFXqFYRRHJVCAKxR9SrnDZXs/oFrQlT9Gn4lkf0ipTKjWnDpNC+
6mwn7muLeowhl1ENfR1GixYfPrxiHH8p6/ylR9JtZRqBY5ChsfMZ8aFlAoGBAIrd
ymmSIeI+iAweodmojJiiHo5IjVbsPt5PxnPjae5vMwar1SWvNyamNnT+2qAHBFAY
iu3PSZ6CEoC16+FGik6peStF2FNzXwvaFXYGwfblHSXCQXDTLjTY/j93gAs9MK5R
2FHcFB8VBMU5zfFCIqekZrx9QqCvCTXyBmxpZGgDAoGAOvEN9Z9JG1QKQU2vwxcz
OJQprcolkEEH2kxwwWvScxEhHt9JMKiukRcWRpmBYEDAhhh0mHXtKBtjPO5npzN9
NIMngvxKNCoZAToIu9L1qJdxui8jEY9AE6bXyVyxOKlDLl0nkG5avSRa1A4+9tkC
xXVnHH1s22owX765/kMyDQ0=
-----END PRIVATE KEY-----
""")

class MainViewController: NSViewController {

    @IBOutlet weak var mLblUid: NSTextField!
    @IBOutlet weak var mLblExpiredDate: NSTextField!
    @IBOutlet weak var mLblIp: NSTextField!
    @IBOutlet weak var mLblLocation: NSTextField!
    @IBOutlet weak var mLblStatusIn: NSTextField!
    @IBOutlet weak var mLblStatusOut: NSTextField!
    @IBOutlet weak var mButtonConnect: NSButton!
    @IBOutlet weak var mButtonLogout: NSButton!
    @IBOutlet weak var mImgFlag: NSImageView!
    
    
    @IBOutlet weak var mLogoutButtonCell: NSButtonCell!
    @IBOutlet weak var mConnectButtonCell: NSButtonCell!
    var serverList = [Server]()
    var ctryList = [Country]()
    static var selectedServerList = [Server]()
    var connected: Bool = false
    var currentManager: NETunnelProviderManager?
    var status = NEVPNStatus.invalid
    var selectedCtry: Int = -1
    var selectedServer: Int = -1
    var seletedIdx: Int = -1
    var myAlert = NSAlert()
    var proxyService: TcpProxyService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        mConnectButtonCell.isBordered = false
        mConnectButtonCell.backgroundColor = NSColor(red: 133, green: 197, blue: 31)
        mButtonConnect.wantsLayer = true
        mButtonConnect.layer?.cornerRadius = 5
        
        mLogoutButtonCell.isBordered = false
        mLogoutButtonCell.backgroundColor = NSColor(red: 246, green: 128, blue: 36)
        mButtonLogout.wantsLayer = true
        mButtonLogout.layer?.cornerRadius = 5
        
        updateServerInfo()
        updateIpData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNStatusDidChange(notification:)),
            name: .NEVPNStatusDidChange,
            object: nil
        )
        
    }
    @IBOutlet weak var mComboServer: NSComboBox!
    
    func loaddingInfo() {
        
    }
    
    @IBAction func ConnectDisConnectVPN(_ sender: Any) {
        
        //startStealthService()
        let dispatchQueue = DispatchQueue(label: "com.shenye.vpn.macos", qos: .background)
        dispatchQueue.async{
            //Time consuming task here
            if !TcpProxyService.started {
                let block = {
                    switch (self.status) {
                    case .invalid, .disconnected:
                        self.seletedIdx = Int.random(in: 0..<MainViewController.selectedServerList.count)
                        self.connect()
                        break
                    case .connected, .connecting:
                        self.disconnect()
                        break
                    default:
                        break
                    }
                }
        
                if self.status == .invalid {
                    self.reloadCurrentManager({ (error) in
                        block()
                    })
                }
                else {
                    block()
                }
            }
            
        }
        
    }
    
    func startStealthService() {
        if let certPath = Bundle.main.path(forResource: "cert", ofType: "pem") , let keyPath = Bundle.main.path(forResource: "key", ofType: "pem") {
            if FileManager.default.fileExists(atPath: certPath) && FileManager.default.fileExists(atPath: keyPath) {
                proxyService = TcpProxyService(cert: certPath, key: keyPath)
            }
        }
        
    }
    
    func stopStealthService() {
        proxyService?.stop()
    }

    @IBAction func comboSeletectionChanged(_ sender: Any) {
        self.serverSelected()
    }
    
    func serverSelected(){
        self.selectedCtry = mComboServer.indexOfSelectedItem
        if self.selectedCtry == -1 {
            myAlert.messageText = "You must select server!"
            myAlert.runModal()
            return
        }
        MainViewController.selectedServerList.removeAll()
        for srv in self.serverList {
            if srv.country == self.ctryList[selectedCtry].id {
                MainViewController.selectedServerList.append(srv)
            }
        }
        
        if MainViewController.selectedServerList.count == 0 {
            myAlert.messageText = "There's no server!"
            myAlert.runModal()
            return
        }
    }
    
    
    func connect() {
        configureVPN({ (manager) in
            return self.makeProtocol()
        }, completionHandler: { (error) in
            if let error = error {
                print("configure error: \(error)")
                return
            }
            let session = self.currentManager?.connection as! NETunnelProviderSession
            do {
                try session.startTunnel()
            } catch let e {
                print("error starting tunnel: \(e)")
            }
        })
    }
    
    func disconnect() {
        configureVPN({ (manager) in
            return nil
        }, completionHandler: { (error) in
            self.currentManager?.connection.stopVPNTunnel()
        })
    }
    
    func configureVPN(_ configure: @escaping (NETunnelProviderManager) -> NETunnelProviderProtocol?, completionHandler: @escaping (Error?) -> Void) {
        reloadCurrentManager { (error) in
            if let error = error {
                print("error reloading preferences: \(error)")
                completionHandler(error)
                return
            }
            
            let manager = self.currentManager!
            if let protocolConfiguration = configure(manager) {
                manager.protocolConfiguration = protocolConfiguration
            }
            manager.isEnabled = true
            
            manager.saveToPreferences { (error) in
                if let error = error {
                    print("error saving preferences: \(error)")
                    completionHandler(error)
                    return
                }
                print("saved preferences")
                self.reloadCurrentManager(completionHandler)
            }
        }
    }
    
    func reloadCurrentManager(_ completionHandler: ((Error?) -> Void)?) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let error = error {
                completionHandler?(error)
                return
            }
            
            var manager: NETunnelProviderManager?
            
            for m in managers! {
                if let p = m.protocolConfiguration as? NETunnelProviderProtocol {
                    if (p.providerBundleIdentifier == MainViewController.tunnelIdentifier) {
                        manager = m
                        break
                    }
                }
            }
            
            if (manager == nil) {
                manager = NETunnelProviderManager()
            }
            
            self.currentManager = manager
            self.status = manager!.connection.status
            self.updateButton()
            completionHandler?(nil)
        }
    }
    
    func updateButton() {
        switch status {
            case .connected, .connecting:
                mButtonConnect.title = "Disconnect"
            
            case .disconnected:
                mButtonConnect.title = "Connect"
            
            case .disconnecting:
                mButtonConnect.title = "Disconnecting"
                
            default:
                break
        }
    }
    
    @objc private func VPNStatusDidChange(notification: NSNotification) {
        guard let status = currentManager?.connection.status else {
            print("VPNStatusDidChange")
            return
        }
        print("VPNStatusDidChange: \(status.rawValue)")
        self.status = status
        updateButton()
    }
    
    @IBAction func Logout(_ sender: Any) {
        self.performSegue(withIdentifier: "mainToLogin", sender: nil)
    }
    
    func updateServerInfo(){
        let headerStr: String = (LoginViewController.username + ":" + LoginViewController.userpass.md5() + ":" + LoginViewController.version).toBase64()
        let headers: HTTPHeaders = [ "Authorization": headerStr ]
        AF.request("http://192.168.100.74/shenye/Android/server_list?XDEBUG_SESSION_START=15032", headers: headers).validate(statusCode: 200..<300).responseString { response in
            if let json = try? JSON(data: response.data!) {
                self.mLblUid.stringValue = json["user"]["username"].stringValue
                self.mLblExpiredDate.stringValue = json["user"]["expired_date"].stringValue
                
                let countryObj = json["countries"]
                let serverObj = json["servers"]
                for item in countryObj.arrayValue {
                    self.mComboServer.addItem(withObjectValue: item["country"])
                    self.ctryList.append(Country(_id: item["id"].intValue, _name: item["country"].stringValue))
                }
                var listenerPort: Int = 1200
                for item in serverObj.arrayValue {
                    self.serverList.append(Server(_id: item["id"].intValue, _account: item["AccountName"].stringValue, _host: item["Hostname"].stringValue, _hub: item["HubName"].stringValue,
                                                  _port: item["Port"].intValue, _ca: item["ca"].stringValue, _crt: item["crt"].stringValue, _key: item["key"].stringValue,
                                                  _ctry: item["Country"].intValue, _lport: listenerPort, _master: item["Master"].stringValue, _mask: item["Mask"].stringValue))
                    listenerPort += 1
                }
                if self.ctryList.count > 0 {
                    self.mComboServer.selectItem(at: 0)
                    self.serverSelected()
                }
            }
            
        }
    }
    
    func updateIpData()
    {
        AF.request("http://ip-api.com/json").validate(statusCode: 200..<300).responseString { response in
            if let json = try? JSON(data: response.data!) {
                self.mLblIp.stringValue = json["query"].stringValue.replacingOccurrences(of: ".", with: ".  ")
                self.mLblLocation.stringValue = json["country"].stringValue + json["city"].stringValue
                let flagUrl: String = "https://www.countryflags.io/" + json["countryCode"].stringValue + "/shiny/32.png"
                let url = URL(string: flagUrl)
                self.mImgFlag.image = NSImage(byReferencing: url!)
            }
        }
    }
    
    func crtPem (caString: String) -> String {
        var ret: String = "-----BEGIN CERTIFICATE-----\n"
        ret += caString.replacingOccurrences(of: "\r\n", with: "\n")
        ret += "\n-----END CERTIFICATE-----\n"
        return ret
    }
    
    func keyPem (keyString: String) -> String {
        var ret: String = "-----BEGIN PRIVATE KEY-----\n"
        ret += keyString.replacingOccurrences(of: "\r\n", with: "\n")
        ret += "\n-----END PRIVATE KEY-----\n"
        return ret
    }
    
    
}

extension MainViewController {
    
    private static let appGroup = "5362Y4AMXU.com.shenye.ymz"
    
    private static let tunnelIdentifier = "com.shenye.ymz.ShenyeVPNTunnelExtension"
    
    private func makeProtocol() -> NETunnelProviderProtocol {
        let serverRnd: Server = MainViewController.selectedServerList[seletedIdx]
        let server = serverRnd.Hostname
        let port = UInt16(1194) //UInt16(serverRnd.listenerPort)
        let credentials = OpenVPN.Credentials(LoginViewController.username, LoginViewController.userpass)
        
        var sessionBuilder = OpenVPN.ConfigurationBuilder()
        sessionBuilder.ca = OpenVPN.CryptoContainer(pem: self.crtPem(caString: serverRnd.ca))
        sessionBuilder.clientCertificate = OpenVPN.CryptoContainer(pem: self.crtPem(caString: serverRnd.crt))
        sessionBuilder.clientKey = OpenVPN.CryptoContainer(pem: self.keyPem(keyString: serverRnd.key))
        sessionBuilder.cipher = .aes128cbc
        sessionBuilder.digest = .sha1
        sessionBuilder.compressionFraming = nil
        sessionBuilder.renegotiatesAfter = nil
        sessionBuilder.hostname = server//hostname
        //        let socketType: SocketType = isTCP ? .tcp : .udp
        let socketType: SocketType = .tcp
        sessionBuilder.endpointProtocols = [EndpointProtocol(socketType, port)]
        sessionBuilder.usesPIAPatches = true
        var builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
        builder.mtu = 1350
        builder.shouldDebug = true
        builder.masksPrivateData = false
        
        let configuration = builder.build()
        return try! configuration.generatedTunnelProtocol(
            withBundleIdentifier: MainViewController.tunnelIdentifier,
            appGroup: MainViewController.appGroup,
            credentials: credentials
        )
    }
}
