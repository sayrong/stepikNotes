//
//  RemoveNoteDBOperation.swift
//  Notes
//
//  Created by Dmitriy on 29/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation

//RemoveNoteDBOperation принимает на вход заметку и экземляр FileNotebook.
//Удаляет эту заметку из FileNotebook.

class RemoveNoteDBOperation: BaseDBOperation {
    private let noteToRemove: Note
    
    init(note: Note, notebook: NoteStorageProtocol) {
        noteToRemove = note
        super.init(notebook: notebook)
    }
    
    override func main() {
        notebook.remove(with: noteToRemove.uid)
        notebook.save()
        finish()
    }
    
}
