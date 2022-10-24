//
//  RaceViewController.swift
//  Formula1
//
//  Created by Yair Kerem on 15/08/2022.
//

import UIKit

class RaceViewController: UIViewController {
    
    @IBOutlet weak var circuitName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var circuitImage: UIImageView!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var seasonPicker: UIPickerView!
    @IBOutlet weak var raceTypePicker: UIPickerView!
    
    @IBOutlet weak var buttonBackgroundImage: UIImageView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var notAvailable: UILabel!

    let fetch = FetcherService()
    
    var circuit: Circuit? = nil
    var selectedSeason: Int = 2012
    var selectedRaceType: String = RaceType.race.rawValue
    let seasonList = F1Service.shared.getSeasonList()
    let raceTypes: [String] = RaceType.allCases.map {$0.rawValue}
    var rankingListSize = 0
    var rankingList: [RaceRankingResult] = []
    var seasonSelectedFlag = false
    var raceTypeSelectedFlag = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        seasonPicker.dataSource = self
        seasonPicker.delegate = self
        raceTypePicker.dataSource = self
        raceTypePicker.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        circuitName.text = circuit?.name
        let city = circuit?.competition.location.city ?? ""
        let country = circuit?.competition.location.country
        if city != "" {
            let location = "\(city), \(country ?? "")"
            self.location.text = location
        } else {
            let location = country
            self.location.text = location
        }
        
        notAvailable.isHidden = true
        
        Task { @MainActor in
            if let imageString = circuit?.image {
                circuitImage.image = await F1Service.shared.getPosterImage(posterString: imageString)
            }
            flagImage.image = F1Service.shared.getFlag(country: circuit?.competition.location.country ?? "Israel")
            flagImage.layer.borderWidth = 0.3
            
            //            if let circuitId = circuit?.id {    // To Do: this should only be preformed after both UIPickers are used to select their values
            //                let raceId = await fetch.getRaceId(season: selectedSeason, circuit: circuitId, raceType: selectedRaceType)
            //                if let raceId = raceId {
            //                    let raceRankingList = await fetch.getRaceRankings(id: raceId)
            //                    self.rankingListSize = raceRankingList.count
            //                    self.rankingList = raceRankingList
            //                    print("Race ranking list:")
            //                    print(raceRankingList)
            //                }
            //            }
            
        }
    }
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        if let circuitId = circuit?.id {
//           seasonSelectedFlag,
//           raceTypeSelectedFlag {
            Task {
                await getRaceResults(circuitId: circuitId)
            }
//            print("seasonPicker = \(seasonPicker.), raceTypePicker = \()")
        }
    }
    
    func getRaceResults(circuitId: Int?) async {
        guard let circuitId = circuitId else {
            return
        }
        Task { 
            let raceId = await fetch.getRaceId(season: selectedSeason, circuit: circuitId, raceType: selectedRaceType)
            if let raceId = raceId {
                let raceRankingList = await fetch.getRaceRankings(id: raceId)
                self.rankingListSize = raceRankingList.count
                self.rankingList = raceRankingList
                
                seasonSelectedFlag = false
                raceTypeSelectedFlag = false
                notAvailable.isHidden = true
                tableView.isHidden = false
                tableView.reloadData()

            } else {
    //            check if the circuit did not host a Grand Prix in the selected season or only this specific race type (e.d sprint)
                if (await fetch.getRaceId(season: selectedSeason, circuit: circuitId, raceType: RaceType.race.rawValue)) != nil {
                    notAvailable.text = "\(circuit?.name ?? "This circuit") did not host a \(selectedRaceType) session in \(String(selectedSeason))."
                } else {
                    notAvailable.text = "\(circuit?.name ?? "This circuit") did not host a Grand Prix in \(String(selectedSeason))."
                }
                notAvailable.isHidden = false
                tableView.isHidden = true
            }
        }
        
    }
}


extension RaceViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == seasonPicker {
            return seasonList.count
        } else {    // pickerView == raceTypePicker
            return raceTypes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == seasonPicker {
            return String(seasonList[row])
        } else {    // pickerView == raceTypePicker
            return raceTypes[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == seasonPicker {
            selectedSeason = seasonList[row]
//            seasonSelectedFlag = true
        } else {    // pickerView == raceTypePicker
            selectedRaceType = raceTypes[row]
//            raceTypeSelectedFlag = true
        }
    }
}


extension RaceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingListSize
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverRaceCell", for: indexPath) as! DriverRaceCell
        
        // provide driver details to segue
        let driver = rankingList[indexPath.row].driver
        Task {
            cell.driverDetails = await fetch.getDriver(id: driver.id)
        }
        
        cell.driverName.text = rankingList[indexPath.row].driver.name
        cell.teamName.text = rankingList[indexPath.row].team.name
        cell.position.text = String(rankingList[indexPath.row].position)
        cell.time.text = rankingList[indexPath.row].time
        
        return cell
    }
}


extension RaceViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DriverViewController,
           let senderCell = sender as? DriverRaceCell {
            destination.driver = senderCell.driverDetails
        }
    }
}
