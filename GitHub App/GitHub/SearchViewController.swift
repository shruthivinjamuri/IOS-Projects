//
//  SearchViewController.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 11/30/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController?
    var searchRepos = [UserRepo]()
    var searchCount = 0
    var token: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = 75

        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
        navigationBar?.tintColor = UIColor.white
        navigationBar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.searchController = UISearchController(searchResultsController: nil)
        
        let bar = self.searchController!.searchBar
        bar.delegate = self
        bar.placeholder = "Search for Repositories..."
        bar.searchBarStyle = .minimal
        bar.tintColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
        bar.sizeToFit()
        //bar.showsCancelButton = true
        definesPresentationContext = true
        self.tableView.tableHeaderView = bar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Search bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //self.searchController?.isActive = false
        searchBar.text = ""
        self.searchRepos = [UserRepo]()
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var text = searchBar.text!
        self.searchController?.isActive = false
        searchBar.text = text
        
        text = text.trimmingCharacters(in: CharacterSet.whitespaces)
        if text.characters.count < 1 {
            return
        }
        showNetworkIndicator(true)
        search(token: self.token!, searchTerm: text, completionHandler: { (status, searchedTuple) in
            if status {
                self.searchCount = searchedTuple.0
                // sort based on the score
                self.searchRepos = searchedTuple.1.flatMap({ $0 }).sorted(by: { $0.searchScore > $1.searchScore })
                showNetworkIndicator(false)
                self.tableView.reloadData()
            }
        })
        
    }
    
    func showBackgroundView() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
        label.center = self.tableView.center
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 1
        label.font = UIFont(name: "Palatino-Italic", size: 20)
        
        label.text = "Please enter a search term"
        label.textColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
        self.tableView.separatorStyle = .none
        self.tableView.backgroundView = label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        if self.searchRepos.count < 1 {
            self.showBackgroundView()
        }
        else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.searchRepos.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell
        let repo = self.searchRepos[indexPath.row]
        cell.setup(repo: repo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let directoryController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DirectoryViewController") as? DirectoryViewController {
            let repo = self.searchRepos[indexPath.row]
            var rootTree: DirectoryTree
            if repo.rootDirectory == nil {
                let rootDirectory = Directory(path: repo.name!, type: "Repo", url: "\(repo.treeUrl!)/master")
                rootTree = DirectoryTree(directory: rootDirectory)
                showNetworkIndicator(true)
                loadDirectory(url: rootDirectory.url!, token: self.token!, completionHandler: { (status, children) in
                    if status {
                        rootTree.children = children.flatMap({ $0 }).sorted(by: { $0.directory.type! > $1.directory.type! })
                        directoryController.directoryRows = rootTree.children
                        directoryController.token = self.token!
                        directoryController.navigationItem.title = repo.name
                        if let navigator = self.navigationController {
                            navigator.pushViewController(directoryController, animated: true)
                        }
                        repo.rootDirectory = rootTree
                    }
                    showNetworkIndicator(false)
                })
            }
            else {
                rootTree = repo.rootDirectory!
                directoryController.directoryRows = rootTree.children
                directoryController.token = self.token!
                directoryController.navigationItem.title = repo.name
                if let navigator = self.navigationController {
                    navigator.pushViewController(directoryController, animated: true)
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
