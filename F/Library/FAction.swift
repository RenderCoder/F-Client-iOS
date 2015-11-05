//
//  FAction.swift
//  F
//
//  Created by huchunbo on 15/11/4.
//  Copyright © 2015年 TIDELAB. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess
import UIKit

class FAction: NSObject {
    subscript(request: String) -> AnyObject? {
        if let value = self.valueForKey(request) {
            return value
        }
        
        return nil
    }
    
    let _actions = [
        "login": {
            (params: [AnyObject], delegate: UIViewController) in
            
            if params.count < 1 {return}
            guard let userInputData = params[0] as? [String: String] else {return}
            
            let parameters = userInputData
            
            Alamofire.request(.POST, "\(Config.host)request_new_token", parameters: parameters, encoding: ParameterEncoding.JSON)
                .responseSwiftyJSON({ (request, response, json, error) in
                    if error == nil {
                        if !json["error"].boolValue {
                            print("login success!")
                        }else{
                            print("login error:(")
                        }
                        print(json)
                    }
                })
        },
        "register": {
            (params: [AnyObject], delegate: UIViewController) in
            
            
        }
    ]
    
    func run (action: String, params: [AnyObject], delegate: UIViewController) {
        
        _actions[action]?(params, delegate)
    }
    
    // MARK:
    // MARK: actions
    class func login (email: String, password: String, completeHandler: (success: Bool, description: String)->Void ) {
        
        let parameters = [
            "email": email,
            "password": password,
            "deviceID": FTool.Device.ID(),
            "deviceName": FTool.Device.Name()
        ]
        
        Alamofire.request(.POST, "\(Config.host)request_new_token", parameters: parameters, encoding: ParameterEncoding.JSON)
            .responseSwiftyJSON({ (request, response, json, error) in
                var success: Bool = false
                var description: String = String()
                
                if error == nil {
                    success = !json["error"].boolValue
                    if !success {
                        description = json["description"].stringValue
                    }
                    
                    //save token
                    FTool.KeyChain()["token"] = json["token"]["token"].stringValue
                }
                
                completeHandler(success: success, description: description)
            })
    }
    
    class func register (email: String, name: String, password: String, completeHandler: (success: Bool, description: String)->Void ) {
        
        let parameters = [
            "email": email,
            "name": name,
            "password": password
        ]
        
        Alamofire.request(.POST, "\(Config.host)register_new_user", parameters: parameters, encoding: ParameterEncoding.JSON)
            .responseSwiftyJSON({ (request, response, json, error) in
                var success: Bool = false
                var description: String = String()
                
                if error == nil {
                    success = !json["error"].boolValue
                    if !success {
                        description = json["description"].stringValue
                        
                        completeHandler(success: success, description: description)
                    } else {
                        FAction.login(email, password: password, completeHandler: completeHandler)
                    }
                }  
            })
    }
}