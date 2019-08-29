//
//  ColorPickerViewController.swift
//  Notes
//
//  Created by Dima on 21/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {

    //MARK: Properties
    weak var owner: EditNoteViewProtocol?
    
    //При измении цвета сразу меняется отображение во view
    var color: UIColor? {
        didSet {
            selectedColorView.colorView.backgroundColor = color
            selectedColorView.hexColor.text = color?.toHexString()
        }
    }
    
    //MARK: Creating UI Elements
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
    
    lazy var selectedColorView: SelectedColorView = {
        let view = SelectedColorView(color: UIColor.white)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: Viewlife cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(doneButton)
        self.view.addSubview(slider)
        self.view.addSubview(brightLabel)
        self.view.addSubview(colorPickerView)
        self.view.addSubview(selectedColorView)
        setupLayout()
    }
    
    //MARK: Handlers
    //Обработки, которые мы вызвает через target
    //Регулировка яркости через слайдер
    @objc private func sliderValueChanged(sender: UISlider) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let newAlpha = sender.value / 100
        color = UIColor(red: red, green: green, blue: blue, alpha: CGFloat(newAlpha))
    }
    
    @objc private func handlePickColorGesture(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: colorPickerView)
        guard colorPickerView.bounds.contains(point) else { return }
        if colorPickerView.pointer.isHidden { colorPickerView.pointer.isHidden = false }
        colorPickerView.pointer.center = point
        let color = getPixelColor(atPosition: point)
        self.color = color
        let alph = (CGFloat(self.colorPickerView.bounds.height - point.y) / self.colorPickerView.bounds.height)
        slider.value = Float(alph) * 100
    }
    
    @objc private func doneTapped() {
        let color = selectedColorView.colorView.backgroundColor ?? UIColor.white
        owner?.colorDidSet(color: color)
        self.navigationController?.popViewController(animated: true)
    }
    
    //Цвет пикселя завит от позиции нашего поинта. Прозрачность от высоты, а цвет от ширины
    private func getPixelColor(atPosition:CGPoint) -> UIColor{
        let alph = CGFloat(self.colorPickerView.bounds.height - atPosition.y) / self.colorPickerView.bounds.height
        let hue = atPosition.x / self.colorPickerView.bounds.width
        return UIColor(hue: hue, saturation: 1, brightness: 1, alpha: alph)
    }
    
    //MARK: Layout
    //Настройки расположения элементов. Спускаемся сверху вниз
    private func setupLayout() {
        NSLayoutConstraint.activate([
            //
            NSLayoutConstraint(item: selectedColorView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .topMargin, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: selectedColorView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: selectedColorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80),
            NSLayoutConstraint(item: selectedColorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
            //
            NSLayoutConstraint(item: brightLabel, attribute: .leading, relatedBy: .equal, toItem: selectedColorView, attribute: .trailing, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: brightLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .topMargin, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: brightLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120),
            NSLayoutConstraint(item: brightLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20),
            //
            NSLayoutConstraint(item: slider, attribute: .top, relatedBy: .equal, toItem: brightLabel, attribute: .bottom, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: slider, attribute: .leading, relatedBy: .equal, toItem: selectedColorView, attribute: .trailing, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: slider, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 180),
            NSLayoutConstraint(item: slider, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20),
            //
            NSLayoutConstraint(item: colorPickerView, attribute: .top, relatedBy: .equal, toItem: selectedColorView, attribute: .bottom, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: colorPickerView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: colorPickerView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailingMargin, multiplier: 1, constant: -20),
            //
            NSLayoutConstraint(item: doneButton, attribute: .top, relatedBy: .equal, toItem: colorPickerView, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: doneButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: doneButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80),
            NSLayoutConstraint(item: doneButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: doneButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottomMargin, multiplier: 1, constant: -20),
            
            ])
    }
    

}
