//
//  Login.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 11/29/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import SwiftHTTP
import JSONJoy

struct App: JSONJoy {
    var url: String?
    var name: String?
    var clientId: String?
    
    init(_ decoder: JSONDecoder) {
        url = decoder["url"].string
        name = decoder["name"].string
        clientId = decoder["client_id"].string
    }
}

struct Authorization: JSONJoy {
    var id: Int?
    var url: String?
    var scopes: Dictionary<String, JSONDecoder>?
    var app: App?
    var token: String?
    var note: String?
    var noteUrl: String?
    var clientId: String?
    var clientSecret: String?
    //var updatedAt: String?
    //var createdAt: String?
    
    init(_ decoder: JSONDecoder) {
        id = decoder["id"].integer
        url = decoder["url"].string
        app = App(decoder["app"])
        token = decoder["token"].string
        note = decoder["note"].string
        noteUrl = decoder["note_url"].string
    }
}

/*
 Since this is course project it's ok to keep these 
 below strings hardcoded.
 */
class Login {
    let clientId = "4956fe341642ab7a7f17"
    let clientSecret = "3e1f7c49e06a0935fa4078ae3b5427a8f7737fbb"
    var basicAuth = ""
    var auth: Authorization?
    
    init(username: String, password: String) {
        let optData = "\(username):\(password)".data(using: String.Encoding.utf8)
        if let data = optData {
            basicAuth = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        }
    }
    
    func tryLogin(completionHandler: @escaping ((Bool) -> Void)) -> Void {
        
        let params = ["scopes":["repo","user"], "note": "dev", "client_id": clientId, "client_secret": clientSecret] as [String : Any]
        
        do {
            let opt = try HTTP.POST("https://api.github.com/authorizations", parameters: params, headers: ["Authorization": "Basic \(basicAuth)"] ,requestSerializer: JSONParameterSerializer())
            opt.start { response in
                if response.error != nil {
                    DispatchQueue.main.async(execute: {
                        completionHandler(false)
                    })
                    
                    return //also notify app of failure as needed
                }
                
                //print(response.description)
                self.auth = Authorization(JSONDecoder(response.data))
                if self.auth!.token != nil {
                    self.auth?.clientId = self.clientId
                    self.auth?.clientSecret = self.clientSecret
                    DispatchQueue.main.async(execute: {
                        completionHandler(true)
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        completionHandler(false)
                    })
                }
                
            }
        } catch let error {
            DispatchQueue.main.async(execute: {
                completionHandler(false)
            })
            assert(false, error.localizedDescription)
        }
    }
}
