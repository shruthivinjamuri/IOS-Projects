//
//  UserRepos.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 11/30/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

import JSONJoy
import SwiftHTTP

class UserRepo {
    var Id: Int
    var name: String?
    var fullName: String?
    var description: String?
    var stars: Int = 0
    var watchers: Int = 0
    var forksCount: Int = 0
    var repoUrl: String?
    var repoSize: Int // Store this value in KB
    var createdDate: String?
    var updatedAt: String?
    var language: String?
    var owner: String?
    var treeUrl: String?
    var rootDirectory: DirectoryTree?
    var searchScore: Double = 0.0
    
    required init(_ decoder: JSONDecoder) {
        self.Id = decoder["id"].integer!
        self.name = decoder["name"].string
        self.fullName = decoder["full_name"].string
        self.description = decoder["description"].string
        self.stars = decoder["stargazers_count"].integer!
        self.watchers = decoder["watchers_count"].integer!
        self.forksCount = decoder["forks_count"].integer!
        self.repoUrl = decoder["url"].string
        self.repoSize = decoder["size"].integer!
        self.createdDate = decoder["created_at"].string
        self.updatedAt = decoder["pushed_at"].string
        self.language =  decoder["language"].string
        self.owner = decoder["owner"]["login"].string
        self.treeUrl = self.replaceHolder(url: decoder["trees_url"].string!)
        if let score = decoder["score"].double {
            self.searchScore = score
        }
    }
    
    func replaceHolder(url: String)-> String {
        let endIndex = url.index(url.endIndex, offsetBy: -6)
        let trimedUrl = url.substring(to: endIndex)
        return trimedUrl
    }
}

class Commit {
    var sha: String
    var author: String
    var commitDate: String
    
    required init(_ decoder: JSONDecoder) {
        self.author = decoder["author"]["login"].string!
        self.sha = decoder["sha"].string!
        self.commitDate = decoder["commit"]["author"]["date"].string!
    }
}

class RepoManager {
    var repos = [UserRepo]()
    var token: String
    var loginUser: String
    var contributionPerMonth = [Int](repeatElement(0, count: 13))
    var commits = Dictionary<Int, [Commit]>()
    var curRepo: Int
    var totalContributions: Int = 0
    
    init(token: String, loginUser: String) {
        self.token = token
        self.loginUser = loginUser
        self.curRepo = 0
    }
    
    func setupRepos(_ decoder: JSONDecoder) {
        for repo in decoder.array! {
            self.repos.append(UserRepo(repo))
        }
    }
    
    func setupCommits(_ decoder: JSONDecoder, repoId: Int) {
        if let decodedArray = decoder.array {
            for commit in decodedArray {
                if var commitList = self.commits[repoId] {
                    commitList.append(Commit(commit))
                    self.commits.updateValue(commitList, forKey: repoId)
                }
                else {
                    self.commits.updateValue([Commit(commit)], forKey: repoId)
                }
            }
            self.curRepo += 1
        }
        
    }
    
    func populateContributions(id: Int) {
        if let repoCommitList = self.commits[id] {
            for eachCommit in repoCommitList {
                if eachCommit.author.lowercased() != self.loginUser.lowercased() {
                    continue
                }
                let commitDate = self.getCommitDateFromString(dateStr: eachCommit.commitDate)
                let month = Calendar.current.component(.month, from: commitDate)
                self.contributionPerMonth[month] += 1
                self.totalContributions += 1
            }
        }
    }
    
    func getCommitDateFromString(dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter.date(from: dateStr)!
    }
    
    func topFourRepos() -> [UserRepo] {
        let sortedRepos = self.repos.sorted(by: { (repo1, repo2) in
            return repo1.stars > repo2.stars
        })

        var topFour:[UserRepo] = []
        
        
        for i in 0..<4 {
            if sortedRepos.count < (i + 1) {
                break
            }
            topFour.append(sortedRepos[i])
        }
        
        return topFour
    }
    
    func handleContributions(completionHandler: @escaping ((Bool, Int, Bool) -> Void)) {
        for userRepo in self.repos {
            do {
                let opt = try HTTP.GET("\(userRepo.repoUrl!)/commits?access_token=\(self.token)&since=\(self.getLastYearDate())&until=\(self.getTodayDate(date: Date()))&author=\(self.loginUser)")
                opt.start { response in
                        if response.error != nil {
                        DispatchQueue.main.async(execute: {
                            completionHandler(false, userRepo.Id, false)
                        })
                        
                        return //also notify app of failure as needed
                    }
                    self.setupCommits(JSONDecoder(response.data), repoId: userRepo.Id)
                    DispatchQueue.main.async(execute: {
                        completionHandler(true, userRepo.Id, self.curRepo == self.repos.count)
                    })
                    
                }
            } catch let error {
                DispatchQueue.main.async(execute: {
                    completionHandler(false, userRepo.Id, false)
                })
                assert(false, error as! String)
                //print("got an error creating the request: \(error)")
            }
        }
    }
    
    func getTodayDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter.string(from: date)
    }
    
    func getLastYearDate() -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .year, value: -1, to: Date())
        return getTodayDate(date: date!)
    }

}

func getDateFromString(dateStr: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return dateFormatter.date(from: dateStr)!
}

func relativeDate(date: Date) -> String {
    let components = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: date, to: Date())
    //print ("Components: \(components) fromdate: \(date) and to date: \(Date())")
    if components.year! >= 1 {return "A while ago"}
    
    if components.month! > 1 {return "\(components.month!) months ago"}
    if components.month! == 1 {return "A month ago"}
    
    if components.day! > 1 { return "\(components.day!) days ago" }
    if components.day! == 1 { return "A day ago" }
    
    if components.hour! > 1 { return "\(components.hour!) hours ago" }
    if components.hour! == 1 { return "An hour ago" }

    if components.minute! > 1 { return "\(components.minute!) minutes ago" }
    if components.minute! == 1 { return "A minute ago" }
    else {return "Just now"}
}
