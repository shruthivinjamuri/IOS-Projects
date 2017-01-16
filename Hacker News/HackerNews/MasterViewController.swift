//
//  MasterViewController.swift
//  HackerNews
//
//  Created by Shruthi Vinjamuri on 12/10/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var stories = [Story]()
    var downloadedStories = [Story?]()
    var rc: UIRefreshControl?
    
    fileprivate lazy var downloader = {
        Downloader(configuration: URLSessionConfiguration.ephemeral)
    }()
    
    deinit {
        downloader.cancelAllTasks()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.rc = UIRefreshControl()
        rc!.backgroundColor = UIColor.orange
        rc!.tintColor = UIColor.white
        rc!.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableView.addSubview(rc!)
        //self.tableView.setContentOffset(CGPoint(x: 0, y: -rc!.frame.size.height), animated: true)
        //rc!.beginRefreshing()
        self.refresh(rc!)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refresh(_ rc: UIRefreshControl) {
        showNetworkIndicator(true)
        loadStories(completionHandler: { loadedStories in
            self.stories = loadedStories.sorted(by: {$0.storyId < $1.storyId})
            self.tableView.reloadData()
            showNetworkIndicator(false)
            rc.endRefreshing()
        })
    }
    
    fileprivate func loadStories(completionHandler: @escaping ([Story]) -> Void ) {
        let _ = downloader.download("https://hacker-news.firebaseio.com/v0/topstories.json") { url in
            if url != nil {
                if let envelope: [Any] = parse(url), let storyIds = envelope as? [Int] {
                    loadStoryFromIds(storyIds: storyIds, completionHandler: completionHandler)
                    return
                }
            }
            
           print("Error retrieving stories!")
            return
        }
    }
    
    fileprivate func loadStoryFromIds(storyIds: [Int], completionHandler: @escaping ([Story])->Void) {
        self.downloadedStories.removeAll(keepingCapacity: true)
        let requiredStoryIds = storyIds.dropLast(storyIds.count - 25 < 0 ? 0 : storyIds.count - 25)
        for storyId in requiredStoryIds {
            downloadStory(storyId: storyId) { downloadedStory in
                self.downloadedStories.append(downloadedStory)
                
                if self.downloadedStories.count > 24 || requiredStoryIds.count == self.downloadedStories.count {
                    completionHandler(self.downloadedStories.flatMap({ $0 }))
                }
            }
        }
    }
    
    fileprivate func downloadStory(storyId: Int, completionHandler: (Story?) -> Void) {
        let _ = downloader.download("https://hacker-news.firebaseio.com/v0/item/\(storyId).json") { url in
            if url != nil {
                if let envelope: [String: Any] = parse(url) {
                    completionHandler(parseStory(content: envelope))
                    return
                }
            }
            completionHandler(nil)
        }
    }
    
 
    func parseStory(content: [String: Any]) -> Story? {
        if content["url"] == nil { return nil }
        let comments = content["kids"] == nil ? [Int]() : content["kids"] as! [Int]
        if let Id = content["id"] as? Int, let by = content["by"] as? String, let title = content["title"] as? String, let score = content["score"] as? Int{
            return Story(Id: Id, author: by, title: title, url: content["url"] as! String, score: score,  comments: comments)
        }
        return nil
    }
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let story = stories[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = story
                controller.navigationItem.title = story.title
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stories.count > 24 ? 25 : self.stories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let story = stories[indexPath.row]
        cell.textLabel!.text = story.title
        cell.detailTextLabel!.text = "\(story.score) points - by \(story.author)"
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
}

