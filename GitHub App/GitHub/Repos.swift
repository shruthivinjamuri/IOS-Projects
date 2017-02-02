//
//  Repos.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 12/3/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

import SwiftHTTP
import JSONJoy

class Repos {
    var token: String
    var repoManager: RepoManager
    
    init(token: String, loginName: String) {
        self.token = token
        self.repoManager = RepoManager(token: token, loginUser: loginName)
    }
    
    func getRepos(completionHandler: @escaping ((Bool) -> Void)) {
    
        do {
            let opt = try HTTP.GET("https://api.github.com/user/repos?access_token=\(self.token)&sort=updated")
            opt.start { response in
                if response.error != nil {
                    DispatchQueue.main.async(execute: {
                        completionHandler(false)
                    })
                    
                    return //also notify app of failure as needed
                }
                DispatchQueue.main.async(execute: {
                    self.repoManager.setupRepos(JSONDecoder(response.data))
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

func search(token: String, searchTerm: String, completionHandler: @escaping ((Bool, (Int, [UserRepo?])) -> Void)) {
    
    do {
        let opt = try HTTP.GET("https://api.github.com/search/repositories?access_token=\(token)&q=\(searchTerm)+in:name,description")
        opt.start { response in
            if response.error != nil {
                DispatchQueue.main.async(execute: {
                    completionHandler(false, (0, [nil]) )
                })
                
                return //also notify app of failure as needed
            }
            DispatchQueue.main.async(execute: {
                let searchTuple = parseSearchResults(JSONDecoder(response.data))
                completionHandler(true, searchTuple)
            })
            
        }
    } catch let error {
        DispatchQueue.main.async(execute: {
            completionHandler(false, (0, [nil]))
        })
        print(error.localizedDescription)
    }
}

func parseSearchResults(_ decoder: JSONDecoder) -> (Int, [UserRepo?]) {
    let searchCount = decoder["total_count"].integer!
    var reposFound = [UserRepo]()
    if let items = decoder["items"].array {
        for item in items {
            reposFound.append(UserRepo(item))
        }
    }
    
    return (searchCount, reposFound)
}
