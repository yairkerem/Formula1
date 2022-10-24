//
//  Models.swift
//  Formula1
//
//  Created by Test2 on 01/08/2022.
//

import Foundation

// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation


struct SeasonResponse: Codable {
    let response: [Int]
}


// MARK: - Parameters
struct Parameters: Codable {
    let search: String
}

// MARK: - DriverResponse
struct DriverResponse: Codable {
    let response: [Driver]
}
// MARK: - Driver
struct Driver: Codable {
    let id: Int?
    let name: String?
    let abbr: String?
    let image: String?
    let nationality: String?
    let country: Country?
    let birthdate, birthplace: String?
    let number, grandsPrixEntered, worldChampionships, podiums: Int?
    let highestRaceFinish: HighestRaceFinish?
    let highestGridPosition: Int?
    let careerPoints: String?
    let teams: [TeamElement]?
    
    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, name, abbr, image, nationality, country, birthdate, birthplace, number
        case grandsPrixEntered = "grands_prix_entered"
        case worldChampionships = "world_championships"
        case podiums
        case highestRaceFinish = "highest_race_finish"
        case highestGridPosition = "highest_grid_position"
        case careerPoints = "career_points"
        case teams
    }
}

// MARK: - Country
struct Country: Codable {
    let name: String?
    let code: String
}

// MARK: - HighestRaceFinish
struct HighestRaceFinish: Codable {
    let position, number: Int?
}

// MARK: - TeamElement
struct TeamElement: Codable {
    let season: Int
    let team: TeamTeam
}

// MARK: - TeamTeam
struct TeamTeam: Codable {
    let id: Int?
    let name: String?
    let logo: String?
}

// MARK: - TeamResultResponse
struct TeamResultResponse: Codable {
    let response: [TeamResult]
}

// MARK: - TeamResult
struct TeamResult: Codable {
    let position: Int?
    let team: TeamTeam?
    let points, season: Int?
}


// MARK: - DriverResultResponse
struct DriverResultResponse: Codable {
    let response: [DriverResult]
}
// MARK: - DriverResult
struct DriverResult: Codable {
    let position: Int?
    let driver: Driver?
    let team: TeamTeam?
//    let points: Int?
    let points: String?
    //    let wins, behind: JSONNull?
    let season: Int?
    
    private enum CodingKeys: String, CodingKey {
        case position, driver, team, points, season
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        position = try container.decode(Int.self, forKey: .position)
        driver = try container.decode(Driver.self, forKey: .driver)
        team = try container.decode(TeamTeam.self, forKey: .team)
        season = try container.decode(Int.self, forKey: .season)
        if let pointStr = try? container.decode(String.self, forKey: .points) {
            self.points = pointStr
        } else if let pointsInt = try? container.decode(Int.self, forKey: .points) {
            self.points = "\(pointsInt)"
        } else {
            self.points = ""
        }
    }
}

enum Points: Codable {
    case integer(Int)
    case string(String)
    case null
}

// MARK: - CircuitResponse
struct CircuitResponse: Codable {
    let response: [Circuit]
}

// MARK: - Circuit
struct Circuit: Codable {
    let id: Int
    let name: String
    let image: String
    let competition: Competition
    let firstGrandPrix, laps: Int
    let length, raceDistance: String
    let lapRecord: LapRecord
    let capacity, opened: Int?
    let owner: String?

    enum CodingKeys: String, CodingKey {
        case id, name, image, competition
        case firstGrandPrix = "first_grand_prix"
        case laps, length
        case raceDistance = "race_distance"
        case lapRecord = "lap_record"
        case capacity, opened, owner
    }
}

struct DisplayedCircuit {
    let id: Int
    let name: String
    let location: String
    let flagImage: String
    let circuitImage: String
}

// MARK: - RaceCircuit
struct RaceCircuit: Codable {
    let id: Int
    let name: String
    let image: String
}

// MARK: - Competition
struct Competition: Codable {
    let id: Int
    let name: String
    let location: Location
}

// MARK: - Location
struct Location: Codable {
    let country: String
    let city: String?
}

// MARK: - LapRecord
struct LapRecord: Codable {
    let time, driver, year: String?
}

// MARK: - RaceRankingResultResponse
struct RaceRankingResultResponse: Codable {
    let response:  [RaceRankingResult]
}

// MARK: - RaceRankingResult
struct RaceRankingResult: Codable {
    let race: Race
    let driver: RaceResultDriver
    let team: TeamTeam
    let position: Int
    let time: String?
    let laps: Int
    let gap: String?
}

// MARK: - RaceResultDriver
struct RaceResultDriver: Codable {
    let id: Int
    let name, abbr: String
    let number: Int
    let image: String
}

// MARK: - Race
struct Race: Codable {
    let id: Int
}


// MARK: - TeamDetailsResponse
struct TeamDetailsResponse: Codable {
    let response: [TeamDetails]
}

// MARK: - TeamDetails
struct TeamDetails: Codable {
    let id: Int
    let name: String
    let logo: String
    let base: String?
    let firstTeamEntry, worldChampionships: Int?
    let highestRaceFinish: HighestRaceFinish
    let polePositions, fastestLaps: Int?
    let president, director: String
    let technicalManager, chassis: String?
    let engine: String
    let tyres: Tyres
    
    var isFavorite: Bool? = false

    enum CodingKeys: String, CodingKey {
        case id, name, logo, base
        case firstTeamEntry = "first_team_entry"
        case worldChampionships = "world_championships"
        case highestRaceFinish = "highest_race_finish"
        case polePositions = "pole_positions"
        case fastestLaps = "fastest_laps"
        case president, director
        case technicalManager = "technical_manager"
        case chassis, engine, tyres
        case isFavorite
    }
}

enum Tyres: String, Codable {
    case bridgestonePirelli = "Bridgestone, Pirelli"
    case michelin = "Michelin"
    case pirelli = "Pirelli"
}

enum RaceType: String, CaseIterable {
    case race = "Race"
    case sprint = "Sprint"
    case q1 = "1st Qualifying"
    case q2 = "2nd Qualifying"
    case q3 = "3rd Qualifying"
    case p1 = "1st Practice"
    case p2 = "2nd Practice"
    case p3 = "3rd Practice"
}


// MARK: - RaceResponse
struct RaceResultResponse: Codable {
    let response: [RaceResult]
}


// MARK: - RaceResult
struct RaceResult: Codable {
    let id: Int
    let competition: Competition
    let circuit: RaceCircuit
    let season: Int
    let type: String
    let laps: Laps
    let fastestLap: FastestLap
    let distance, timezone: String
    let date: String //Date
//    let weather: JSONNull?
    let status: String

    enum CodingKeys: String, CodingKey {
        case id, competition, circuit, season, type, laps
        case fastestLap = "fastest_lap"
        case distance, timezone, date, status
    }
}


// MARK: - FastestLap
struct FastestLap: Codable {
    let driver: Driver
//    let time: JSONNull?
}


// MARK: - Laps
struct Laps: Codable {
//    let current: JSONNull?
    let total: Int
}

// MARK: - Favorite Driver
struct FavoriteDriver: Codable {
    let driverId: Int
}

// MARK: - Favorite Team
struct FavoriteTeam: Codable {
    let id: Int
}

// MARK: - FavoriteList
struct FavoriteList: Codable {
    let drivers: [Driver]
    let teams: [TeamDetails]
}


