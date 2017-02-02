//
//  ProfileTableViewCell.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 11/30/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblUserBio: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblFollowingCount: UILabel!
    @IBOutlet weak var lblFollowersCount: UILabel!
    
    func setup(_ personObj: UserProfile) {
        var bioString = "\(personObj.name!)"
//        if personObj.bio != nil {
//            bioString.append("\nBio: \(getTrimmedBio(str: personObj.bio!))")
//        }
        if let login = personObj.loginName {
            bioString.append("\nLoginId: \(login)")
        }
        if personObj.location != nil {
            bioString.append("\nLocation: \(personObj.location!)")
        }
        bioString.append("\nJoined on: \(personObj.joinedOn!.substring(to: personObj.joinedOn!.index(personObj.joinedOn!.startIndex, offsetBy: 10)))")
        
        lblUserBio.text = bioString
        imgProfilePic.image = personObj.profilePicImg
        imgProfilePic.contentMode = .scaleAspectFill
        lblFollowingCount.text = trimNumbers(count: personObj.following)
        lblFollowersCount.text = trimNumbers(count: personObj.followers)
        lblFollowingCount.layer.cornerRadius = 2
        lblFollowingCount.layer.borderWidth = 1
        lblFollowingCount.layer.masksToBounds = true
        lblFollowersCount.layer.cornerRadius = 2
        lblFollowersCount.layer.borderWidth = 1
        lblFollowersCount.layer.masksToBounds = true
        imgProfilePic.layer.cornerRadius = 10
        imgProfilePic.layer.borderWidth = 1
        imgProfilePic.layer.masksToBounds = true
    }
    
    func trimNumbers(count: Int) -> String {
        
        if count < 1000 {
            return "\(count)"
        }
        
        return "\(count/1000)K+"
    }
}

class RepoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblRepo1: UILabel!
    @IBOutlet weak var lblRepo1Count: UILabel!
    @IBOutlet weak var lblRepo2Count: UILabel!
    @IBOutlet weak var lblRepo2: UILabel!
    @IBOutlet weak var lblRepo3Count: UILabel!
    @IBOutlet weak var lblRepo3: UILabel!
    @IBOutlet weak var lblRepo4Count: UILabel!
    @IBOutlet weak var lblRepo4: UILabel!
    
    func setup(repoManager: RepoManager) {
        let topFour = repoManager.topFourRepos()
        self.hideViews(count: topFour.count)
        
        let count = topFour.count
        var index =  count - 1
        if count > 3 {
            lblRepo4.text = getDescription(name: topFour[index].name!, description: topFour[index].description)
            lblRepo4Count.text = "★ \(topFour[index].stars)"
            index -= 1
        }
        
        if count > 2 {
            lblRepo3.text = getDescription(name: topFour[index].name!, description: topFour[index].description)
            lblRepo3Count.text = "★ \(topFour[index].stars)"
            index -= 1
        }
        
        if count > 1 {
            lblRepo2.text = getDescription(name: topFour[index].name!, description: topFour[index].description)
            lblRepo2Count.text = "★ \(topFour[index].stars)"
            index -= 1
        }
        
        if count > 0 {
            lblRepo1.text = getDescription(name: topFour[index].name!, description: topFour[index].description)
            lblRepo1Count.text = "★ \(topFour[index].stars)"
            index -= 1
        }
        
    }
    
    func getDescription(name: String, description: String?) -> String {
        var str: String = ""
        str.append("Name: \(name)")
        if let desc = description {
            str.append("\nDescription: \(desc)")
        }
        return str
    }
    
    func hideViews(count: Int) {
        if count > 3 {
            return
        }
        // hide 4th view
        lblRepo4.isHidden = true
        lblRepo4Count.isHidden = true
        
        if count < 3 {
            lblRepo3.isHidden = true
            lblRepo3Count.isHidden = true
        }
        
        if count < 2 {
            lblRepo2.isHidden = true
            lblRepo2Count.isHidden = true
        }
        
        if count < 1 {
            lblRepo1.isHidden = true
            lblRepo1Count.isHidden = true
        }
    }

    
    
}

