//
//  FavoritesService.swift
//  Formula1
//
//  Created by Yair Kerem on 19/09/2022.
//

import Foundation

class FavoritesService {
    static let shared: FavoritesService = FavoritesService()
    
    private init() {
        
    }
    
    var favoriteDrivers: [Int] = []
    var favoriteTeams: [Int] = []
    
    //    Drivers
    func addFavorite(driver id: Int) {
        if !isFavorite(driverId: id) {
            favoriteDrivers.append(id)
            print("Driver \(id) added to local list of favorite drivers")
        }
        return
    }
    
    func removeFavorite(driver id: Int) {
        if isFavorite(driverId: id) {
            if let index = favoriteDrivers.firstIndex(where: {$0 == id} ) {
                favoriteDrivers.remove(at: index)  //  force unwrapping because we know the driver is in the list (it was checked by isFavorite)
                print("Driver \(id) removed from local list of favorite drivers")
            }
        }
        return
    }
    
    
    func isFavorite(driverId: Int) -> Bool {
        print(favoriteDrivers)
        if let _ = favoriteDrivers.firstIndex(where: {$0 == driverId} ) {
            return true
        }
        return false
    }
    
    
    //    Teams
    func addFavorite(team id: Int) {
        if !isFavorite(teamId: id) {
            favoriteTeams.append(id)
            print("Team \(id) added to local list of favorite teams")
        }
        return
    }
    
    func removeFavorite(team id: Int) {
        if isFavorite(teamId: id) {
            if let index = favoriteTeams.firstIndex(where: {$0 == id} ) {
                favoriteTeams.remove(at: index)  //  force unwrapping because we know the driver is in the list (it was checked by isFavorite)
                print("Team \(id) removed from local list of favorite teams")
            }
        }
        return
    }
    
    
    func isFavorite(teamId: Int) -> Bool {
        if let _ = favoriteTeams.firstIndex(where: {$0 == teamId} ) {
            return true
        }
        return false
    }
}
