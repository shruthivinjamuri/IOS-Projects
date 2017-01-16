//
//  MasterViewController.swift
//  StrongLifts
//
//  Created by Shruthi Vinjamuri on 11/5/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

protocol RepsUpdated {
    func UserUpdatedReps()
}

class MasterViewController: UITableViewController, RepsUpdated {

    var detailViewController: DetailViewController? = nil
    var objects = [Workout]()
    var previous: Workout? = nil
    fileprivate var currentlyEditing: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 86

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    func UserUpdatedReps() {
        self.tableView.reloadRows(at: [
            IndexPath(row: currentlyEditing, section: 0)
            ], with: .automatic)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: AnyObject) {
        let workout = objects.count > 0 ? Workout(index: previous!.index + 1, previous: previous!) : Workout(index: 1)
        previous = workout
        objects.insert(workout, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let workout = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = workout
                currentlyEditing = indexPath.row
                controller.delegate = self
                controller.navigationItem.title = "Workout \(workout.index)"
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
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let workout = objects[indexPath.row]
        cell.textLabel!.text = workout.toString()
        cell.detailTextLabel?.text = "Workout \(workout.index)"
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    internal func toString(_ unit: Units) -> String {
        switch unit {
        case .pounds:
            return "LB"
        case .kilograms:
            return "KG"
        }
    }


}

