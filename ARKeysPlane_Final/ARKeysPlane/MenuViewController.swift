//
//  MenuViewController.swift
//  ARKeysPlane
//
//  Created by Langston Lee on 5/7/19.
//  Copyright © 2019 Jacob Wang. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var classicButton: UIButton!
    @IBOutlet weak var arcadeButton: UIButton!
    @IBOutlet weak var timeTrialButton: UIButton!
    
    @IBOutlet weak var touchModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        //let classicButton = UIButton()
        classicButton.layer.cornerRadius = 10
        arcadeButton.layer.cornerRadius = 10
        timeTrialButton.layer.cornerRadius = 10
        
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "classicSegue"?:
            let vc = segue.destination as! ViewController
            vc.lane = Lane(gameMode: .classic)
            vc.touchMode = touchModeSwitch.isOn
            vc.lane.gameDelegate = vc.self
            print("classic")
        case "arcadeSegue"?:
            let vc = segue.destination as! ViewController
            vc.lane = Lane(gameMode: .arcade)
            vc.touchMode = touchModeSwitch.isOn
            vc.lane.gameDelegate = vc.self
            print("arcade")
        case "timeTrialSegue"?:
            let vc = segue.destination as! ViewController
            vc.lane = Lane(gameMode: .timeTrial)
            vc.touchMode = touchModeSwitch.isOn
            vc.lane.gameDelegate = vc.self
            print("time trial")
        default:
            print("unrecognized segue")
        }
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
    
    
}
