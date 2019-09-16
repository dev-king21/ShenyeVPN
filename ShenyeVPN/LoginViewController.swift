//
//  ViewController.swift
//  ShenyeVPN
//
//  Created by jsec1912 on 4/26/19.
//  Copyright © 2019 jsec1912. All rights reserved.
//

import Cocoa
import Alamofire
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

class LoginViewController: NSViewController {

    @IBOutlet var mainView: NSView!
    @IBOutlet weak var tfUsername: NSTextField!
    @IBOutlet weak var tfUserPwd: NSSecureTextField!
    
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var loginButtonCell: NSButtonCell!
    
    static var version: String = "2.3.0"
    static var username: String = ""
    static var userpass: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButtonCell.isBordered = false
        loginButtonCell.backgroundColor = NSColor(red: 133, green: 197, blue: 31)
        loginButton.wantsLayer = true
        loginButton.layer?.cornerRadius = 5
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    @IBAction func Login(_ sender: Any) {
        
        let uname : String = tfUsername.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let upass : String = tfUserPwd.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let myAlert = NSAlert()
        
        if uname.isEmpty || upass.isEmpty {
            myAlert.messageText = "Username and Password must be entered!"
            myAlert.runModal()
            return
        }
        
        let headerStr: String = (uname + ":" + upass.md5() + ":" + LoginViewController.version).toBase64()
        
        let headers: HTTPHeaders = [ "Authorization": headerStr ]
        
        AF.request("http://192.168.100.74/shenye/Android/login?XDEBUG_SESSION_START=15032", headers: headers).validate().response{response in
            
            let statusCode = response.response?.statusCode;
            if statusCode == 200 {
                self.goToMain(uname: uname, upass: upass)
            } else if statusCode == 401 {
                
            } else if statusCode == 402 {
                
            } else if statusCode == 409 {
                
            } else if statusCode == 423 {
                
            } else {
                
            }
        }
    }
    
    func goToMain(uname: String, upass: String) {
        LoginViewController.username = uname
        LoginViewController.userpass = upass
        self.performSegue(withIdentifier: "loginToMain", sender: nil)
    }
    
}

public extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func md5() -> String {
        return md5Digest(param: self).map { String(format: "%02hhx", $0) }.joined()
    }
    
    func md5Digest(param: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = param.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
}

public extension NSColor {
    convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0 && red <= 255 else {
            return nil
        }
        guard green >= 0 && green <= 255 else {
            return nil
        }
        guard blue >= 0 && blue <= 255 else {
            return nil
        }
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
}

