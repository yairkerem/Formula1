//
//  DriverCell.swift
//  Formula1
//
//  Created by Yair Kerem on 08/08/2022.
//

import Foundation
import UIKit

class DriverCell: UITableViewCell {
    
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var abbr: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var flag: UIImageView!   // To Do: create [country : flagImage] dictionary

    var driverInCell: Driver? = nil

}
