//
//  CircuitListViewController.swift
//  Formula1
//
//  Created by Yair Kerem on 08/08/2022.
//

import UIKit

class CircuitListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let fetch = FetcherService()
    let storage = StorageService()
//    let f1Service = F1Service()
    
    var listToShow: [Circuit] = []
    var circuit: Circuit? = nil
    
    
    @IBOutlet weak var searchController: UISearchBar!
    
    var searchTask: Task<(), Never>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        searchController.delegate = self
        
        Task {
            //test:
//            let driver = await StorageService().getDriver(id: 1)

            let circuits = await fetch.getAllCircuits()
            self.listToShow = circuits
            self.tableView.reloadData()
        }
        
    }
}


extension CircuitListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CircuitCell", for: indexPath) as! CircuitCell
        
        let circuit = listToShow[indexPath.row]
        cell.circuitInCell = circuit
        cell.name.text = circuit.name
        let city = circuit.competition.location.city ?? ""
        let country = circuit.competition.location.country
        if city != "" {
            let location = "\(city), \(country)"
            cell.location.text = location
        } else {
            let location = country
            cell.location.text = location
        }
        
        
        
        Task {
            if let posterImageCached = await storage.getCircuitImage(circuitImage: circuit.image, circuit: circuit) {
                
                DispatchQueue.main.async {
                    self.storage.circuitPosterCachingNSCache.setObject(posterImageCached, forKey: circuit.id as NSNumber)
                    cell.poster.image = posterImageCached
                }
            }
        }
        cell.flag.image = F1Service.shared.getFlag(country: circuit.competition.location.country )
        cell.flag.layer.borderWidth = 0.3

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView
        
//        cell.contentView.backgroundColor = UIColor.white
//        cell.contentView.alpha = 1.0
//        cell.layer.backgroundColor =  UIColor.white.cgColor

//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 150
        
        return cell
    }
}

extension CircuitListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? RaceViewController,
        let senderCell = sender as? CircuitCell {
            destination.circuit = senderCell.circuitInCell
        }
    }
}

extension CircuitListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchTask = searchTask {
            searchTask.cancel()
        }
        searchTask = Task { @MainActor in
            do {
                if Task.isCancelled { return }
                try await Task.sleep(nanoseconds: NSEC_PER_SEC/2)
                if Task.isCancelled {
                    return
                }
                let circuits = await fetch.searchCircuit(containing: searchController.text) // {
                    self.listToShow = circuits
                    self.tableView.reloadData()
//                }
                if searchText == "" {
                    self.listToShow = await fetch.getAllCircuits()
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error)
            }
        }
        self.tableView.reloadData()
    }

}
