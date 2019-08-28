//
//  ColorViewRect.swift
//  Notes
//
//  Created by Dmitriy on 28/08/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit

//При установке цвета одному квадрату, надо снять галки с других
//Поэтому у каждому квадрата задан owner. Через него можно сборосить цвет остальным
protocol IColorsController: class {
    func unselectColors();
    var selectedColor: UIColor { get set }
}

//Квадраты выбора цвета
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
    
    //Рисование галки
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
    
    //Градиент. Шагаем попиксельно по х и меняем hue, по y яркость
    //что за hue - https://ru.wikipedia.org/wiki/%D0%A2%D0%BE%D0%BD_(%D1%86%D0%B2%D0%B5%D1%82)
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
        owner?.selectedColor = self.backgroundColor ?? UIColor.white
        selected = true
    }
}
