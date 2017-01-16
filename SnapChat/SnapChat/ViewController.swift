//
//  ViewController.swift
//  SnapChat
//
//  Created by Shruthi Vinjamuri on 11/12/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    var messages: [SnapChatMessage] = []
    var refreshControl: UIRefreshControl!
    var lastUpdateDateTime: String?
    var searchedContent: [SnapChatMessage]?
    var searchController: UISearchController?
    var backgroundLabel = UILabel()
    var SnapChatNames = ["Bradley Simpson", "Brody Jenner", "Camila Cabello", "Ariana Grande", "Cara Delevingne",
                         "Charlie Puth", "Normani Kordei", "Kylie Jenner", "Jason Derulo", "George Shelley"]
    var currentIndex = 0
    var snapImageView = UIImageView()
    var snapImageLabel = UILabel()
    var emptyMessage = "You have no Snaps.\nSwipe down to refresh."
    var messageTimer: Timer?
    var currentMessage: SnapChatMessage?
    var currentCell: SnapChatCell?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // background label
        self.setUpBackgroundLabel()
        
        // SetUp Message View
        self.setUpSnapMessageView()
        
        // Refresh Control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = .white
        refreshControl.backgroundColor = UIColor(red: 1.0, green: 173/255, blue: 173/255, alpha: 1)
        self.refreshControl.addTarget(self, action:#selector(self.updateTableView), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        // Search controller
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchResultsUpdater = self
        
        let bar = searchController!.searchBar
        bar.delegate = self
        bar.placeholder = "Search for friends..."
        bar.searchBarStyle = .minimal
        bar.tintColor = UIColor.white
        bar.barTintColor = .white
        self.tableView.tableHeaderView = bar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpSnapMessageView() {
        
        // setup the view for the image
        self.snapImageView.frame = self.view.bounds
        self.snapImageView.center = self.view.center
        self.snapImageView.contentMode = .scaleAspectFill
        
        // create view to show timer value in a label
        let timerView = UIView()
        timerView.backgroundColor = .black
        timerView.alpha = 0.5
        timerView.frame = CGRect(x:snapImageView.bounds.width - 45, y: 25, width: 20, height: 20)
        timerView.layer.cornerRadius = 2
        timerView.layer.masksToBounds = true
        timerView.layer.borderWidth = 1
        
        // create the label
        self.snapImageLabel.text = "3"
        self.snapImageLabel.textColor = UIColor.white
        self.snapImageLabel.textAlignment = NSTextAlignment.center
        self.snapImageLabel.frame = timerView.bounds
        
        //add the label to timer and timer to image view
        timerView.addSubview(self.snapImageLabel)
        self.snapImageView.addSubview(timerView)
    }

    func displaySnapImage(row: Int) {
        self.snapImageView.image = UIImage(named: "selfie\(row+1)")
        self.view.addSubview(self.snapImageView)
        self.view.bringSubview(toFront: self.snapImageView)
    }
    
    func updateTableView() {
        if self.searchedContent != nil {
            self.messages = self.searchedContent!
            self.searchController?.searchBar.text = ""
            self.searchedContent = nil
            self.tableView.reloadData()
        }
        
        if let prevDateTime = self.lastUpdateDateTime {
            let attributedTitle = NSMutableAttributedString(string: prevDateTime)
            attributedTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.white,
                                         range: attributedTitle.mutableString.range(of: prevDateTime))
            self.refreshControl.attributedTitle = attributedTitle
        }
        
        self.lastUpdateDateTime = self.getLastUpdatedDateTime()
        
        // Kicks off animation for color change of refresh control background
        animateRefreshControl()
        
        // Fake load of the data
        let FAKE_LOAD_DELAY = 2.0;
        let popTime = DispatchTime.now() + Double(Int64(FAKE_LOAD_DELAY * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.refreshControl.endRefreshing()
            self.generateData()
        }
    }
    
    fileprivate func animateRefreshControl() {
        if !self.refreshControl.isRefreshing {
            return
        }
        
        UIView.animate(withDuration: 0.5, delay: Double(0.0) ,options:UIViewAnimationOptions.curveLinear, animations: { () in
            self.refreshControl!.backgroundColor = UIColor(red: 1.0, green: 173/255, blue: 173/255, alpha: 1)
        }, completion: { success in
            UIView.animate(withDuration: 0.5, delay: Double(0.0), options:UIViewAnimationOptions.curveLinear, animations: { () in
                self.refreshControl!.backgroundColor = UIColor(red: 173/255, green: 1.0, blue: 173/255, alpha: 1)
            }, completion: { success in
                UIView.animate(withDuration: 0.5, delay: Double(0.0), options:UIViewAnimationOptions.curveLinear, animations: { () in
                    self.refreshControl!.backgroundColor = UIColor(red: 173/255, green: 173/255, blue: 1.0, alpha: 1)
                }, completion: { success in
                    self.animateRefreshControl()
                })
            })
        })
    }
    
   // Mark: - UISearchController
    func updateSearchResults(for searchController: UISearchController) {
        
        if self.searchedContent == nil {
            self.searchedContent = self.messages
        }
        
        if let text = searchController.searchBar.text {
            if text == "" {
                self.messages = self.searchedContent!
            } else {
                self.messages = self.searchedContent!.filter({ message in message.description.lowercased().contains(text.lowercased()) })
            }

            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if self.messages.count > 1 {
            self.restoreTableView()
        }
        self.messages = self.searchedContent!
        self.searchController?.isActive = false
        self.tableView.reloadData()
        self.searchedContent = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text!
        self.searchController?.isActive = false
        searchBar.text = text
        
        self.messages = self.searchedContent!.filter({ message in message.description.contains(text.lowercased()) })
        tableView.reloadData()
    }
    
    func setUpBackgroundLabel() {
        self.backgroundLabel = UILabel()
        self.backgroundLabel.frame = self.tableView.bounds
        self.backgroundLabel.center = tableView.center
        self.backgroundLabel.textAlignment = .center
        self.backgroundLabel.numberOfLines = 2
        self.backgroundLabel.textColor = .black
        self.backgroundLabel.font = UIFont(name: "Palatino-Italic", size: 20)
    }
    
    func displayEmptyTableMessage() {
        self.tableView.separatorStyle = .none
        self.backgroundLabel.text = self.emptyMessage
        self.tableView.backgroundView = self.backgroundLabel
    }
    
    func restoreTableView() {
        self.tableView.backgroundView = nil
        self.tableView.separatorStyle = .singleLine
    }
    
    func generateData() {
        if self.currentIndex >= self.SnapChatNames.count {
            return
        }
        let duration = Int(arc4random_uniform(UInt32(5)) + 3)
        let message = SnapChatMessage(description: self.SnapChatNames[self.currentIndex], duration: duration)
        self.currentIndex += 1
        self.messages.append(message)
        self.searchController?.isActive = false
        self.emptyMessage = "No Results 💩."
        self.tableView.reloadData()
        self.restoreTableView()
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.messages.count < 1 {
            self.displayEmptyTableMessage()
        }
        else {
            self.restoreTableView()
        }
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SnapChatCell
        let message = messages[indexPath.row]
        
        // Long Press recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 1
        cell.addGestureRecognizer(longPressRecognizer)

        // Tap Recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        cell.addGestureRecognizer(tapRecognizer)
        
        // Cell attributes
        cell.CellDescription.text = message.description
        cell.CellStatus.text = message.getStatusMessage()
        cell.CellStatusImage.image = message.getImage()
        
        return cell
    }
    
    func onLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        let point = gestureRecognizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        
        if let index = indexPath {
            self.currentCell = self.tableView.cellForRow(at: index) as? SnapChatCell
            
            if gestureRecognizer.state == .ended {
                self.handleTimerEnd()
                return
            }
            
            if gestureRecognizer.state == .began {
                self.currentMessage = messages[index.row]
                if self.currentMessage!.displayDuration > 0 {
                    self.currentMessage!.openMessage()
                    self.snapImageLabel.text = String(self.currentMessage!.displayDuration)
                    self.messageTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                        self.update()
                    })
//                    self.messageTimer?.fire()
                    self.displaySnapImage(row: index.row)
                }
                return
            }
        }
    }
    
    func update() {
        print("Updating")
        if self.currentMessage!.displayDuration > 0 {
            self.currentMessage!.displayDuration -= 1
            self.snapImageLabel.text = String(self.currentMessage!.displayDuration)
        }
        else {
            self.handleTimerEnd()
        }
    }
    
    func handleTimerEnd() {
        self.messageTimer?.invalidate()
        self.currentCell!.CellStatusImage.image = self.currentMessage!.getImage()
        self.currentCell!.CellStatus.text = self.currentMessage!.getStatusMessage()
        self.view.sendSubview(toBack: self.snapImageView)
        self.snapImageView.removeFromSuperview()
    }
    
    func onTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        
        if let index = indexPath {
            let cell = self.tableView.cellForRow(at: index) as! SnapChatCell
            let prevText = cell.CellStatus.text
            UIView.animate(withDuration: 0.3, animations: { () in
                cell.center.x = cell.center.x - 30
                cell.center.y = cell.center.y
                cell.CellStatus.text = "Double tap to reply"
            }, completion: { success in
                UIView.animate(withDuration: 0.6, delay: Double(0.0), usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options:UIViewAnimationOptions.curveLinear, animations: { () in
                    cell.center.x = cell.center.x + 30
                    cell.center.y = cell.center.y
                }, completion: { success in
                    cell.CellStatus.text = prevText
                })
            })
        }
    }
    
    fileprivate func getLastUpdatedDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, YYY - h:mm a"
        return "Last Updated: " + dateFormatter.string(from: Date())
    }

}

