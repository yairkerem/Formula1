//
//  MainDriverCell.swift
//  Formula1
//
//  Created by Yair Kerem on 20/08/2022.
//

import Foundation
import UIKit

protocol CellDelegate {
    func favoriteHasBeenTapped()
}

class MainDriverCell: UITableViewCell {
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var abbr: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var flag: UIImageView!  
    @IBOutlet weak var birthDate: UILabel!
    @IBOutlet weak var birthPlace: UILabel!
    @IBOutlet weak var numberOfGP: UILabel!
    @IBOutlet weak var numberOfPodiums: UILabel!
    @IBOutlet weak var numberOfChamps: UILabel!
    @IBOutlet weak var highestRacePosition: UILabel!
    @IBOutlet weak var highestGridPosition: UILabel!
    var favoriteTapped: () -> () = { } // Default implementation
    
    var delegate: CellDelegate?
    
    @IBOutlet weak var favoriteStar: UIButton!
    
    var driver: Driver? = nil
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        favoriteTapped()
    }

    



}

