//
//  MenuController.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 11/30/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgVWProfile: UIImageView!
    var profileData: UserProfile?
    var repoManager: RepoManager?
    var menuData: MenuProfile? {
        didSet {
            self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgVWProfile.layer.borderWidth = 1
        imgVWProfile.layer.cornerRadius = 10
        imgVWProfile.layer.masksToBounds = true
        imgVWProfile.contentMode = .scaleAspectFill
        imgVWProfile.layer.borderColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1).cgColor
        
        // Preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // To display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.configureView()
    }
    
    func configureView() {
        if let name = lblName, let img = imgVWProfile {
            if let data = self.menuData {
                name.text = data.name
                img.image = data.profilePicImg
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Menu"
        }
        return nil
    }
    
    // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHome", let profile = self.profileData  {
            let destinationController = (segue.destination as! UINavigationController).topViewController as! HomeViewController
            destinationController.profileData = profile
            destinationController.repoManager = self.repoManager!
            return
        }
        
        if segue.identifier == "showRepo", let repoManager = self.repoManager {
            let destinationController = (segue.destination as! UINavigationController).topViewController as! RepoViewController
            destinationController.userRepos = repoManager.repos
            destinationController.token = repoManager.token
            return
        }
        
        if segue.identifier == "showSearch" {
            let destinationController = (segue.destination as! UINavigationController).topViewController as! SearchViewController
            destinationController.token = repoManager?.token
            
            return
        }
    }
 

}
