//
//  ViewController.swift
//  Notes
//
//  Created by Babette Alvyn sharp on 23/06/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
        
        #if TESTQA
            let welcomeMessage = UILabel(frame: CGRect(x: 5, y: 50, width: 200, height: 21))
            welcomeMessage.textColor = .black
            welcomeMessage.text = "Welcome to test version"
            welcomeMessage.textAlignment = .center
            super.view.addSubview(welcomeMessage)
        #endif
        
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

