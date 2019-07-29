//
//  RemoveNoteOperation.swift
//  Notes
//
//  Created by Dmitriy on 29/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation

//RemoveNoteOperation - вызывает SaveNotesBackendOperation и RemoveNoteDBOperation.
//Должна вызываться из UI по событию удаления заметки.

class RemoveNoteOperation: AsyncOperation {
    
    private let note: Note
    private let notebook: FileNotebook
    private let removeFromDb: RemoveNoteDBOperation
    private var saveToBackend: SaveNotesBackendOperation?
    
    private(set) var result: Bool? = false
    
    init(note: Note, notebook: FileNotebook, backendQueue: OperationQueue, dbQueue: OperationQueue) {
        
        self.note = note
        self.notebook = notebook
        removeFromDb = RemoveNoteDBOperation(note: note, notebook: notebook)
        super.init()
        removeFromDb.completionBlock = {
            let saveToBackend = SaveNotesBackendOperation(notes: notebook.notes)
            self.saveToBackend = saveToBackend
            self.addDependency(saveToBackend)
            backendQueue.addOperation(saveToBackend)
        }
        addDependency(removeFromDb)
        dbQueue.addOperation(removeFromDb)
    }
    
    override func main() {
        switch saveToBackend!.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }
        finish()
    }
}