class ContributionTableViewCell : UITableViewCell {
    
    @IBOutlet var vwMonthlyBars: [UIView]!
    @IBOutlet var lblMonthNames: [UILabel]!
    var monthLabels = [1: "JAN", 2: "FEB", 3: "MAR", 4: "APR", 5:"MAY", 6: "JUN", 7: "JUL", 8: "AUG", 9: "SEP", 10: "OCT", 11: "NOV", 12: "DEC"]
    
    func setup(repoManager: RepoManager, cellHeight: Int) {
        let curMonth = Calendar.current.component(.month, from: Date())
        let heightOfBars = repoManager.contributionPerMonth
        let labels = lblMonthNames.sorted(by: {(lbl1: UILabel, lbl2: UILabel) in
            lbl1.tag < lbl2.tag
        })
        let bars = vwMonthlyBars.sorted(by: {(vw1: UIView, vw2: UIView) in
            vw1.tag < vw2.tag
        })
        for i in 0..<12 {
            let monthIndex = (curMonth + 1 + i) % 12 == 0 ? 12 : (curMonth + 1 + i) % 12
            labels[i].text  = monthLabels[monthIndex]
            for constraint in bars[i].constraints {
                if constraint.firstAttribute == .height {
                    constraint.constant = calculateBarHeight(commits: heightOfBars[monthIndex], cellHeight: cellHeight, lblHeight: Int(labels[i].bounds.height))
                    break
                }
            }
        }
    }
    
    func calculateBarHeight(commits: Int, cellHeight: Int, lblHeight: Int) -> CGFloat {
        let heightOfBar = Double(cellHeight - 50)
        if commits == 0 {
            return CGFloat(0)
        }
        else if commits <= 10 {
            return CGFloat(0.2 * heightOfBar)
        }
        else if commits <= 20 {
            return CGFloat(0.4 * heightOfBar)
        }
        else if commits <= 30 {
            return CGFloat(0.6 * heightOfBar)
        }
        else if commits <= 8 {
            return CGFloat(0.8 * heightOfBar)
        }
        else {
            return CGFloat(heightOfBar)
        }
    }
    
}

class RepoFolderTableViewCell : UITableViewCell {
    
    @IBOutlet weak var lblRepoDesc: UILabel!
    @IBOutlet weak var lblRepoName: UILabel!
    
    func setup(repoName: String, repoDesc: String?) {
        self.lblRepoName.text = repoName
        self.lblRepoDesc.text = repoDesc
    }
}

class DirectoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgRowType: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    
    func setup(directory: Directory) {
        lblName!.text = directory.path
        imgRowType.image = directory.type == "blob" ?  UIImage(named: "File-icon") : UIImage(named: "Folder-icon")
        if directory.type == "blob", var size = directory.size {
            lblSize.isHidden = false
            if size < 1024 {
                lblSize.text = "\(size) Bytes"
                return
            }
            size = size/1024
            if size < (1024) {
                lblSize.text = "\(size) KB"
            }
            else {
                lblSize.text = "\(size/1024) MB"
            }
        }
        else {
            lblSize.isHidden = true
        }
    }
}

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblUpdateTime: UILabel!
    @IBOutlet weak var lblForksCount: UILabel!
    @IBOutlet weak var lblStarsCount: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblRepoDesc: UILabel!
    @IBOutlet weak var lblRepoFullName: UILabel!
    func setup(repo: UserRepo) {
        self.lblForksCount.text = "\(repo.forksCount)"
        self.lblRepoFullName.text = repo.fullName
        self.lblRepoDesc.text = repo.description
        self.lblLanguage.text = repo.language
        self.lblStarsCount.text = "★ \(repo.stars)"
        let date = getDateFromString(dateStr: repo.updatedAt!)
        self.lblUpdateTime.text =  relativeDate(date: date)
    }
}
