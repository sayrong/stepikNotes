//
//  ViewController.swift
//  Notes
//
//  Created by Babette Alvyn sharp on 23/06/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var colorRect1: UIView!
    @IBOutlet weak var colorRect2: UIView!
    @IBOutlet weak var colorRect3: UIView!
    @IBOutlet weak var colorRect4: UIView!
    @IBOutlet weak var noteText: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContent: UIView!
    
    
    func adjustTextHeight(textView: UITextView) {
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
    }
    
    override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
        //adjustTextHeight(textView: noteText)
        #if TESTQA
            let welcomeMessage = UILabel(frame: CGRect(x: 5, y: 50, width: 200, height: 21))
            welcomeMessage.textColor = .black
            welcomeMessage.text = "Welcome to test version"
            welcomeMessage.textAlignment = .center
            super.view.addSubview(welcomeMessage)
        #endif
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        colorRect1.layer.borderWidth = 1
        colorRect1.layer.borderColor = UIColor.black.cgColor
        colorRect2.layer.borderWidth = 1
        colorRect2.layer.borderColor = UIColor.black.cgColor
        colorRect3.layer.borderWidth = 1
        colorRect3.layer.borderColor = UIColor.black.cgColor
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    @IBAction func test(_ sender: Any) {
        adjustTextHeight(textView: noteText)
    }
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}

