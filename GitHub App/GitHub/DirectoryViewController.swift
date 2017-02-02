//
//  DirectoryViewController.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 12/17/16.
//  Copyright © 2016 UWM. All rights reserved.
//

import UIKit

class DirectoryViewController: UITableViewController {
    
    var token: String?
    var directoryRows: [DirectoryTree]? {
        didSet {
            self.configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = 44
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        if self.directoryRows == nil || self.directoryRows!.count < 0 {
            self.showBackgroundView()
        }
        else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
        }
        
        return 1
    }
    
    func showBackgroundView() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
        label.center = self.tableView.center
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 1
        label.font = UIFont(name: "Palatino-Italic", size: 20)
        label.text = "Loading data please wait!"
        self.tableView.separatorStyle = .none
        self.tableView.backgroundView = label
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if let rows = self.directoryRows {
            return rows.count
        }
        else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirectoryCell", for: indexPath) as! DirectoryTableViewCell
        if let dir = self.directoryRows {
            cell.setup(directory: dir[indexPath.row].directory)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let directory = self.directoryRows?[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if directory!.directory.type! == "blob" {
            loadBlobContent(url: directory!.directory.url!, token: self.token!, completionHandler: { (status, code) in
                if let rawCode = code, status, let codeController = storyboard.instantiateViewController(withIdentifier: "CodeViewController")    as? CodeViewController {
                    codeController.codeContent = rawCode
                    codeController.navigationItem.title = directory?.directory.path
                    self.navigationController?.pushViewController(codeController, animated: true)
                }
            })
        }
        else {
            if let directoryController = storyboard.instantiateViewController(withIdentifier: "DirectoryViewController")    as? DirectoryViewController {
                directoryController.directoryRows = directory!.children
                directoryController.token = self.token!
                directoryController.navigationItem.title = directory?.directory.path
                if let navigator = self.navigationController {
                    navigator.pushViewController(directoryController, animated: true)
                }
            }
        }
    }

}
