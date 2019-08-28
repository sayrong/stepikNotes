//
//  ColorPicker.swift
//  Notes
//
//  Created by Dmitriy on 11/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation
import UIKit

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

class ColorPicker: UIView {
    
    //Чтобы можно было выполнить стороннее действие после выбора цвета
    var completion:((_ color: UIColor)->())?
    
    //Квадратная кнопка где будет отображаться цвет и его значение.
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
    
    
    //Элементы и layout сделаны через код, так что на размер frame можно не обращать особого внимания
    lazy var doneButton: UIButton = {
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return doneButton
    }()
    
    lazy var slider: UISlider = {
        let slider = UISlider(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .allTouchEvents)
        return slider
    }()
    
    lazy var brightLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Brightness"
        return label
    }()
    
    //UILongPressGestureRecognizer селектор вызывается каждый раз при движении
    lazy var colorPickerView: Gradient = {
        let view = Gradient(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = 0
        recognizer.addTarget(self, action: #selector(handlePickColorGesture(_:)))
        view.addGestureRecognizer(recognizer)
        return view
    }()
    
    lazy var selectedColor: SelectedColorView = {
        let view = SelectedColorView(color: UIColor.white)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //При измении цвета сразу меняется отображение во view
    var color: UIColor? {
        didSet {
            selectedColor.colorView.backgroundColor = color
            selectedColor.hexColor.text = color?.toHexString()
        }
    }
    
    //Регулировка яркости через слайдер
    @IBAction func sliderValueChanged(sender: UISlider) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let newAlpha = sender.value / 100
        color = UIColor(red: red, green: green, blue: blue, alpha: CGFloat(newAlpha))
    }
    
    //Обработки, которые мы вызвает через target
    @objc func handlePickColorGesture(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: colorPickerView)
        guard colorPickerView.bounds.contains(point) else { return }
        if colorPickerView.pointer.isHidden { colorPickerView.pointer.isHidden = false }
        colorPickerView.pointer.center = point
        let color = getPixelColor(atPosition: point)
        self.color = color
        let alph = (CGFloat(self.colorPickerView.bounds.height - point.y) / self.colorPickerView.bounds.height)
        slider.value = Float(alph) * 100
    }
    
    @objc func doneTapped() {
        if let completion = completion {
            completion(selectedColor.colorView.backgroundColor ?? UIColor.white)
        }
    }
    
    
    //Настройки расположения элементов. Спускаемся сверху вниз
    private func setupLayout() {
        NSLayoutConstraint.activate([
            //
            NSLayoutConstraint(item: selectedColor, attribute: .top, relatedBy: .equal, toItem: self, attribute: .topMargin, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: selectedColor, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: selectedColor, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80),
            NSLayoutConstraint(item: selectedColor, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
            //
            NSLayoutConstraint(item: brightLabel, attribute: .leading, relatedBy: .equal, toItem: selectedColor, attribute: .trailing, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: brightLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .topMargin, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: brightLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120),
            NSLayoutConstraint(item: brightLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20),
            //
            NSLayoutConstraint(item: slider, attribute: .top, relatedBy: .equal, toItem: brightLabel, attribute: .bottom, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: slider, attribute: .leading, relatedBy: .equal, toItem: selectedColor, attribute: .trailing, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: slider, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 180),
            NSLayoutConstraint(item: slider, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20),
            //
            NSLayoutConstraint(item: colorPickerView, attribute: .top, relatedBy: .equal, toItem: selectedColor, attribute: .bottom, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: colorPickerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: colorPickerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailingMargin, multiplier: 1, constant: -20),
            //
            NSLayoutConstraint(item: doneButton, attribute: .top, relatedBy: .equal, toItem: colorPickerView, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: doneButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: doneButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80),
            NSLayoutConstraint(item: doneButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: doneButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottomMargin, multiplier: 1, constant: -20),
            
            ])
    }
    
    //Цвет пикселя завит от позиции нашего поинта. Прозрачность от высоты, а цвет от ширины
    func getPixelColor(atPosition:CGPoint) -> UIColor{
        let alph = CGFloat(self.colorPickerView.bounds.height - atPosition.y) / self.colorPickerView.bounds.height
        let hue = atPosition.x / self.colorPickerView.bounds.width
        return UIColor(hue: hue, saturation: 1, brightness: 1, alpha: alph)
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
