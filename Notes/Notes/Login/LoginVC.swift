//
//  LoginVC.swift
//  Notes
//
//  Created by Dmitriy on 15/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    private func checkFieldNotEmpty() -> Bool {
        var result = true
        if let loginText = loginTextField.text {
            if loginText.isEmpty {
                loginTextField.shake()
                result = false
            }
        }
        if let pwd = passwordTextField.text {
            if pwd.isEmpty {
                passwordTextField.shake()
                result = false
            }
        }
        return result
    }
    
    @IBAction func showHelloScreen(_ sender: Any) {
        guard checkFieldNotEmpty() else {
            return
        }
        let helloScreen = HelloVC()
        helloScreen.name = loginTextField.text!
        self.present(helloScreen, animated: true, completion: nil)  
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
