//
//  FetcherService.swift
//  Formula1
//
//  Created by Yair Kerem on 01/08/2022.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
import CoreVideo
#endif

let numberOfCircuits = 31
let numberOfDrivers = 89 //  use only 19 due to server requests-per-minute limitation (there are 89 drivers)
let fetchTimeoutInterval = 60.0
let basicURLString = "https://v1.formula-1.api-sports.io"

struct FetcherService {
    func getSeasons() async -> [Int]{
        
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/seasons")!)
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let seasons = try JSONDecoder().decode(SeasonResponse.self, from: data)
            return(seasons.response)
        } catch {
            print("getSeasons Error: \(error)")
        }
        return[]
    }
    
    func getDriver(id: Int) async -> Driver? {
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/drivers?id=\(id)")!)
        
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            
            //            print(String(data: data, encoding: .utf8))
            let driver = try JSONDecoder().decode(DriverResponse.self, from: data)
            if let firstDriver = driver.response.first {
                return firstDriver
            }
            //            if driver.response[0] != nil { // find another way to make sure response[0] exists
            //                return(driver.response[0])
            //            }
        } catch {
            print("getDriver Error: \(error)")
        }
        return nil
    }
    
    func searchDriver(containing searchText: String?) async -> [Driver] {
        guard let searchText = searchText,
              searchText.count >= 3 else { //minimal requirement for search query (from server)
            return []
        }
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/drivers?search=\(searchText)")!)
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let driver = try JSONDecoder().decode(DriverResponse.self, from: data)
            print(driver.response)
            return(driver.response)
            
        }
        catch {
            print("searchDriver Error: \(error)")
        }
        return []
    }
    
    func getAllDrivers() async throws -> [Driver] {
        let drivers = try await withThrowingTaskGroup(of: Driver?.self) { group -> [Driver?] in
            for index in 1...numberOfDrivers {
                group.addTask {
                    let driver = await getDriver(id: index)
                    return driver
                }
            }
            var allDrivers = [Driver?]()
            do {
                for try await value in group {
                    allDrivers.append(value)
                }
            } catch {
                print("Not able to create ")
            }
            
            let favoriteUserData = try await FirebaseRefHelper.databaseFavoriteDrivers?.getData()
            
            var favoriteDrivers = [FavoriteDriver]()
            if let dictionary = favoriteUserData?.value as? [String: Any] {
                dictionary.keys.forEach { currentKey in
                    favoriteDrivers.append(FavoriteDriver(driverId: Int(currentKey.deletingPrefix("driverId-"))!))

                    if let id = Int(currentKey.deletingPrefix("driverId-")) {
                        FavoritesService.shared.addFavorite(driver: id)
                    }
                }
            }
            
            if !favoriteDrivers.isEmpty{
                let newDriverRanking = allDrivers.map { driveResult -> Driver? in
                    if let driveResult = driveResult {
                        var driver = driveResult
                        if let _ = favoriteDrivers.first(where: {$0.driverId == driver.id ?? -1 }) {
                            driver.isFavorite = true
                        }
                        return driver
                    } else {
                        return nil
                    }
                }
                allDrivers = newDriverRanking
            }
            
            print("AllDrivers:\(allDrivers)")
            
            
            return allDrivers
        }
        let verifiedDrivers = drivers.compactMap{($0)}
        return verifiedDrivers
    }
    
    
    func getAllFavoriteDrivers() async -> [Driver] {
        //        The following is here as a demonstration of an alternate implementation:
        //        return await getAllDrivers().filter({ driver in
        //            return driver.isFavorite
        //        })
        do {
            return try await getAllDrivers().filter{ $0.isFavorite }
        } catch (let error) {
            print("getAllFavoriteDrivers error:\(error)")
            return  [Driver]()
        }
    }
    
    
    func getTeamRankings(season: Int) async -> [TeamResult] {
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/rankings/teams?season=\(season)")!)
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let teamRankings = try JSONDecoder().decode(TeamResultResponse.self, from: data)
            //            print(teamRankings.response)
            return(teamRankings.response)
        }
        catch {
            print("getTeamRankings Error: \(error)")
        }
        return []
    }
    
    func getDriverRankings(season: Int) async -> [DriverResult] {
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/rankings/drivers?season=\(season)")!)
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let driverRankings = try JSONDecoder().decode(DriverResultResponse.self, from: data)
            return(driverRankings.response)
        }
        catch {
            print("getDriverRankings Error: \(error.localizedDescription)")
            print("Request = \(request)")
        }
        return []
    }
    
    func getRaceRankings(id: Int) async -> [RaceRankingResult] {
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/rankings/races?race=\(id)")!)
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let driverRankings = try JSONDecoder().decode(RaceRankingResultResponse.self, from: data)
            
            return(driverRankings.response)
        }
        catch {
            print("getRaceRankings Error: \(error)")
        }
        print("Failed to load race rankings")
        return []
    }
    
    
    func getRaceId(season: Int, circuit: Int, raceType: String) async -> Int? {
        print("\(basicURLString)/races?circuit=\(circuit)&season=\(season)&type=\(raceType)") // temporary: for debugging
        guard let url = URL(string: "\(basicURLString)/races?circuit=\(circuit)&season=\(season)&type=\(raceType)") else {
            print ("Race did not take place")
            return nil
        }
        
        var id: Int? = nil
        let request = buildGetRequestHeaders(url: url)
        print(request)
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let race = try JSONDecoder().decode(RaceResultResponse.self, from: data)
            if let raceId = race.response.first?.id {
                print("race ID ====== \(raceId)")
                id = raceId
                return raceId
            }
            else {
                return nil
            }
        }
        catch {
            print("getRaceId Error: \(error)")
        }
        print("Failed to load race results")
        return id
    }
    
    
    
    func getAllCircuits() async -> [Circuit] {
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/circuits")!)
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let circuits = try JSONDecoder().decode(CircuitResponse.self, from: data)
            return(circuits.response)
        }
        catch {
            print("getCircuits Error: \(error)")
        }
        return []
    }
    
    func getCircuit(id: Int) async -> Circuit? {
        if id < 1 || id > numberOfCircuits {
            return nil
        }
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/circuits/?id=\(id)")!)
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let circuits = try JSONDecoder().decode(CircuitResponse.self, from: data)
            return(circuits.response[0])
        }
        catch {
            print("getCircuits Error: \(error)")
        }
        return nil
    }
    
    func searchCircuit(containing searchText: String?) async -> [Circuit] {
        guard let searchText = searchText,
              searchText.count >= 3 else { //minimal requirement for search query (from server)
            return []
        }
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/circuits/?search=\(searchText)")!)
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let circuits = try JSONDecoder().decode(CircuitResponse.self, from: data)
            return(circuits.response)
            
        }
        catch {
            print("searchCircuit Error: \(error)")
        }
        return []
    }
    
    
    func getAllTeams() async throws -> [TeamDetails] {
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/teams")!)
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let teams = try JSONDecoder().decode(TeamDetailsResponse.self, from: data)
            return(teams.response)      // this used to work, and the request still works fine with Postman, but here we get 0 responses
        }
        catch {
            print("getAllTeams Error: \(error)")
        }
        return []
    }
    
