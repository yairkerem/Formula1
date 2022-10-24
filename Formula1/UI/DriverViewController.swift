//
//  DriverViewController.swift
//  Formula1
//
//  Created by Yair Kerem on 20/08/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class DriverViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var driver: Driver? = nil
    let f1Service = F1Service.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
    }

    //    Firebase server: modify Favorite Status
    private lazy var databaseFavoriteDrivers: DatabaseReference? = {
        // User Id
        guard let uid = Auth.auth().currentUser?.uid else {
//        guard let uid = UserDefaults.standard.string(forKey: userIdKey) else {    // written by Guy. why? perhaps because he didn't have access to the Firebase account
        print("No user in User Defaults")
            return nil
        }
        // reference
        let ref = Database.database().reference().child("users/\(uid)/favorites/drivers")
        return ref
    }()
    
    let encoder = JSONEncoder()
    
    
    func addDriver(_ driver: FavoriteDriver) {
        guard let databasePath = databaseFavoriteDrivers else {
            return
        }
        do {    //  add to Firebase DB
            let data = try encoder.encode(driver)
            let json = try JSONSerialization.jsonObject(with: data)
            databasePath.child("driverId-\(driver.driverId)").setValue(json)
            
            //  add to local storage
            let id = driver.driverId
            FavoritesService.shared.addFavorite(driver: id)
            print("Local list: \(FavoritesService.shared.favoriteDrivers)")

        } catch {
            print("Error: \(error)")
        }
        return
    }
    
    func removeDriver(_ driver: FavoriteDriver) {
        guard let databasePath = databaseFavoriteDrivers else {
            return
        }
        //  remove from local list
        //    Note: this must be done before the async removal from server because the displayed star image relies on this, and the image updates before the removal from the server.
        let id = driver.driverId
        FavoritesService.shared.removeFavorite(driver: id)
        print("Local list: \(FavoritesService.shared.favoriteDrivers)")
        
//        remove from server
        databasePath.child("driverId-\(driver.driverId)").removeValue { error, ref in
            if let error = error {
                print("error:\(error)")
            }
            print("the ref is:\(ref)")
        }
        return
    }
}

extension DriverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let teamList: [TeamElement] = driver?.teams ?? []
        return(teamList.count + 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0,
        let driver = driver {     // main cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainDriverCell", for: indexPath) as! MainDriverCell
            
            let name = driver.name?.components(separatedBy: " ")
            if let firstName = name?[0] {
                cell.firstName.text = firstName
            }
            if let lastName = name?[1] {
                cell.lastName.text = lastName
            }
            
            cell.abbr.text = driver.abbr
            
            Task { @MainActor in
                if let imageString = driver.image {
                    let posterImage = await F1Service.shared.getPosterImage(posterString: imageString)
                    cell.poster.image = posterImage
                }
            }

            if let countryName = driver.country?.name {
                cell.flag.image = F1Service.shared.getFlag(country: countryName)
            } else {
                if let countryCode = driver.country?.code {
                    cell.flag.image = F1Service.shared.getFlag(with: countryCode)
                } else {    //  no country name nor code
                    cell.flag.image = F1Service.shared.getFlag(country: "Israel")
                }
            }
            
            if let date = driver.birthdate {
                let birthDate = f1Service.convertDate(date)
                cell.birthDate.text = birthDate

            }
            cell.birthPlace.text = driver.birthplace
            
            if let grandsPrixEntered = driver.grandsPrixEntered {
                cell.numberOfGP.text = String(grandsPrixEntered)
            } else {
                cell.numberOfGP.text = "N/A"
                cell.numberOfGP.textColor = .lightGray
            }
            
            if let podiums = driver.podiums {
                cell.numberOfPodiums.text = String(podiums)
            } else {
                cell.numberOfPodiums.text = "N/A"
                cell.numberOfPodiums.textColor = .lightGray
            }
            
            if let championships = driver.worldChampionships {
                cell.numberOfChamps.text = String(championships)
            } else {
                cell.numberOfChamps.text = "N/A"
                cell.numberOfChamps.textColor = .lightGray
            }
            
            if let highestRacePosition = driver.highestRaceFinish?.position,
               let numberOfOccurrences = driver.highestRaceFinish?.number {
                cell.highestRacePosition.text = "\(String(highestRacePosition)) (x \(String(numberOfOccurrences)))"
            } else {
                cell.highestRacePosition.text = "N/A"
                cell.highestRacePosition.textColor = .lightGray
            }
            
            if let highestGridPosition = driver.highestGridPosition{
                cell.highestGridPosition.text = String(highestGridPosition)
            } else {
                cell.highestGridPosition.text = "N/A"
                cell.highestGridPosition.textColor = .lightGray
            }
            
            
            
            
            cell.favoriteTapped = { [weak self] in
                self?.favoriteTappedHandler(cell: cell)
                tableView.reloadData()
            }
            
            var plain = UIButton.Configuration.plain()
            plain.imagePadding = 10
            
            if let id = driver.id {
                if FavoritesService.shared.isFavorite(driverId: id) {
                    plain.image = UIImage(named: "star-on")
                } else {
                    plain.image = UIImage(named: "star-off")
                }
            }

            
            cell.favoriteStar.configuration = plain
            cell.favoriteStar.imageView?.layer.transform = CATransform3DMakeScale(0.3, 0.3, 0.3)
            
            
            return cell
        } else {    // team cells
            let cell = tableView.dequeueReusableCell(withIdentifier: "DriverTeamCell", for: indexPath) as! DriverTeamCell
            if let season = driver?.teams?[indexPath.row - 1].season,
               let team = driver?.teams?[indexPath.row - 1].team {
                cell.season.text = String(season)
                cell.teamName.text = team.name
                if let logo = team.logo {
                    Task {
                        let logoImage = await F1Service.shared.getPosterImage(posterString: logo)
                        cell.teamLogo.image = logoImage
                    }
                }
            }
            cell.layer.borderWidth = 0
            return cell
        }
    }
    
    func favoriteTappedHandler(cell: MainDriverCell) {
        if let driver = driver,
           let id = driver.id {
            
            let selectedDriver = FavoriteDriver(driverId: id)
            if !FavoritesService.shared.isFavorite(driverId: id) {
                addDriver(selectedDriver)
            } else {
                removeDriver(selectedDriver)
            }
            tableView.reloadRows(at: [IndexPath(row:0, section: 0)], with: .none)
            return
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 350
        } else {
            return 55
        }
    }
    
}


