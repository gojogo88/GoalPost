//
//  ViewController.swift
//  GoalPost
//
//  Created by Jonathan Go on 2017/09/11.
//  Copyright © 2017 Appdelight. All rights reserved.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate
//references the existing appDelegate

class GoalsVC: UIViewController {

    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var undoView: UIView!
    
    //variables
    var goals = [Goal]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCoreDataObjects()
        tableView.reloadData()
   }
    
    func fetchCoreDataObjects() {
        self.fetchData { (complete) in
            if complete {
                if goals.count >= 1 {
                    tableView.isHidden = false
                } else {
                    tableView.isHidden = true
                }
            }
        }
    }

    @IBAction func addGoalBtnPressed(_ sender: Any) {
        guard let createGoalVC = storyboard?.instantiateViewController(withIdentifier: "CreateGoalVC") else { return }
        presentDetail(createGoalVC)
    }

    @IBAction func undoBtnPressed(_ sender: Any) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.undoManager?.undo()
        undoView.isHidden = true
        fetchCoreDataObjects()
        tableView.reloadData()
    }
    
}

extension GoalsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else { return UITableViewCell() }
        
        let goal = goals[indexPath.row]
        
        cell.configureCell(goal: goal)
        return cell
    }
    
    //to be able to edit our tableview
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //editing style
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            self.removeGoal(atIndexPath: indexPath)
            self.fetchCoreDataObjects()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let addAction = UITableViewRowAction(style: .normal, title: "ADD 1") { (rowAction, indexPath) in
            self.updateProgress(atIndexPath: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        addAction.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.662745098, blue: 0.2666666667, alpha: 1)
        
        let goal = goals[indexPath.row]
        
        if goal.goalProgress == goal.goalCompletionValue {
            return [deleteAction]
        } else {
            return [deleteAction, addAction]
        }
    }
}

extension GoalsVC {
    func fetchData(completion: (_ complete: Bool) ->()) {
        //1.Create an constant to hold the Managed Object Context
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        //2.Create a fetch request to grab data from the persistent storage
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
        
        //3.Used our constant to fetch all that data from the fetch request
        do {
            goals = try managedContext.fetch(fetchRequest)
            print("Successfully fetched data")
            completion(true)
        } catch {
            debugPrint("Could not fetch \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func removeGoal(atIndexPath indexPath: IndexPath) {
        //1.Create an constant/reference to hold the Managed Object Context
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.undoManager = UndoManager()
        managedContext.delete(goals[indexPath.row])
        
        do {
            try managedContext.save()
            undoView.isHidden = false
            print("Successfully removed goal")
        } catch {
            debugPrint("Could not remove \(error.localizedDescription)")
        }
    }
    
    func updateProgress(atIndexPath indexPath: IndexPath) {
        //1.Create an constant/reference to hold the Managed Object Context
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        //2. find the goal we want to update
        let chosenGoal = goals[indexPath.row]
        
        if chosenGoal.goalProgress < chosenGoal.goalCompletionValue {
            chosenGoal.goalProgress += 1
        } else {
            return
        }
        
        do {
            try managedContext.save()
            print("Successfully set progress!")
        } catch {
            debugPrint("Could not set progress: \(error.localizedDescription)")
        }
    }
}
