//
//  ViewController.swift
//  BasicTunnel-macOS
//
//  Created by Davide De Rosa on 10/15/17.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
//
//  This file is part of TunnelKit.
//
//  TunnelKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  TunnelKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with TunnelKit.  If not, see <http://www.gnu.org/licenses/>.
//
//  This file incorporates work covered by the following copyright and
//  permission notice:
//
//      Copyright (c) 2018-Present Private Internet Access
//
//      Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//      The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//

import Cocoa
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

extension ViewController {
    private static let appGroup = "5362Y4AMXU.com.shenye.ymz"
    
    private static let tunnelIdentifier = "com.shenye.ymz.ShenyeVPNTunnelExtension"
    
    private func makeProtocol() -> NETunnelProviderProtocol {
        let server = textServer.stringValue
        let domain = textDomain.stringValue
        
        let hostname = ((domain == "") ? server : [server, domain].joined(separator: "."))
        let port = UInt16(1194)//UInt16(textPort.stringValue)!
        let credentials = OpenVPN.Credentials(textUsername.stringValue, textPassword.stringValue)
        
        var sessionBuilder = OpenVPN.ConfigurationBuilder()
        sessionBuilder.ca = ca
        sessionBuilder.clientCertificate = crt
        sessionBuilder.clientKey = key
        sessionBuilder.cipher = .aes128cbc
        sessionBuilder.digest = .sha1
        sessionBuilder.compressionFraming = nil
        sessionBuilder.renegotiatesAfter = nil
        sessionBuilder.hostname = server//hostname
        //        let socketType: SocketType = isTCP ? .tcp : .udp
        let socketType: SocketType = .udp
        sessionBuilder.endpointProtocols = [EndpointProtocol(socketType, port)]
        sessionBuilder.usesPIAPatches = true
        var builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
        builder.mtu = 1350
        builder.shouldDebug = true
        builder.masksPrivateData = false
        
        let configuration = builder.build()
        return try! configuration.generatedTunnelProtocol(
            withBundleIdentifier: ViewController.tunnelIdentifier,
            appGroup: ViewController.appGroup,
            credentials: credentials
        )
    }
}

class ViewController: NSViewController {
    @IBOutlet var textUsername: NSTextField!
    
    @IBOutlet var textPassword: NSTextField!
    
    @IBOutlet var textServer: NSTextField!
    
    @IBOutlet var textDomain: NSTextField!
    
    @IBOutlet var textPort: NSTextField!
    
    @IBOutlet var buttonConnection: NSButton!
    
    var currentManager: NETunnelProviderManager?
    
    var status = NEVPNStatus.invalid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textServer.stringValue = "192.168.100.96"//"germany"
        textDomain.stringValue = "privateinternetaccess.com"
        textPort.stringValue = "1194"
        textUsername.stringValue = "vman"
        textPassword.stringValue = "ghostman"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNStatusDidChange(notification:)),
            name: .NEVPNStatusDidChange,
            object: nil
        )
        
        reloadCurrentManager(nil)
        
        //
        
        testFetchRef()
    }
    
    @IBAction func connectionClicked(_ sender: Any) {
        let block = {
            switch (self.status) {
            case .invalid, .disconnected:
                self.connect()
                
            case .connected, .connecting:
                self.disconnect()
                
            default:
                break
            }
        }
        
        if (status == .invalid) {
            reloadCurrentManager({ (error) in
                block()
            })
        }
        else {
            block()
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
                    if (p.providerBundleIdentifier == ViewController.tunnelIdentifier) {
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
            buttonConnection.title = "Disconnect"
            
        case .disconnected:
            buttonConnection.title = "Connect"
            
        case .disconnecting:
            buttonConnection.title = "Disconnecting"
            
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
    
    private func testFetchRef() {
        //        let keychain = Keychain(group: ViewController.APP_GROUP)
        //        let username = "foo"
        //        let password = "bar"
        //
        //        guard let _ = try? keychain.set(password: password, for: username) else {
        //            print("Couldn't set password")
        //            return
        //        }
        //        guard let passwordReference = try? keychain.passwordReference(for: username) else {
        //            print("Couldn't get password reference")
        //            return
        //        }
        //        guard let fetchedPassword = try? Keychain.password(for: username, reference: passwordReference) else {
        //            print("Couldn't fetch password")
        //            return
        //        }
        //
        //        print("\(username) -> \(password)")
        //        print("\(username) -> \(fetchedPassword)")
    }
}

