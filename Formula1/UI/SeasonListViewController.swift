//
//  SeasonListViewController.swift
//  Formula1
//
//  Created by Yair Kerem on 12/08/2022.
//

import UIKit

class SeasonListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!

    var listToShow: [Int] = F1Service.shared.getSeasonList().reversed()
    let fetch = FetcherService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImageString = F1Service.shared.getRandomBackgroundImage()
        Task {@ MainActor in
            backgroundImageView.image = await F1Service.shared.getPosterImage(posterString: backgroundImageString)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
       
    }
}


extension SeasonListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeasonCell", for: indexPath) as! SeasonCell
        cell.seasonLabel.text = String(listToShow[indexPath.row])
        cell.seasonLabel.layer.cornerRadius = cell.seasonLabel.frame.size.height/5.0
        cell.seasonLabel.layer.masksToBounds = true
        cell.seasonLabel.layer.borderColor = .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        cell.seasonLabel.layer.borderWidth = 0.5

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        F1Service.shared.selectedSeason = listToShow[indexPath.row]

    }
    
}
