//
//  ColorPicker.swift
//  Notes
//
//  Created by Dmitriy on 11/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation
import UIKit

class Gradient: UIView {
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for y : CGFloat in stride(from: 0.0 ,to: self.bounds.size.height, by: 1) {
            let alph = CGFloat(rect.height - y) / rect.height
            for x : CGFloat in stride(from: 0.0 ,to: rect.width, by: 1) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: alph)
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x:x, y:y, width:1,height:1))
            }
        }
    }
}

class ColorPicker: UIView {
    
    class SelectedColorView: UIView {
        
        var colorView: UIView
        var hexColor: UILabel
        
        init(color:UIColor) {
            self.colorView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            self.hexColor = UILabel(frame: CGRect(x: 10, y: 80, width: 80, height: 20))
            self.hexColor.text = color.toHexString()
            super.init(frame: CGRect(x: 80, y: 80, width: 80, height: 100))
            self.addSubview(colorView)
            self.addSubview(hexColor)
            self.layer.borderColor = UIColor.black.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 10
            self.colorView.layer.cornerRadius = 10
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(doneButton)
        self.addSubview(slider)
        self.addSubview(brightLabel)
        self.addSubview(colorPickerView)
        self.addSubview(selectedColor)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    lazy var doneButton: UIButton = {
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        return doneButton
    }()
    
    lazy var slider: UISlider = {
        let slider = UISlider(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 100
        return slider
    }()
    
    lazy var brightLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Brightness"
        return label
    }()
    
    lazy var colorPickerView: Gradient = {
        let view = Gradient(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    lazy var selectedColor: SelectedColorView = {
        let view = SelectedColorView(color: UIColor.white)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            //
            NSLayoutConstraint(item: selectedColor, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 60),
            NSLayoutConstraint(item: selectedColor, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: selectedColor, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80),
            NSLayoutConstraint(item: selectedColor, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
            //
            NSLayoutConstraint(item: brightLabel, attribute: .leading, relatedBy: .equal, toItem: selectedColor, attribute: .trailing, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: brightLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 80),
            NSLayoutConstraint(item: brightLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120),
            NSLayoutConstraint(item: brightLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20),
            //
            NSLayoutConstraint(item: slider, attribute: .top, relatedBy: .equal, toItem: brightLabel, attribute: .bottom, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: slider, attribute: .leading, relatedBy: .equal, toItem: selectedColor, attribute: .trailing, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: slider, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200),
            NSLayoutConstraint(item: slider, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20),
            //
            NSLayoutConstraint(item: colorPickerView, attribute: .top, relatedBy: .equal, toItem: selectedColor, attribute: .bottom, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: colorPickerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: colorPickerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -20),
            //
            NSLayoutConstraint(item: doneButton, attribute: .top, relatedBy: .equal, toItem: colorPickerView, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: doneButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: doneButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80),
            NSLayoutConstraint(item: doneButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: doneButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottomMargin, multiplier: 1, constant: -20),
            
            ])
    }
    
}

extension UIColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb) 
    }
}
