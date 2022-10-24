//
//  FavoritesViewController.swift
//  Formula1
//
//  Created by Yair Kerem on 27/08/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FavoritesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
   
    let fetch = FetcherService()
    let storage = StorageService()

//    var teamList = [TeamDetails]()
    var teamList = FavoritesService.shared.favoriteTeams
    var driverList = FavoritesService.shared.favoriteDrivers

    let sections = ["Drivers", "Constructors"]
    
    override func viewDidLoad() {   // this view loads when user signs in, not when Favorites VC is loaded
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        driverList = FavoritesService.shared.favoriteDrivers
        teamList = FavoritesService.shared.favoriteTeams
        print("Favorite drivers list: \(driverList)")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        driverList = FavoritesService.shared.favoriteDrivers
        teamList = FavoritesService.shared.favoriteTeams
        tableView.reloadData()
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return driverList.count
        case 1:
            return teamList.count
        default:
            return 0
        }
        
        //        return listToShow[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DriverCell") as! DriverCell
            let driverId = driverList[indexPath.row]
            
            Task { @MainActor in
                if let driver = await fetch.getDriver(id: driverId),
                   let image = driver.image,
                   let id = driver.id,
                   let posterImageCached = await storage.getDriverImage(driverImage: image, driver: driver) {
                    
                    cell.driverInCell = driver
                    let name = driver.name?.components(separatedBy: " ")
                    if let firstName = name?[0] {
                        cell.firstName.text = firstName
                        print(firstName)
                    }
                    if let lastName = name?[1] {
                        cell.lastName.text = lastName
                        print(lastName)
                    }
                    cell.abbr.text = driver.abbr
                    
                    //                DispatchQueue.main.async {    // commented out because the @MainActor seams to work faster
                    self.storage.driverPosterCachingNSCache.setObject(posterImageCached, forKey: id as NSNumber)
                    cell.poster.image = posterImageCached
                    //                }
                    if let countryName = driver.country?.name {
                        cell.flag.image = F1Service.shared.getFlag(country: countryName)
                    } else {
                        if let countryCode = driver.country?.code {
                            cell.flag.image = F1Service.shared.getFlag(with: countryCode)
                        } else {    //  no country name nor code
                            cell.flag.image = F1Service.shared.getFlag(country: "Israel")
                        }
                    }
                }
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = backgroundView
            
    
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell") as! TeamCell

            let teamId = teamList[indexPath.row]
            
            Task { @MainActor in
                if let team = await fetch.getTeam(id: teamId),
//                   let image = team.logo,
//                   let id = team.id,
                   let posterImageCached = await storage.getTeamImage(teamImage: team.logo, team: team) {
                    
                    cell.teamInCell = team
                    cell.teamName.text = team.name
                    
                    //  DispatchQueue.main.async {          // commented out because the @MainActor seams to work faster
                    self.storage.teamPosterCachingNSCache.setObject(posterImageCached, forKey: team.id as NSNumber)
                    cell.logo.image = posterImageCached
                    //  }
                    
                    cell.location.text = team.base
                
                }
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = backgroundView

            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return("Drivers")
        } else {
            return("Constructors")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .black
        }
    }

}


extension FavoritesViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DriverViewController,
           let senderCell = sender as? DriverCell {
            destination.driver = senderCell.driverInCell
        }
        
        if let destination = segue.destination as? TeamViewController,
        let senderCell = sender as? TeamCell {
            destination.team = senderCell.teamInCell
        }
    }
}
