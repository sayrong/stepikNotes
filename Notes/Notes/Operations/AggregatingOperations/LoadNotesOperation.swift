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
    
    private var loadFromDb: LoadNotesDBOperation
    private let loadFromBackend: LoadNotesBackendOperation
    
    private(set) var notes: [Note]?
    private var dbNotes:[Note] = []
    private var model: FileNotebook
    let group = DispatchGroup()
    
    init(notebook: FileNotebook, backendQueue: OperationQueue, dbQueue: OperationQueue) {
        group.enter()
        group.enter()
        loadFromBackend = LoadNotesBackendOperation()
        loadFromDb = LoadNotesDBOperation(notebook:notebook)
        model = notebook
        super.init()

        loadFromBackend.completionBlock = {
            switch self.loadFromBackend.result! {
            case .success(let notes):
                self.notes = notes
            case .failure(_):
                DDLogError("Got error while loading notes from backend")
            }
            self.group.leave()
        }
        loadFromDb.completionBlock = {
            if let notes = self.loadFromDb.result {
                self.dbNotes = notes
            }
            self.group.leave()
        }
        self.addDependency(loadFromDb)
        self.addDependency(loadFromBackend)
        backendQueue.addOperation(loadFromBackend)
        dbQueue.addOperation(loadFromDb)
    }
    
    override func main() {
        //если нам не прилетели заметки, берем их локально
        group.wait()
        if notes == nil {
            notes = dbNotes
        }
        finish()
    }
    
}
