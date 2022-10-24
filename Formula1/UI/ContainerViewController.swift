//
//  ContainerViewController.swift
//  Formula1
//
//  Created by Yair Kerem on 20/08/2022.
//

import UIKit

class ContainerViewController: UIViewController {
    
    var circuitListVC:  CircuitListViewController?
    var driverListVC: DriverListViewController?
    var teamListVC: TeamListViewController?
    var seasonsVC: SeasonListViewController?
    var favoritesVC: FavoritesViewController?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)

        segmentedControl.setWidth(30, forSegmentAt: 4)
        segmentedControl.apportionsSegmentWidthsByContent = true
        
        title = "Circuits"
        
    }
    
    private func setup() {
        // Create a reference to the the appropriate storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate the desired view controller from the storyboard using the view controllers identifier
        // Cast is as the custom view controller type you created in order to access it's properties and methods
        self.circuitListVC = storyboard.instantiateViewController(withIdentifier: "CircuitListViewController") as? CircuitListViewController
        if let circuitListVC = circuitListVC {
            addChild(circuitListVC)
            self.containerView.addSubview(circuitListVC.view)
            circuitListVC.didMove(toParent: self)
            circuitListVC.view.frame = self.containerView.bounds
            circuitListVC.view.isHidden = false
        }
        
        self.driverListVC = storyboard.instantiateViewController(withIdentifier: "DriverListViewController") as? DriverListViewController
        if let driverListVC = driverListVC {
            addChild(driverListVC)
            self.containerView.addSubview(driverListVC.view)
            driverListVC.didMove(toParent: self)
            driverListVC.view.frame = self.containerView.bounds
            driverListVC.view.isHidden = true
        }
        
        self.teamListVC = storyboard.instantiateViewController(withIdentifier: "TeamListViewController") as? TeamListViewController
        if let teamListVC = teamListVC {
            addChild(teamListVC)
            self.containerView.addSubview(teamListVC.view)
            teamListVC.didMove(toParent: self)
            teamListVC.view.frame = self.containerView.bounds
            teamListVC.view.isHidden = true
        }
        
        self.seasonsVC = storyboard.instantiateViewController(withIdentifier: "SeasonListViewController") as? SeasonListViewController
        if let seasonsVC = seasonsVC {
            addChild(seasonsVC)
            self.containerView.addSubview(seasonsVC.view)
            seasonsVC.didMove(toParent: self)
            seasonsVC.view.frame = self.containerView.bounds
            seasonsVC.view.isHidden = true
        }
        
        self.favoritesVC = storyboard.instantiateViewController(withIdentifier: "FavoritesViewController") as? FavoritesViewController
        if let favoritesVC = favoritesVC {
            addChild(favoritesVC)
            self.containerView.addSubview(favoritesVC.view)
            favoritesVC.didMove(toParent: self)
            favoritesVC.view.frame = self.containerView.bounds
            favoritesVC.view.isHidden = true
        }
        
        
    }
    @IBAction func didTapSegment(segment: UISegmentedControl) {
        guard let circuitListVC = circuitListVC,
              let driverListVC = driverListVC,
              let teamListVC = teamListVC,
              let seasonsVC = seasonsVC,
              let favoritesVC = favoritesVC else { return }
        
        circuitListVC.view.isHidden = true
        driverListVC.view.isHidden = true
        teamListVC.view.isHidden = true
        seasonsVC.view.isHidden = true
        favoritesVC.view.isHidden = true

        switch segment.selectedSegmentIndex {
        case 0:
            circuitListVC.view.isHidden = false
            self.title = "Circuits"
        case 1:
            driverListVC.view.isHidden = false
            self.title = "Drivers"
        case 2:
            teamListVC.view.isHidden = false
            self.title = "Constructors"
        case 3:
            seasonsVC.view.isHidden = false
            self.title = "Season Standings"
        case 4:
            favoritesVC.view.isHidden = false
            self.title = "Favorites"
        default:
            print("Container View Controller segment-control error")
        }
        
    }
}
