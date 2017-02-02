//
//  RepoViewController.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 11/30/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class RepoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var userRepos: [UserRepo]?
    var token: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = 60
        
        // Do any additional setup after loading the view.
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
        navigationBar?.tintColor = UIColor.white
        navigationBar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return (self.userRepos?.count)!
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath) as! RepoFolderTableViewCell
        let repo = self.userRepos?[indexPath.row]
        cell.setup(repoName: repo!.name!, repoDesc: repo!.description)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let directoryController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DirectoryViewController") as? DirectoryViewController {
            let repo = self.userRepos?[indexPath.row]
            var rootTree: DirectoryTree
            if repo?.rootDirectory == nil {
                let rootDirectory = Directory(path: repo!.name!, type: "Repo", url: "\(repo!.treeUrl!)/master")
                rootTree = DirectoryTree(directory: rootDirectory)
                showNetworkIndicator(true)
                loadDirectory(url: rootDirectory.url!, token: self.token!, completionHandler: { (status, children) in
                    if status {
                        rootTree.children = children.flatMap({ $0 }).sorted(by: { $0.directory.type! > $1.directory.type! })
                        directoryController.directoryRows = rootTree.children
                        directoryController.token = self.token!
                        directoryController.navigationItem.title = repo!.name
                        if let navigator = self.navigationController {
                            navigator.pushViewController(directoryController, animated: true)
                        }
                        repo?.rootDirectory = rootTree
                    }
                    showNetworkIndicator(false)
                })
            }
            else {
                rootTree = repo!.rootDirectory!
                directoryController.directoryRows = rootTree.children
                directoryController.navigationItem.title = repo!.name
                directoryController.token = self.token
                if let navigator = self.navigationController {
                    navigator.pushViewController(directoryController, animated: true)
                }
            }
        }
    }

}
