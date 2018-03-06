//
//  WeatherViewController.swift
//  Test
//
//  Created by Olya Tilichenko on 06.03.2018.
//  Copyright © 2018 Olya Tilichenko. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

    @IBOutlet weak var weatherLabel: UILabel!
    var weather:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let weather = weather {
        weatherLabel.text = weather
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
