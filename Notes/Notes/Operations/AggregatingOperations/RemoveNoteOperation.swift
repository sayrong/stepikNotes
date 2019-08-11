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
    
    private let removeFromDb: RemoveNoteDBOperation
    private let dbQueue: OperationQueue
    
    private(set) var result: Bool? = false
    
    init(note: Note, notebook: FileNotebook, backendQueue: OperationQueue, dbQueue: OperationQueue) {
        self.dbQueue = dbQueue
        removeFromDb = RemoveNoteDBOperation(note: note, notebook: notebook)
        super.init()
        removeFromDb.completionBlock = {
            let saveToBackend = SaveNotesBackendOperation(notes: notebook.notes)
            saveToBackend.completionBlock = {
                switch saveToBackend.result! {
                case .success:
                    self.result = true
                case .failure:
                    self.result = false
                }
                print("RemoveNoteOperation - done")
                self.finish()
            }
            backendQueue.addOperation(saveToBackend)
        }
        
    }
    
    override func main() {
       dbQueue.addOperation(removeFromDb)
    }
}
