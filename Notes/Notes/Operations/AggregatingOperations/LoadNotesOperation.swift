//
//  LoadNotesOperation.swift
//  Notes
//
//  Created by Dmitriy on 29/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation
import CocoaLumberjack

//LoadNotesOperation - вызывает LoadNotesBackendOperation. Если ошибка произошла, то вызывает LoadNotesDBOperation.
//Если не ошибка - то заметки загруженные с сервера заменяют локальные в FileNotebook.
//Она вызывается при отображении списка заметок.

class LoadNotesOperation: AsyncOperation {
    
    private var loadFromDb: LoadNotesDBOperation?
    private let loadFromBackend: LoadNotesBackendOperation
    
    private(set) var localNotes: [Note]?
    
    init(notebook: FileNotebook, backendQueue: OperationQueue, dbQueue: OperationQueue) {
        loadFromBackend = LoadNotesBackendOperation()
        super.init()
        
        loadFromBackend.completionBlock = {
            switch self.loadFromBackend.result! {
            case .success(let notes):
                self.localNotes = notes
            case .failure(let _):
                DDLogError("Got error while loading notes from backend")
                let loadFromDb = LoadNotesDBOperation(notebook:notebook)
                loadFromDb.completionBlock = {
                    if let notes = self.loadFromDb?.result {
                        self.localNotes = notes
                    }
                }
                self.loadFromDb = loadFromDb
                self.addDependency(loadFromDb)
                dbQueue.addOperation(loadFromDb)
            }
        }
        self.addDependency(loadFromBackend)
        backendQueue.addOperation(loadFromBackend)
    }
    
    override func main() {
        finish()
    }
    
}
