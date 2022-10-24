//
//  DriverListViewController.swift
//  Formula1
//
//  Created by Yair Kerem on 08/08/2022.
//

import UIKit

class DriverListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let fetch = FetcherService()
    let storage = StorageService()
    //    let f1Service = F1Service()
    
    var listToShow: [Driver?] = []
    
    @IBOutlet weak var searchController: UISearchBar!
    var searchTask: Task<(), Never>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchController.delegate = self
        
        Task { @MainActor in
            //            let driver = await fetch.getDriver(id: 1)
            //            let flag = f1Service.getFlag(country: (driver?.country?.name)!)
            //            let flag = f1Service.getFlag(country: "Israel")
            do {
                let drivers = try await fetch.getAllDrivers()
                self.listToShow = drivers
                print(listToShow)
                self.tableView.reloadData()
            } catch (let error) {
                print("DriverListViewController Error in drivers: \(error)")
            }
        }
    }
}


extension DriverListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverCell", for: indexPath) as! DriverCell
        let driver = listToShow[indexPath.row]
        cell.driverInCell = driver
        let name = driver?.name?.components(separatedBy: " ")
        if let firstName = name?[0] {
            cell.firstName.text = firstName
        }
        if let lastName = name?[1] {
            cell.lastName.text = lastName
        }
        cell.abbr.text = driver?.abbr
       
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView
        
        Task { @MainActor in
            if let driver = driver,
               let image = driver.image,
               let id = driver.id,
               let posterImageCached = await storage.getDriverImage(driverImage: image, driver: driver) {
                
//                DispatchQueue.main.async {    // commented out because the @MainActor seams to work faster
                    self.storage.driverPosterCachingNSCache.setObject(posterImageCached, forKey: id as NSNumber)
                    cell.poster.image = posterImageCached
//                }
            }
        }

        if let countryName = driver?.country?.name {
            cell.flag.image = F1Service.shared.getFlag(country: countryName)
        } else {
            if let countryCode = driver?.country?.code {
                cell.flag.image = F1Service.shared.getFlag(with: countryCode)
            } else {    //  no country name nor code
                cell.flag.image = F1Service.shared.getFlag(country: "Israel")
            }
        }
        
        return cell
        
    }
}

extension DriverListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let searchTask = searchTask {
            searchTask.cancel()
        }
        searchTask = Task {
            do {
                if Task.isCancelled { return }
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC/2)
                if Task.isCancelled {
                    return
                }
                let drivers = await fetch.searchDriver(containing: searchController.text) // {
                if Task.isCancelled {
                    return
                }
                self.listToShow = drivers
                self.tableView.reloadData()
                //                }
                if searchText == "" {
                    self.listToShow = try await fetch.getAllDrivers()
                    if Task.isCancelled {
                        return
                    }
                    self.tableView.reloadData()
                }
            } catch (let error) {
                print("searchBar error in search: \(error)")
            }
        }
        self.tableView.reloadData()
    }
}

extension DriverListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DriverViewController,
           let senderCell = sender as? DriverCell {
            destination.driver = senderCell.driverInCell
        }
    }
}
