//
//  EditNoteViewPresenter.swift
//  Notes
//
//  Created by Dmitriy on 29/08/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation
import UIKit

//Считай пустой presenter c моделью

class EditNoteViewPresenter : EditNotePresenterProtocol {

    weak var view: EditNoteViewProtocol?
    //Заметка, которую в данные момент редактируем
    var noteToEdit: Note?
    
    init(view: EditNoteViewController, note: Note?) {
        self.view = view
        self.noteToEdit = note
        self.selectedColor = noteToEdit?.color ?? UIColor.white
    }
    
    
    //MARK: Conforms to protocol
    var selectedColor: UIColor
    
    var noteName: String {
        get {
            return noteToEdit?.title ?? ""
        }
    }
    
    var noteText: String {
        get {
            return noteToEdit?.content ?? ""
        }
    }
    
    var selfDestructDate: Date? {
        get {
            return noteToEdit?.selfDestructDate
        }
    }
    
}