//     TO DO:
    func getAllFavoriteTeams() async -> [TeamDetails] {
        do {
            return try await getAllTeams().filter{ $0.isFavorite ?? false }
        } catch (let error) {
            print("getAllFavoriteTeams error:\(error)")
            return  [TeamDetails]()
        }
        
//        return await getAllTeams().filter{ $0.isFavorite ?? false }
    }
    
    
    func searchTeam(containing searchText: String?) async -> [TeamDetails] {
        guard let searchText = searchText,
              searchText.count >= 3 else { //minimal requirement for search query (from server)
            return []
        }
        
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/teams/?search=\(searchText)")!)
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let teams = try JSONDecoder().decode(TeamDetailsResponse.self, from: data)
            print(teams.response)
            return(teams.response)
            
        }
        catch {
            print("searchTeam Error: \(error)")
        }
        return []
    }
    
    
    func getTeam(id: Int) async -> TeamDetails? {
        let request = buildGetRequestHeaders(url: URL(string: "\(basicURLString)/teams/?id=\(id)")!)
        
        do {
            let (data,_) = try await URLSession.shared.data(for: request)
            let teams = try JSONDecoder().decode(TeamDetailsResponse.self, from: data)
            if let firstTeam = teams.response.first {
                return(firstTeam)
            } else {
                print("error loading team details")
                return nil
            }
        }
        catch {
            print("getTeam Error: \(error)")
        }
        return nil
    }
    
    
    func imageUrl(for path: String) -> URL? {
        URL(string: path)
    }
    
    func buildGetRequestHeaders(url: URL) -> URLRequest {
        var request = URLRequest(url: url,timeoutInterval: fetchTimeoutInterval)
        
        request.addValue("d95ca2b0d8e23187f8a60467ab9e3fb0",
                         forHTTPHeaderField: "x-rapidapi-key")
        request.addValue("v1.formula-1.api-sports.io", forHTTPHeaderField: "x-rapidapi-host")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        return request
    }
}


extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
