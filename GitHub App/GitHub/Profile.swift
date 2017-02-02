//
//  Profile.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 11/30/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

import SwiftHTTP
import JSONJoy

class Profile {
    var clientId: String
    let clientSecret: String
    var token: String
    var userData: UserProfile?
    
    init(clientId: String, clientSecret: String, token: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.token = token
    }
    
    func getProfile(completionHandler: @escaping ((Bool) -> Void)) -> Void {
        
        do {
            let opt = try HTTP.GET("https://api.github.com/user?access_token=\(self.token)")
            opt.start { response in
                if response.error != nil {
                    DispatchQueue.main.async(execute: {
                        completionHandler(false)
                    })
                    
                    return //also notify app of failure as needed
                }
                self.userData = UserProfile(JSONDecoder(response.data))
                DispatchQueue.main.async(execute: {
                    completionHandler(true)
                })

            }
        } catch let error {
            DispatchQueue.main.async(execute: {
                completionHandler(false)
            })
            assert(false, error.localizedDescription)
        }
    }
}
