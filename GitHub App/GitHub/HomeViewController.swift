//
//  HomeViewController.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 11/30/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    @IBOutlet weak var menuButton:UIBarButtonItem!
    var profileData: UserProfile?
    var repoManager: RepoManager?
    var cell3Height = 275
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.rowHeight = UITableViewAutomaticDimension
//        self.tableView.estimatedRowHeight = 86
        
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! ProfileTableViewCell
            cell.setup(profileData!)
            return cell
        case 1:
             let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! RepoTableViewCell
             cell.setup(repoManager: self.repoManager!)
            return cell
        case 2:
             let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! ContributionTableViewCell
             cell.setup(repoManager: self.repoManager!, cellHeight: self.cell3Height)
            return cell
        default:
           return UITableViewCell() // this case should never be arised
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String = ""
        switch section {
        case 0:
            title = "Your Profile"
        case 1:
            title = "Popular Repositories"
        case 2:
            title = " \(self.repoManager == nil ? "" : String(describing: self.repoManager!.totalContributions)) Contribution(s) in last year"
        default:
            title = ""
        }
        return title
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            return 12
        }
        else { // portrait
            return 18
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionTitle: String = self.tableView(tableView, titleForHeaderInSection: section)!
        let sectionHeight = self.tableView(tableView, heightForHeaderInSection: section)
        if sectionTitle == "" {
            return nil
        }
        let view: UIView = UIView()
        let title: UILabel = UILabel()
        
        title.text = sectionTitle
        title.textColor = UIColor.black
        view.backgroundColor = UIColor.init(red: 102/255, green: 204/255, blue: 1, alpha: 1)
        title.frame = CGRect(x: 8, y: 2, width: UIScreen.main.bounds.width, height: sectionHeight - 4)
        title.font = UIFont(name: "Avenir Next Condensed", size: sectionHeight - 4)
        view.addSubview(title)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var totalHeight = tableView.bounds.height  - (self.navigationController?.navigationBar.bounds.height)!
        
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            totalHeight -= 40
        }
        else {
            totalHeight -= 75
        }
        
        var height: CGFloat
        switch indexPath.section {
        case 0:
            height = totalHeight * 0.32
        case 1:
            height = totalHeight * 0.18
        case 2:
            height = totalHeight * 0.5
            self.cell3Height = Int(height)
        default:
            height = CGFloat(86)
        }
        return height
    }
}
