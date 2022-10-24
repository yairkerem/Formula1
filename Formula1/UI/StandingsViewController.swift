//
//  StandingsViewController.swift
//  Formula1
//
//  Created by Yair Kerem on 13/08/2022.
//

import UIKit

class StandingsViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var seasonHeader: UILabel!

    let fetch = FetcherService()
//    let season = F1Service.shared.selectedSeason
    enum ListSelection {
        case drivers, teams
    }
    var listSelection: ListSelection = .drivers
    var driverStandingsList: [DriverResult] = []
    var teamStandingsList: [TeamResult] = []

    @IBOutlet weak var standingsSegmentedControl: UISegmentedControl!
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            listSelection = .drivers
        case 1:
            listSelection = .teams
        default:
            listSelection = .drivers
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        var season: Int {
            return F1Service.shared.selectedSeason
        }
        tableView.dataSource = self
        tableView.delegate = self
        
        Task { @MainActor in
            driverStandingsList = await fetch.getDriverRankings(season: season)
            teamStandingsList = await fetch.getTeamRankings(season: season)
            
            seasonHeader.text = String(season)
            tableView.reloadData()
            
        }
        
        standingsSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        
    }
}

extension StandingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listSelection == .drivers {
            return driverStandingsList.count
        } else if listSelection == .teams {
            return teamStandingsList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if listSelection == .drivers {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DriverRankCell", for: indexPath) as! DriverRankCell
            
            // provide driver details to segue
            let driver = driverStandingsList[indexPath.row].driver
            Task {
                if let id = driver?.id {
                    cell.driverDetails = await fetch.getDriver(id: id)
                }
            }
            
            cell.driverName.text = driverStandingsList[indexPath.row].driver?.name
            cell.teamName.text = driverStandingsList[indexPath.row].team?.name
            if let position = driverStandingsList[indexPath.row].position{
                cell.position.text = String(position)
            }
            
            if let points = driverStandingsList[indexPath.row].points {
                cell.score.text = points
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamRankCell", for: indexPath) as! TeamRankCell
            cell.teamName.text = teamStandingsList[indexPath.row].team?.name
            
            let team = teamStandingsList[indexPath.row].team
            Task {
                if let id = team?.id {
                    cell.teamDetails = await fetch.getTeam(id: id)
                }
            }
            
            if let position = teamStandingsList[indexPath.row].position{
                cell.position.text = String(position)
            }
            if let points = teamStandingsList[indexPath.row].points {
                cell.score.text = String(points)
            }
            return cell
        }
    }
    
    private func handlePoints(_ points: Points) -> String {
        switch points {
        case .integer(let numberInt): return "\(numberInt)"
        case .string(let numberStr): return numberStr
        case .null: return  "undefined"
        }
    }
}


extension StandingsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DriverViewController,
        let senderCell = sender as? DriverRankCell {
            destination.driver = senderCell.driverDetails
        }
        if let destination = segue.destination as? TeamViewController,
        let senderCell = sender as? TeamRankCell {
            destination.team = senderCell.teamDetails
        }
    }
}
