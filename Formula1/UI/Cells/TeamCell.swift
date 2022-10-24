//
//  TeamCell.swift
//  Formula1
//
//  Created by Yair Kerem on 12/08/2022.
//

import Foundation
import UIKit

class TeamCell: UITableViewCell {
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    var teamInCell: TeamDetails? = nil


}
