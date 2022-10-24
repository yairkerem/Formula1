//
//  StorageService.swift
//  Formula1
//
//  Created by Yair Kerem on 06/08/2022.
//

import Foundation
import UIKit

class StorageService {
    
    var caching = [Int : Driver]()
    
    var circuitPosterCachingNSCache = NSCache<NSNumber,UIImage>()
    var driverPosterCachingNSCache = NSCache<NSNumber,UIImage>()
    var teamPosterCachingNSCache = NSCache<NSNumber,UIImage>()
    
    
    
//    //  Firebase Server Storage
//    func addDriverToFavorites(id: Int) {
//
//    }
//
//    func removeDriverFromFavorites(id: Int) {
//
//    }
//
//    func addTeamToFavorites(id: Int) {
//
//    }
//
//    func removeTeamFromFavorites(id: Int) {
//
//    }
    
    func getFavorites() async -> FavoriteList? { //    belongs in fetcher service
        return nil
    }
    
    static func getDocumentsFolder() -> URL {
        //        FileManager.default.urls(for: .cachesDirectory, in: .localDomainMask)
        // Back up to iCloud
        let urls = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        return urls[0] // Only 1 documentDirectory
    }
    
    
    func getDriver(id: Int) async -> Driver? {
        var driver: Driver?
        
        if let cachedDriver = caching[id] {   // if driver is cached
            driver = cachedDriver
        } else {  // download driver from server
            
            driver = await FetcherService().getDriver(id: id)
            
            let driverUrl: URL = StorageService.getDocumentsFolder().appendingPathComponent(String(id))
            URLSession.shared.dataTask(with: driverUrl) { data, response, error in
                if let data = data {
                    do {
                        let cachedDriver = try JSONDecoder().decode(Driver.self, from: data)
                        print(cachedDriver)
                        driver = cachedDriver
                    } catch  (let error) {
                        print("## Parsing error: \(error.localizedDescription)")
                    }
                }
            }.resume()
        }
        
        return driver
    }

    
    static func saveDriver(data: Data, id: Int) {
        let driverFileName: URL = StorageService.getDocumentsFolder().appendingPathComponent(String(id))
        print(driverFileName)   //  to be deleted
        do {
            try data.write(to: driverFileName)
        } catch (let error) {
            print("Error:\(error)")
        }
    }
    
    
    
    //    Local Storage
    func getCircuitImage (circuitImage: String, circuit: Circuit) async -> UIImage? {
        if let circuitImageCached = circuitPosterCachingNSCache.object(forKey: circuit.id as NSNumber) {
            return(circuitImageCached)
        } else {
            if let circuitImageURL = URL(string: circuitImage) { // url from the sender
                let (data, _) = try! await URLSession.shared.data(from: circuitImageURL)
                let circuitImage = UIImage(data: data)
                return(circuitImage)
            }
        }
        return nil
    }
    
    func getDriverImage (driverImage: String, driver: Driver) async -> UIImage? {
        if let id = driver.id,
           let driverImageCached = driverPosterCachingNSCache.object(forKey: id as NSNumber) {
            return(driverImageCached)
        } else {
            if let driverImageURL = URL(string: driverImage) { // url from the sender
                let (data, _) = try! await URLSession.shared.data(from: driverImageURL)
                let driverImage = UIImage(data: data)
                return(driverImage)
            }
        }
        return nil
    }
    
    func getTeamImage (teamImage: String, team: TeamDetails) async -> UIImage? {
        if let teamImageCached = teamPosterCachingNSCache.object(forKey: team.id as NSNumber) {
            return(teamImageCached)
        } else {
            if let teamImageURL = URL(string: teamImage) { // url from the sender
                let (data, _) = try! await URLSession.shared.data(from: teamImageURL)
                let teamImage = UIImage(data: data)
                return(teamImage)
            }
        }
        return nil
    }
    
}

