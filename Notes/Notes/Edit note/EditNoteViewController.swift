//
//  ViewController.swift
//  Notes
//
//  Created by Babette Alvyn sharp on 23/06/2019.
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


class EditNoteViewController: UIViewController, IColorsController, selectedColorProtocol {

    @IBOutlet weak var colorRect1: ColorViewRect!
    @IBOutlet weak var colorRect2: ColorViewRect!
    @IBOutlet weak var colorRect3: ColorViewRect!
    @IBOutlet weak var colorRect4: ColorViewRect!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var noteName: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContent: UIView!
    @IBOutlet weak var destroyLabel: UILabel!
    @IBOutlet weak var pickerNotHidden: NSLayoutConstraint!
    @IBOutlet weak var pickerHidden: NSLayoutConstraint!
    @IBOutlet weak var destroyDateSwitch: UISwitch!
    
    var selectedColor: UIColor = UIColor.white
    
    var noteToEdit: Note?
    var completion:((_ vc: EditNoteViewController)->())?
    
    //сброс цвета к квадрадах
    func unselectColors() {
        colorRect1.selected = false
        colorRect2.selected = false
        colorRect3.selected = false
        colorRect4.selected = false
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
        //Для градиента owner не нужен, так как мы проваливаемся в ColorPicker и там есть completion
        let gradientButton = UILongPressGestureRecognizer(target: self, action: #selector(showColorPicker(_:)))
        gradientButton.minimumPressDuration = 0.5
        colorRect4.addGestureRecognizer(gradientButton)
        
        colorRect1.backgroundColor = UIColor.white
        colorRect2.backgroundColor = UIColor.red
        colorRect3.backgroundColor = UIColor.green
    }
    
    
    override func viewDidLoad() {
		super.viewDidLoad()
        #if TESTQA
            //Можно что-то сделать для тестовой сборки
        #endif
        //Тапаем за клавиатуру и она скрывается
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        if let col = noteToEdit?.color {
            selectedColor = col
        }
        noteName.text = noteToEdit?.title
        noteText.text = noteToEdit?.content
        noteText.layer.borderColor = UIColor.black.cgColor
        noteText.layer.borderWidth = 0.5
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureRect()
        if let date = noteToEdit?.selfDestructDate {
            destroyDateSwitch.isOn = true
            datePicker.isHidden = false
            datePicker.date = date
        }
        switch selectedColor {
        case UIColor.white:
            colorRect1.selected = true
        case UIColor.red:
            colorRect2.selected = true
        case UIColor.green:
            colorRect3.selected = true
        default:
            changeColorToGradient()
        }
    }
    
    
    @objc func showColorPicker(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            performSegue(withIdentifier: "colorPickerSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ColorPickerViewController {
            vc.owner = self
        }
    }
    
    //Вызвается при возврата из ColorPicker когда выбран цвет
    func changeColorToGradient() {
        colorRect4.backgroundColor = selectedColor
        colorRect4.isGradient = false
        unselectColors()
        colorRect4.selected = true
    }
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //Заданы две констрейты, в активном состоянии они друг другу мешают.
    //Сделано потому, что когда элемент hide = true, то он сохраняет свою форму просто невидим.
    //Когда дата включена я цепляюсь (квадратами с выбором цветов) к ее нижней границе, когда выключена к лейблу с destroy date
    @IBAction func dateSwitchAction(_ sender: UISwitch) {
        datePicker.isHidden = !sender.isOn
        self.view.setNeedsLayout()
    }
    
    //isActive для constraint сбрасывается при повороте дисплея
    //и устанавливется где-то после viewWillLayoutSubviews
    override func viewDidLayoutSubviews() {
        if destroyDateSwitch.isOn {
            pickerHidden.isActive = false
            pickerNotHidden.isActive = true
        } else {
            pickerHidden.isActive = true
            pickerNotHidden.isActive = false
        }
        super.viewDidLayoutSubviews()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if let cmp = completion, parent == nil {
            cmp(self)
        }
        super.willMove(toParent: parent)
    }
    
}

