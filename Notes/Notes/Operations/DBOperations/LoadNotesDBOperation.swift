//
//  LoadNotesDBOperation.swift
//  Notes
//
//  Created by Dmitriy on 29/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation

//LoadNotesDBOperation принимает на вход экземляр FileNotebook.
//В качестве результата вовращает массив заметок из этого FileNotebook.
//То есть у нее должно быть поле `var result: [Note]?`

class LoadNotesDBOperation: BaseDBOperation {
    var result: [Note]?
    
    override func main() {
        self.result = notebook.loadFromFile()
        finish()
    }
}
