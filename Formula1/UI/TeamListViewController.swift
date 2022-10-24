//
//  TeamListViewController.swift
//  Formula1
//
//  Created by Yair Kerem on 12/08/2022.
//

import UIKit
import CoreMedia

class TeamListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let fetch = FetcherService()
    let storage = StorageService()
//    let f1Service = F1Service()
    
    var listToShow: [TeamDetails] = []
    
    @IBOutlet weak var searchController: UISearchBar!
    var searchTask: Task<(), Never>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        searchController.delegate = self
        
        Task { @MainActor in
            do {
                let teams = try await fetch.getAllTeams()
                self.listToShow = teams
                self.tableView.reloadData()
            } catch (let error) {
                print("TeamListViewController Error in teams: \(error)")
            }
            
        }
    }
 
}



extension TeamListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as! TeamCell
        let team = listToShow[indexPath.row]
        cell.teamInCell = team
        cell.teamName.text = team.name
        cell.location.text = team.base
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView
        
        Task {
            if let posterImageCached = await storage.getTeamImage(teamImage: team.logo, team: team) {
                
                DispatchQueue.main.async {
                    self.storage.teamPosterCachingNSCache.setObject(posterImageCached, forKey: team.id as NSNumber)
                    cell.logo.image = posterImageCached
                }
            }
        }

        return cell
    }
}


extension TeamListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if let searchTask = searchTask {
            searchTask.cancel()
        }
        searchTask = Task {
            do {
                if Task.isCancelled { return }
                try await Task.sleep(nanoseconds: NSEC_PER_SEC/2)
                if Task.isCancelled {
                    return
                }
                let teams = await fetch.searchTeam(containing: searchController.text) // {
                    self.listToShow = teams
                    self.tableView.reloadData()

                if searchText == "" {
                    self.listToShow = try await fetch.getAllTeams()
                    self.tableView.reloadData()
                }
            } catch let error {
                print("TeamListViewController error: \(error)")
            }
        }
        self.tableView.reloadData()
    }
}

extension TeamListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TeamViewController,
        let senderCell = sender as? TeamCell {
            destination.team = senderCell.teamInCell
        }
    }
}
