//
//  F1Service.swift
//  Formula1
//
//  Created by Test2 on 08/08/2022.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseMessaging

class F1Service {
    static let shared: F1Service = F1Service()
    
    private init() {
        //Making the init private prevents us from creating an instance of F1Service and forces us to use the shared singleton instead. The init is empty because we have nothing to initialize. If we didn't give defaultFlagImage a value in its declaration for example we would have needed to set it here.
        
    }
    
    let firstSeason = 2012 // determined in the server
    let mostRecentSeason = 2022
    var selectedSeason: Int = 0
    
    func getSeasonList() -> [Int] {
        var seasonList: [Int] = []
        for season in Range(firstSeason...mostRecentSeason) {
            seasonList.append(season)
        }
        return seasonList
    }
    
    let fetch = FetcherService()
    let defaultFlagImage = UIImage(named: "IL")
    
    func getPosterImage(posterString: String) async -> UIImage? {
        guard let path = fetch.imageUrl(for: posterString) else {
            return nil
        }
        let (data, _) = try! await URLSession.shared.data(from: path)
        if let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    func getRandomBackgroundImage() -> String {
        let imageList = [
            "https://wallpaper.dog/large/20502172.jpg",
            "https://i.pinimg.com/564x/27/9d/2d/279d2d8fd4254d94f6f6766973a92b84.jpg",
            "https://wallpaper.dog/large/20502169.jpg",
            "https://wallpaper.dog/large/20502217.jpg",
            "https://i.pinimg.com/originals/0b/85/50/0b85505733ccc23306162af4cf7b8939.jpg",
            "https://w0.peakpx.com/wallpaper/132/787/HD-wallpaper-red-bull-racing-car-f1-formula-formula-one-formula1-formule-max-verstappen-rb16-speed-sport.jpg",
            "https://wallpaper.dog/large/20502168.jpg",
            "https://w0.peakpx.com/wallpaper/865/482/HD-wallpaper-senna-today-art-ayrton-ayrton-senna-f1-fia-formula-1-formula1-motorsports.jpg",
            "https://pbs.twimg.com/media/EjK0_mTXYAsdZKU.jpg",
            "https://i.pinimg.com/originals/a3/b0/e5/a3b0e50f690b21cbd69f1259c55c7909.jpg",
            "https://w0.peakpx.com/wallpaper/748/900/HD-wallpaper-hamilton-panther-black-car-cars-f1-hamilton-lewis-negra-pantera-panther-wakanda.jpg",
            "https://cdn.wallpapersafari.com/94/11/h5HC09.jpg",
            "https://i.pinimg.com/originals/ca/63/9e/ca639ec209bcf4fcd1b450cd9ce54504.jpg",
            "https://i.pinimg.com/474x/ce/59/38/ce59388486b1f8af872ca058d99b3cd2.jpg",
            "https://media.gettyimages.com/photos/michael-schumacher-of-germany-and-ferrari-during-first-qualifying-picture-id52578408?s=612x612",
        ]
        let randomImageNumber = Int.random(in: 0..<imageList.count)
        return imageList[randomImageNumber]
    }
    
    func convertDate(_ date: String) -> String {
        let dateArray = date.components(separatedBy: "-")
        if dateArray.count != 3 {
            return date
        }
        //   convert to Int (and back to String) to remove leading 0
        if  let year = Int(dateArray[0]),
            let month = Int(dateArray[1]),
            let day = Int(dateArray[2]) {
            let newDateString = "\(String(day)).\(String(month)).\(String(year))"
            return newDateString
        }
        return(date)
    }
    
    
    func isFavorite(Driver id: Int) -> Bool {
        
        return false
    }
    
    func isFavorite(Team id: Int) -> Bool {
        
        return false
    }
    
    
    func getFlag(country: String) -> UIImage? {
        let locale = Locale(identifier: "en_US_POSIX")
        if let imageCode = locale.isoCode(for: country),
           let image = UIImage(named: imageCode) {
            return image
        } else {
            switch country {    //  the following flags are not delivered properly from the server, so they are assigned manually
            case "Great Britain":
                if let image = UIImage(named: "GB") {
                    return (image)
                }
            case "China":
                if let image = UIImage(named: "CN") {
                    return (image)
                }
            case "USA":
                if let image = UIImage(named: "US") {
                    return (image)
                }
            case "Abu Dhabi":
                if let image = UIImage(named: "AE") {
                    return (image)
                }
            case "Saudi Arabia ":       //  the ending space is intentional; that's what the server provides
                if let image = UIImage(named: "SA") {
                    return (image)
                }
            default:
                return defaultFlagImage!
            }
        }
        return defaultFlagImage!
    }
    
    
    func getFlag(with countryCode: String) -> UIImage? {
        _ = Locale(identifier: "en_US_POSIX")
        if let image = UIImage(named: countryCode) {
            return image
        }
        return defaultFlagImage!
    }

}



// MARK: - Locale
extension Locale {  //  the locale affects the country codes used to fetch flag images
    func isoCode(for countryName: String) -> String? {
        return Locale.isoRegionCodes.first(where: { (code) -> Bool in
            localizedString(forRegionCode: code)?.compare(countryName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        })
    }
}


