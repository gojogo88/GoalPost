//
//  FinishGoalVC.swift
//  GoalPost
//
//  Created by Jonathan Go on 2017/09/11.
//  Copyright © 2017 Appdelight. All rights reserved.
//

import UIKit
import CoreData

class FinishGoalVC: UIViewController, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var createGoalBtn: UIButton!
    @IBOutlet weak var pointsTextField: UITextField!
    
    //variables
    var goalDescription: String!
    var goalType: GoalType!
    
    func initData(description: String, type: GoalType) {
        self.goalDescription = description
        self.goalType = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createGoalBtn.bindToKeyboard()
        pointsTextField.delegate = self
        
    }

    @IBAction func createGoalBtnPressed(_ sender: Any) {
        //pass data into Core Data Goal Model
        if pointsTextField.text != "" {
            self.save { (complete) in
                if complete {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    
    //save to Core Data
    func save(completion: (_ finished: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        //this is how we get our managed object context from the main queue
        //create an instance of Goal Entity and instantiate it by telling which model it will be using (managedContext)
        let goal = Goal(context: managedContext)
        
        goal.goalDescription = goalDescription
        goal.goalType = goalType.rawValue  //rawValue to acccess the String value
        goal.goalCompletionValue = Int32(pointsTextField.text!)!
        goal.goalProgress = Int32(0)  //no progress yet
        
        //tell manage context to pass it on to persistent storage. do-try-catch bec of "throws"
        do {
            try managedContext.save()
            print("Successfully saved data")
            completion(true)
        } catch {
            debugPrint("Could not save: \(error)")
            completion(false)
        }
    }
}
