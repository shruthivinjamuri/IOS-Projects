//
//  DetailViewController.swift
//  HackerNews
//
//  Created by Shruthi Vinjamuri on 12/10/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
     var flattenedComments = [Comment]()
     var displayText = "Please select a story."
    
    fileprivate lazy var downloader = {
        Downloader(configuration: URLSessionConfiguration.ephemeral)
    }()
    
    deinit {
        downloader.cancelAllTasks()
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem, let tableView = self.tableView {
            showNetworkIndicator(true)
            self.flattenedComments.removeAll()
            loadCommentsFromIds(commentIds: detail.commentIds, completionHandler: { loadedNestedComments in
                self.flattenComments(nestedComments: loadedNestedComments.flatMap({ $0 }))
                self.displayText = self.flattenedComments.count == 0 ? "No Comments." : "Please select a story."
                tableView.reloadData()
                showNetworkIndicator(false)
            })
            return
        }
    }
    
    func showBackgroundView() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
        label.center = self.tableView.center
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 2
        label.font = UIFont(name: "Palatino-Italic", size: 20)
        label.text = self.displayText
        self.tableView.separatorStyle = .none
        self.tableView.backgroundView = label
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(openWebPage(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func openWebPage(_ sender: Any) {
        if let _ = self.detailItem {
            self.performSegue(withIdentifier: "openWebPage", sender: sender)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openWebPage" {
            let webController = segue.destination  as! WebViewController
            webController.urlString = self.detailItem?.url
        }
    }
    
    var detailItem: Story? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.flattenedComments.count < 1 {
             self.showBackgroundView()
        }
        else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.flattenedComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        let comment = self.flattenedComments[indexPath.row]
        cell.detailTextLabel!.attributedText = getCommentTextLabel(author: (comment.author), date: (comment.createdDate), isDeleted: comment.isDeleted)
        
        cell.textLabel!.attributedText = getCommentDetailLabel(text: (comment.text), isDeleted: comment.isDeleted)
        cell.indentationLevel = comment.depth
        cell.indentationWidth = 10.0
       
        return cell
    }
    
    func getCommentDetailLabel(text: String, isDeleted: Bool) -> NSAttributedString {
        let detailText: NSAttributedString
        let completedText = isDeleted ? "[deleted] \(text)" : text
        do {
                 detailText = try NSAttributedString(
                data: completedText.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
        }
        catch {
            detailText = NSAttributedString(string: completedText)
        }
        
        return detailText
    }
    
    func getCommentTextLabel(author: String, date: Date, isDeleted: Bool) -> NSAttributedString {
        let completeAuthor = isDeleted ? "[deleted] \(author)" : author
        let attrAuthor = NSMutableAttributedString(string: completeAuthor)
        attrAuthor.addAttribute(NSForegroundColorAttributeName, value: UIColor.orange, range: attrAuthor.mutableString.range(of: author))
        let dateString = "- \(self.relativeDate(date: date))"
        let attrDate = NSMutableAttributedString(string: dateString)
         attrDate.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: attrDate.mutableString.range(of: dateString))
        attrAuthor.append(attrDate)
        
        return attrAuthor
    }
    
    private func relativeDate(date: Date) -> String {
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .month], from: date, to: Date())
        if components.minute! < 1 { return "A few seconds ago" }
        if components.minute! == 1 { return "A minute ago" }
        if components.hour! < 1 { return "\(components.minute!) minutes ago" }
        if components.hour! == 1 { return "An hour ago" }
        if components.day! < 1 { return "\(components.hour!) hours ago" }
        if components.day! == 1 { return "A day ago" }
        if components.month! < 1 { return "\(components.day!) days ago" }
        return "A while ago"
    }
    
    fileprivate func flattenComments(nestedComments: [NestedComments]) {
        
        for nestedComment in nestedComments {
            helper(nestedComment: nestedComment, depth: 1)
        }
    }
    
    fileprivate func helper(nestedComment: NestedComments, depth: Int) {
        nestedComment.comment.depth = depth
        self.flattenedComments.append(nestedComment.comment)
        for childNestedComment in nestedComment.children {
            helper(nestedComment: childNestedComment, depth: depth+1)
        }
    }
    
    func downloadComment(commentId: Int,completionHandler: (Comment?) -> Void) {
        let _ = downloader.download("https://hacker-news.firebaseio.com/v0/item/\(commentId).json") { url in
            if url != nil {
                if let envelope: [String: Any] = parse(url) {
                    completionHandler(parseComment(content: envelope))
                    return
                }
            }
            completionHandler(nil)
        }
    }
    
//    func loadCommentsFromIds(commentsIds: [Int], )
    
    func loadCommentsFromIds(commentIds: [Int], completionHandler: @escaping ([NestedComments?])->Void) {
        
        if (commentIds.count == 0) {
            completionHandler([NestedComments]())
            return
        }
        
        var parentNestedComments = [NestedComments?]()
        var collectedComments = 0
        for commentId in commentIds {
            downloadComment(commentId: commentId) { downloadedComment in
                collectedComments += 1
                if downloadedComment ==  nil {
                    parentNestedComments.append(nil)
                    if parentNestedComments.count == commentIds.count {
                        completionHandler(parentNestedComments.flatMap({ $0 }))
                    }
                    return
                } // don't add a nil comment to list
                let nestedComment =  NestedComments(comment: downloadedComment!)
                loadCommentsFromIds(commentIds: (downloadedComment?.replies)!, completionHandler: { childNestedComments in
                    
                    nestedComment.children = childNestedComments.flatMap({ $0 })
                    parentNestedComments.append(nestedComment)
                    if parentNestedComments.count == commentIds.count {
                        completionHandler(parentNestedComments.flatMap({ $0 }))
                    }
                })
            }
        }
    }
    
    
    
    func getDate(time: Int) -> Date {
        return Date.init(timeIntervalSince1970: TimeInterval(time))
    }
    
    func parseComment(content: [String: Any]) -> Comment? {
        let replies = content["kids"] == nil ? [Int]() : content["kids"] as! [Int]
        let isDeleted = content["deleted"] == nil ? false : content["deleted"] as! Bool
        if let Id = content["id"] as? Int, let by = content["by"] as? String, let text = content["text"] as? String, let time = content["time"] as? Int {
            return Comment(Id: Id, author: by, text: text, created: getDate(time: time), deleted: isDeleted,replies: replies)
        }
        return nil
    }


}

