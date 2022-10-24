//
//  SignInViewController.swift
//  Formula1
//
//  Created by Yair Kerem on 06/08/2022.
//

import UIKit
import FirebaseAuth

let userIdKey = "userIDKey"

class SignInViewController: UIViewController {
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        
        guard let authInfo = authenticationDetails() else {
            return
        }
        Auth.auth().signIn(withEmail: authInfo.email, password: authInfo.password) { authResult, error in
            if let error = error {
                print("Error in sign in: \(error)")
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
        guard let authInfo = authenticationDetails() else {
            return
        }
        Auth.auth().createUser(withEmail: authInfo.email, password: authInfo.password) { authResult, error in
            if let error = error {
                print("Error in creating user: \(error)")
                
                // Create a new alert
                let errorMessage = UIAlertController(title: "Sign-Up Problem", message: "\(error.localizedDescription)", preferredStyle: .alert)

                // Create OK button with action handler
                 let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                     print("Ok button tapped")
                  })
                
                //Add OK button to a dialog message
                errorMessage.addAction(ok)
                
                // Present alert to user
                self.present(errorMessage, animated: true, completion: nil)


                return
            }
            else {    //  go to next page
//                self.present(page, animated: true, completion: nil)
                self.performSegue(withIdentifier: "navigationController", sender: nil)
            }
        }
    }
    
    private func authenticationDetails() -> (email: String, password: String)? {
        guard let userEmail = userTextField.text,
              !userEmail.isEmpty,
              let password = passwordTextField.text,
              !password.isEmpty else {
            return nil
        }
        return(userEmail, password)
    }

}
