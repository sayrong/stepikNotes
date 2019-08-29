//
//  ViewController.swift
//  Notes
//
//  Created by Babette Alvyn sharp on 23/06/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit

//Архитектура ради архитектуры
//Так и не нашел логики, которая не связана со view и которую можено вынести в presenter
protocol EditNotePresenterProtocol: class {
    var noteName: String { get }
    var noteText: String { get }
    var selfDestructDate: Date? { get }
    var selectedColor: UIColor { get set }
}

protocol EditNoteViewProtocol: class {
    func colorDidSet(color: UIColor)
}

class EditNoteViewController: UIViewController, EditNoteViewProtocol {

    //MARK: IBOutlet
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
    
    //MARK: Properties
    var presenter: EditNotePresenterProtocol!
    //Не понимаю как передать модель в презентер минуя view
    var noteToEdit: Note?
    var completion:((_ vc: EditNoteViewController)->())?
    
    //MARK: Conforms to protocol
    func colorDidSet(color: UIColor) {
        unselectColors()
        presenter.selectedColor = color
    }
    
    //MARK: Config section
    //Настраиваем наши квадраты с цветом
    //Логика настройки UI
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
    
    //Логика настройки UI - текст и цвет
    private func configAppearanceAndText() {
        noteName.text = presenter.noteName
        noteText.text = presenter.noteText
        noteText.layer.borderColor = UIColor.black.cgColor
        noteText.layer.borderWidth = 0.5
    }
    
    //Логика настройки UI - клавиатуры
    private func configKeyboard() {
        //Тапаем за клавиатуру и она скрывается
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func commonConfig() {
        configureRect()
        configKeyboard()
        configAppearanceAndText()
    }
    
    //MARK: viewWill appear methods
    //Нет смысла эти методы переносить в presenter
    //Они вызываеются каждый раз при появлении экрана
    //Получается какая-то proxy
    private func configDate() {
        if let date = presenter.selfDestructDate {
            destroyDateSwitch.isOn = true
            datePicker.isHidden = false
            datePicker.date = date
        }
    }
    
    private func configColorRect() {
        switch presenter.selectedColor {
        case UIColor.white:
            colorRect1.selected = true
        case UIColor.red:
            colorRect2.selected = true
        case UIColor.green:
            colorRect3.selected = true
        default:
            modifyGradientColor()
        }
    }
    
    
    //MARK: Private methods
    //Если выбрали кастомный цвет
    private func modifyGradientColor() {
        colorRect4.backgroundColor = presenter.selectedColor
        colorRect4.isGradient = false
        colorRect4.selected = true
    }
    
    private func unselectColors() {
        colorRect1.selected = false
        colorRect2.selected = false
        colorRect3.selected = false
        colorRect4.selected = false
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
		super.viewDidLoad()
        self.presenter = EditNoteViewPresenter(view: self, note: noteToEdit)
        #if TESTQA
            //Можно что-то сделать для тестовой сборки
        #endif
        commonConfig()
	}
    
    //Каждый раз при появлении экрана
    //Определяем на каком квадрате ставить галку
    //И нужно ли выводить datePicker
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configDate()
        configColorRect()
    }
    
    //MARK: Navigation to colorPicker
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
    
    //Прячем клавиатуру
    @objc func dismissKeyboard() {
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
    
    //При уходе с экрана вызываем completion
    override func willMove(toParent parent: UIViewController?) {
        if let cmp = completion, parent == nil {
            cmp(self)
        }
        super.willMove(toParent: parent)
    }
    
}

