//
//  DriverRaceCell.swift
//  Formula1
//
//  Created by Yair Kerem on 19/08/2022.
//

import Foundation
import UIKit

class DriverRaceCell: UITableViewCell {
    
  
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var time: UILabel!

    var driverDetails: Driver? = nil
}
