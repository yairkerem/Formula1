//
//  TeamViewController.swift
//  Formula1
//
//  Created by Yair Kerem on 20/08/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class TeamViewController: UIViewController {

    @IBOutlet weak var teamLogo: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var firstTeamEntry: UILabel!
    @IBOutlet weak var championships: UILabel!
    @IBOutlet weak var highestRaceFinish: UILabel!
    @IBOutlet weak var polePositions: UILabel!
    @IBOutlet weak var fastestLaps: UILabel!
    @IBOutlet weak var president: UILabel!
    @IBOutlet weak var director: UILabel!
    @IBOutlet weak var engine: UILabel!
    @IBOutlet weak var favoriteStar: UIButton!
    private var isTeamFavorite = false
    
    @IBAction func favoriteTapped(_ sender: UIButton) { favoriteTappedHandler() }
    
    var team: TeamDetails? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let logo = team?.logo {
            Task { @MainActor in
                let logoImage = await F1Service.shared.getPosterImage(posterString: logo)
                self.teamLogo.image = logoImage
            }
        }
        
        teamName.text = team?.name
        location.text = team?.base
        if let firstTeamEntry = team?.firstTeamEntry {
            self.firstTeamEntry.text = String(firstTeamEntry)
        } else {
            self.firstTeamEntry.text = "N/A"
            self.firstTeamEntry.textColor = .lightGray
        }
        
        if let championships = team?.worldChampionships {
            self.championships.text = String(championships)
        } else {
            self.championships.text = "N/A"
            self.championships.textColor = .lightGray
        }
        
        if let highestRacePosition = team?.highestRaceFinish.position,
           let numberOfOccurrences = team?.highestRaceFinish.number {
            self.highestRaceFinish.text = "\(String(highestRacePosition)) (x \(String(numberOfOccurrences)))"
        } else {
            self.highestRaceFinish.text = "N/A"
            self.highestRaceFinish.textColor = .lightGray
        }
        
        if let polePositions = team?.polePositions {
            self.polePositions.text = String(polePositions)
        } else {
            self.polePositions.text = "N/A"
            self.polePositions.textColor = .lightGray
        }
        
        if let fastestLaps = team?.fastestLaps {
            self.fastestLaps.text = String(fastestLaps)
        } else {
            self.fastestLaps.text = "N/A"
            self.fastestLaps.textColor = .lightGray
        }
        
        president.text = team?.president
        director.text = team?.director
        engine.text = team?.engine
        
        if let id = team?.id {
            if FavoritesService.shared.isFavorite(teamId: id) {
                isTeamFavorite = true
            } else {
                isTeamFavorite = false
            }
        }
        
        favoriteStar.configurationUpdateHandler = { [weak self] button in
            guard let self = self else { return }
            var config = button.configuration
            config?.image = self.isTeamFavorite ? UIImage(named: "star-on") : UIImage(named: "star-off")
            button.configuration = config
        }
        
        favoriteStar.imageView?.layer.transform = CATransform3DMakeScale(0.3, 0.3, 0.3)
    }
    
    
    //    Firebase server: modify Favorite Status
    private lazy var databaseFavoriteTeams: DatabaseReference? = {
        // User Id
        guard let uid = Auth.auth().currentUser?.uid else {
//        guard let uid = UserDefaults.standard.string(forKey: userIdKey) else {    // written by Guy. why? perhaps because he didn't have access to the Firebase account
        print("No user in User Defaults")
            return nil
        }
        // reference
        let ref = Database.database().reference().child("users/\(uid)/favorites/teams")
        return ref
    }()
    
    let encoder = JSONEncoder()
    
    
    func addTeam(_ team: FavoriteTeam) {
        guard let databasePath = databaseFavoriteTeams else {
            return
        }
        do {    //  add to Firebase DB
            let data = try encoder.encode(team)
            let json = try JSONSerialization.jsonObject(with: data)
            databasePath.child("teamId-\(team.id)").setValue(json)
            
            //  add to local storage
            let id = team.id
            FavoritesService.shared.addFavorite(team: id)
            print("Local list: \(FavoritesService.shared.favoriteTeams)")

        } catch {
            print("Error: \(error)")
        }
        return
    }
    
    func removeTeam(_ team: FavoriteTeam) {
        guard let databasePath = databaseFavoriteTeams else {
            return
        }
        //  remove from local list
        //    Note: this must be done before the async removal from server because the displayed star image relies on this, and the image updates before the removal from the server.
        let id = team.id
        FavoritesService.shared.removeFavorite(team: id)
        print("Local list: \(FavoritesService.shared.favoriteTeams)")
        
//        remove from server
        databasePath.child("teamId-\(team.id)").removeValue { error, ref in
            if let error = error {
                print("error:\(error)")
            }
            print("the ref is:\(ref)")
        }
        return
    }
    
    func favoriteTappedHandler() {
        isTeamFavorite.toggle()
        if let team = team {
            let id = team.id
            if !FavoritesService.shared.isFavorite(teamId: id) {
                addTeam(FavoriteTeam(id: id))
            } else {
                removeTeam(FavoriteTeam(id: id))
            }
            
            return
        }
        
    }
}

