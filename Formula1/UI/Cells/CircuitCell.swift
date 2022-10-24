//
//  CircuitCell.swift
//  Formula1
//
//  Created by Yair Kerem on 08/08/2022.
//

import UIKit

class CircuitCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var flag: UIImageView!   // To Do: create [country : flagImage] dictionary
    
    var circuitInCell: Circuit? = nil
}
