//
//  ColorPicker.swift
//  Notes
//
//  Created by Dmitriy on 11/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation
import UIKit

//Квадратная view где будет отображаться цвет и его hex значение.
class SelectedColorView: UIView {
    
    var colorView: UIView
    var hexColor: UILabel
    
    init(color:UIColor) {
        self.colorView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        colorView.backgroundColor = UIColor.white
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

//Указатель на цвет под пальцем
class Pointer: UIView {
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
       
        context?.setLineWidth(3.0)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.addEllipse(in: CGRect(x: 8, y: 8, width: self.bounds.width - 16, height: self.bounds.height - 16))

        context?.move(to: CGPoint(x: self.bounds.width / 2, y: 8))
        context?.addLine(to: CGPoint(x: self.bounds.width / 2, y: 0))

        context?.move(to: CGPoint(x: self.bounds.width / 2, y: self.bounds.height - 8))
        context?.addLine(to: CGPoint(x: self.bounds.width / 2, y: self.bounds.height))

        context?.move(to: CGPoint(x: 0, y: self.bounds.height / 2))
        context?.addLine(to: CGPoint(x: 8, y: self.bounds.height / 2))
        
        context?.move(to: CGPoint(x: self.bounds.width - 8, y: self.bounds.height / 2))
        context?.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height / 2))
        context?.strokePath()
        
    }
}

class Gradient: UIView {
    
    //Указатель на цвет под пальцем
    lazy var pointer: Pointer = {
        let pointer = Pointer(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        pointer.isOpaque = false
        pointer.isHidden = true
        return pointer
    }()
    
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
    
    //При изменении размеры поля выбора цвета надо менять соответственно коортинаты указателя
    //Как у меня бомбило с этого задания
    override var bounds: CGRect {
        willSet {
            let oldPoint = pointer.center
            let oldValue = self.bounds
            let difHight = newValue.height / oldValue.height
            let difWidth = newValue.width / oldValue.width
            pointer.center = CGPoint(x: oldPoint.x * difWidth, y: oldPoint.y * difHight)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(pointer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
