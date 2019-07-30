//
//  SaveNoteOperation.swift
//  Notes
//
//  Created by Dmitriy on 29/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation

class SaveNoteOperation: AsyncOperation {
    
    private let note: Note
    private let notebook: FileNotebook
    private let saveToDb: SaveNoteDBOperation
    private var saveToBackend: SaveNotesBackendOperation?
    
    private(set) var result: Bool? = false
    
    init(note: Note,
         notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        self.note = note
        self.notebook = notebook
        saveToDb = SaveNoteDBOperation(note: note, notebook: notebook)
        super.init()
        let saveToBackend = SaveNotesBackendOperation(notes: notebook.notes)
        self.saveToBackend = saveToBackend
        //после окончания saveDb ставим в очередь saveToBackend
        saveToDb.completionBlock = {
            backendQueue.addOperation(saveToBackend)
        }
        //наша операция не будет выполнена, пока две вложенных операции не закончены
        self.addDependency(saveToDb)
        self.addDependency(saveToBackend)
        dbQueue.addOperation(saveToDb)
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
