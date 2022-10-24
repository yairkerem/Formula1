//
//  FirebaseRefHelper.swift
//  Formula1
//
//  Created by Guy Cohen on 12/09/2022.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class FirebaseRefHelper {
    static var databaseFavoriteDrivers: DatabaseReference? {
        // User Id
        guard let uid = UserDefaults.standard.string(forKey: userIdKey) else {
            print("no user")
            return nil
        }
        // reference
        let ref = Database.database().reference().child("users/\(uid)/favorites/drivers")
        return ref
    }
    

    static var databaseFavoriteTeams: DatabaseReference? {
        // User Id
        guard let uid = UserDefaults.standard.string(forKey: userIdKey) else {
            print("no user")
            return nil
        }
        // reference
        let ref = Database.database().reference().child("users/\(uid)/favorites/teams")
        return ref
    }
}
