//
//  ColorPickerViewController.swift
//  Notes
//
//  Created by Dima on 21/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit

protocol selectedColorProtocol: class{
    var selectedColor: UIColor { get set }
}

class ColorPickerViewController: UIViewController {

    var selectedColor: UIColor?
    weak var owner: selectedColorProtocol?
    var colorView: ColorPicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureColorPicker()
    }
    
    private func configureColorPicker() {
        colorView = ColorPicker(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        if let colorView = colorView {
            self.view.addSubview(colorView)
            colorView.translatesAutoresizingMaskIntoConstraints = false
            colorView.backgroundColor = UIColor.white
            //colorView.isHidden = true
            colorView.completion = completion(color:)
            self.view.addSubview(colorView)
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: colorView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: colorView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: colorView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: colorView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
                ])
        }
    }
    
    
    private func completion(color: UIColor)->() {
        self.selectedColor = color
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil, selectedColor != nil, owner != nil {
            owner!.selectedColor = selectedColor!
        }
        super.willMove(toParent: parent)
    }

}
