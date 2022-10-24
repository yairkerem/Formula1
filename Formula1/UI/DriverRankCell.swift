//
//  DriverRankCell.swift
//  Formula1
//
//  Created by Yair Kerem on 13/08/2022.
//

import Foundation
import UIKit

class DriverRankCell: UITableViewCell {
    
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var score: UILabel!

    var driverDetails: Driver? = nil
    let pointsEnum: Points? = nil
    
}
