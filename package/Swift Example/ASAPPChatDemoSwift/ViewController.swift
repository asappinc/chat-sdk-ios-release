//
//  ViewController.swift
//  ASAPPChatDemoSwift
//
//  Created by Mitchell Morgan on 8/4/16.
//  Copyright © 2016 ASAPP, Inc. All rights reserved.
//

import UIKit
import ASAPPSDK

class ViewController: UIViewController {
    
    let pushButton = UIButton(frame: .zero)
    let presentButton = UIButton(frame: .zero)
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupASAPP()
        
        title = "ASAPP Demo Swift"
        view.backgroundColor = UIColor.white
        
        pushButton.setTitle("Push Transition", for: .normal)
        pushButton.setTitleColor(UIColor.blue, for: .normal)
        pushButton.setTitleColor(UIColor.blue.withAlphaComponent(0.5), for: .highlighted)
        pushButton.addTarget(self, action: #selector(ViewController.pushToASAPPChat), for: .touchUpInside)
        view.addSubview(pushButton)
        
        presentButton.setTitle("Present Transition", for: .normal)
        presentButton.setTitleColor(UIColor.blue, for: .normal)
        presentButton.setTitleColor(UIColor.blue.withAlphaComponent(0.5), for: .highlighted)
        presentButton.addTarget(self, action: #selector(ViewController.presentASAPPChat), for: .touchUpInside)
        view.addSubview(presentButton)
    }
}

// MARK:- ASAPP

extension ViewController {
    
    func setupASAPP() {
        
        /**
         Set your ASAPP credentials here:
         */
        let appId: String = ""
        let apiHostName: String = ""
        let regionCode: String = ""
        let clientSecret: String = ""
        
        assert(!appId.isEmpty && !apiHostName.isEmpty && !regionCode.isEmpty && !clientSecret.isEmpty,
               "You must set your appId, apiHostName, regionCode, and clientSecret in ViewController.swift before running.")
        
        
        /**
         ASAPPConfig
         
         Set up your ASAPP Config here. This only needs to be performed once.
         A typical setup would place this code in the app's delegate file, but
         is placed here for viewing convenience.
         */
        let config = ASAPPConfig(appId: appId, apiHostName: apiHostName, clientSecret: clientSecret, regionCode: regionCode)
        ASAPP.initialize(with: config)
        
        
        /**
         ASAPPDelegate
         
         Set the delegate, which should implement all protocol methods.
         */
        ASAPP.delegate = self
        
        
        /**
         ASAPPUser
         
         Set the current user of the app.  The user identifer should be unique to the user.
         this could be an email address or some other internal identifier.
         
         This demo app automatically creates a fake user id and persists it between sessions.
         */
        ASAPP.user = ASAPPUser(
            userIdentifier: getUserIdentifier(),
            requestContextProvider: { needsRefresh in
                return [
                    ASAPP.authTokenKey: "dist_ios_SDK_Swift_fake_auth_token",
                    "fake_context_key_1": "fake_context_value_1"
                ]
        })
        
        
        /**
         ASAPPFontFamily
         
         You can define a font family to be used by the SDK's default styles.
         */
        let avenirNext = ASAPPFontFamily(
            light: UIFont(name: "AvenirNext-Regular", size: 16)!,
            regular: UIFont(name: "AvenirNext-Medium", size: 16)!,
            medium: UIFont(name: "AvenirNext-DemiBold", size: 16)!,
            bold: UIFont(name: "AvenirNext-Bold", size: 16)!)
        
        
        /**
         ASAPPStyles
         
         The SDK can be stylized to fit your brand.
         */
        ASAPP.styles.textStyles.updateStyles(for: avenirNext)
        
        ASAPP.styles.textStyles.navButton = ASAPPTextStyle(font: avenirNext.bold, size: 12, letterSpacing: 0, color: .black)
        
        
        /**
         ASAPPStrings
         
         The strings displayed in the SDK can be customized by accessing ASAPP.strings...
         */
        ASAPP.strings.chatTitle = "Demo Chat"
    }
    
    func handleASAPPDeepLink(named deepLink: String, with data: [String : Any]?) {
        let alert = UIAlertController(title: "Deep Link", message: deepLink, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func pushToASAPPChat() {
        guard let chatViewController = ASAPP.createChatViewControllerForPushing(fromNotificationWith: nil) else { return }
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    @objc func presentASAPPChat() {
        guard let chatViewController = ASAPP.createChatViewControllerForPresenting(fromNotificationWith: nil) else { return }
        present(chatViewController, animated: true, completion: nil)
    }
}

// MARK:- ASAPPDelegate

extension ViewController: ASAPPDelegate {
    func chatViewControllerDidDisappear() {}
    
    func chatViewControlledDidTapDeepLink(name: String, data: [String: Any]?) {
        handleASAPPDeepLink(named: name, with: data)
    }
    
    func chatViewControllerShouldHandleWebLink(url: URL) -> Bool {
        // Return false if ASAPP should not handle the web link and your app will handle it instead.
        return true
    }
    
    func chatViewControllerDidTapUserLoginButton() {
        /**
         Application should present UI to let user login. Once login is finished, ASAPP.user should be set.
         
         Note: if the user is always logged in, the body of this method may be left blank.
         */
    }
    
    func chatViewControllerDidReceiveChatEvent(name: String, data: [String: Any]?) {
        // Application can respond to certain agreed-upon events that can occur during a chat.
    }
}

// MARK:- Customer Id

extension ViewController {
    
    /***
     
     This returns a random user id by default, but you can override it
     to return a custom value, if preferred.
     
     */
    
    func getUserIdentifier() -> String {
        let customerIdKey = "saved_user_id_key"
        
        if let customerId = UserDefaults.standard.string(forKey: customerIdKey) {
            print("Using user identifier: \(customerId)")
            return customerId
        }
        
        let customerId = "customer_id-\(floor(Date().timeIntervalSinceReferenceDate))"
        
        UserDefaults.standard.set(customerId, forKey: customerIdKey)
        
        print("Using customer identifier: \(customerId)")
        
        return customerId
    }
}

// MARK:- Layout

extension ViewController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let buttonSize = CGSize(width: view.bounds.width, height: 50)
        let buttonCtrSpacing: CGFloat = buttonSize.height + 20
        
        let ctr = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        pushButton.bounds = CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height)
        pushButton.center = CGPoint(x: ctr.x, y: ctr.y - buttonCtrSpacing)
        
        presentButton.bounds = CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height)
        presentButton.center = CGPoint(x: ctr.x, y: ctr.y + buttonCtrSpacing)
    }
}
