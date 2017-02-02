//
//  UserProfile.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 11/30/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit
import JSONJoy

class UserProfile: JSONJoy {
    var profilePicImg: UIImage!
    var name: String!
    var bio: String!
    var joinedOn: String!
    var followers: Int!
    var following: Int!
    var location: String!
    var loginName: String!
    var id: Int!
    var profileURL: String!
    var repoUrl: String!
    var userId: Int!
    var userUrl: String!
    
    required init(_ decoder: JSONDecoder) {
        self.profilePicImg = UIImage(named: "profilepic")
        if let imgStr = decoder["avatar_url"].string {
            let imgURL = URL(string: imgStr)
            let data = try? Data(contentsOf: imgURL!)
            if let imgData = data {
                self.profilePicImg = UIImage(data: imgData)
            }
        }
        
        self.name = decoder["name"].string
        self.bio = decoder["bio"].string
        self.joinedOn = decoder["created_at"].string
        self.followers = decoder["followers"].integer
        self.following = decoder["following"].integer
        self.location = decoder["location"].string
        self.loginName = decoder["login"] .string
        self.id = decoder["id"].integer
        self.profileURL = decoder["html_url"].string
        self.repoUrl = decoder["repos_url"].string
        self.userId = decoder["Id"].integer
        self.userUrl = decoder["url"].string
    }

}

class MenuProfile {
    var profilePicImg: UIImage!
    var name: String!
    
    required init(profilePic: UIImage, name: String) {
        self.profilePicImg = profilePic
        self.name = name
    }
}

