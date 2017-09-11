//
//  GoalCell.swift
//  GoalPost
//
//  Created by Jonathan Go on 2017/09/11.
//  Copyright © 2017 Appdelight. All rights reserved.
//

import UIKit

class GoalCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var goalDescriptionLbl: UILabel!
    @IBOutlet weak var goalTypeLbl: UILabel!
    @IBOutlet weak var goalProgressLbl: UILabel!
    
    
    func configureCell(goal: Goal) {
        self.goalDescriptionLbl.text = goal.goalDescription
        self.goalTypeLbl.text = goal.goalType //pulls it out as a string
        self.goalProgressLbl.text = String(describing: goal.goalProgress)
    }
    
}
