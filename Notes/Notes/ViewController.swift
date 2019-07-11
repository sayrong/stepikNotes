//
//  ViewController.swift
//  Notes
//
//  Created by Babette Alvyn sharp on 23/06/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit




protocol IColorsController: class {
    func unselectColors();
}

@IBDesignable class ColorViewRect: UIView {
    
    weak var owner: IColorsController?
    
    var selected: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var isGradient: Bool = false
    
    override func draw(_ rect: CGRect) {
        if isGradient {
            makeGradient()
        }
        if selected {
            markView()
        }
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    private func markView() {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2.0)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.move(to: CGPoint(x: self.bounds.maxX - 20, y: 8))
        context?.addLine(to: CGPoint(x: self.bounds.maxX - 13, y: 18))
        context?.move(to: CGPoint(x: self.bounds.maxX - 13, y: 18))
        context?.addLine(to: CGPoint(x: self.bounds.maxX - 8, y: 4))
        context?.addEllipse(in: CGRect(x: self.bounds.maxX - 23, y: 2, width: 20, height: 20))
        context?.strokePath()
    }
    
    private func makeGradient() {
        let context = UIGraphicsGetCurrentContext()
        for y : CGFloat in stride(from: 0.0 ,to: self.bounds.size.height, by: 1) {
            let alph = CGFloat(self.bounds.size.height - y) / self.bounds.size.height
            for x : CGFloat in stride(from: 0.0 ,to: self.bounds.size.width, by: 1) {
                let hue = x / self.bounds.size.width
                let color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: alph)
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x:x, y:y, width:1,height:1))
            }
        }
    }
    
    
    @objc func selectColor() {
        owner?.unselectColors()
        selected = true
    }
}


class ViewController: UIViewController, IColorsController {

    @IBOutlet weak var colorRect1: ColorViewRect!
    @IBOutlet weak var colorRect2: ColorViewRect!
    @IBOutlet weak var colorRect3: ColorViewRect!
    @IBOutlet weak var colorRect4: ColorViewRect!
    @IBOutlet weak var noteText: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContent: UIView!
    
    var colorView: ColorPicker?
    
    func adjustTextHeight(textView: UITextView) {
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
    }
    
    func unselectColors() {
        colorRect1.selected = false
        colorRect2.selected = false
        colorRect3.selected = false
    }
    
    private func configureRect() {
        let tapRect1: UITapGestureRecognizer = UITapGestureRecognizer(target: colorRect1, action: #selector(colorRect1.selectColor))
        let tapRect2: UITapGestureRecognizer = UITapGestureRecognizer(target: colorRect2, action: #selector(colorRect2.selectColor))
        let tapRect3: UITapGestureRecognizer = UITapGestureRecognizer(target: colorRect3, action: #selector(colorRect3.selectColor))
        colorRect1.addGestureRecognizer(tapRect1)
        colorRect2.addGestureRecognizer(tapRect2)
        colorRect3.addGestureRecognizer(tapRect3)
        colorRect1.owner = self
        colorRect2.owner = self
        colorRect3.owner = self
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
        configureRect()
        colorView = ColorPicker(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        colorView?.backgroundColor = UIColor.white
        colorView?.isHidden = true
        self.view.addSubview(colorView!)
        
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
    
    
    
    @IBAction func testAction(_ sender: Any) {
        self.colorView?.isHidden = false
        
        
    }
    
}

