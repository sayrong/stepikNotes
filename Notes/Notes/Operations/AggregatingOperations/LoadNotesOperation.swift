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
    
    //Две операции зашрузка с веба и локально
    private var loadFromDb: LoadNotesDBOperation
    private let loadFromBackend: LoadNotesBackendOperation
    
    private(set) var notes: [Note]?
    private var model: NoteStorageProtocol
    //Для синхрониизации потоков.
    //Оказывается addDependency не ждет, пока выполниться completionBlock у операции
    let group = DispatchGroup()
    
    init(notebook: NoteStorageProtocol, backendQueue: OperationQueue, dbQueue: OperationQueue) {
        //Инициализация полей
        group.enter()
        loadFromBackend = LoadNotesBackendOperation()
        loadFromDb = LoadNotesDBOperation(notebook:notebook)
        model = notebook
        super.init()
        //Если загрузка с сервера выполнилась удачно, то забираем полученные данные
        //Если ошибка загружаем заметки локально
        loadFromBackend.completionBlock = {
            switch self.loadFromBackend.result! {
            case .success(let notes):
                self.notes = notes
            case .failure(_):
                self.group.enter()
                DDLogError("Got error while loading notes from backend")
                dbQueue.addOperation(self.loadFromDb)
            }
            self.group.leave()
        }
        loadFromDb.completionBlock = {
            if let notes = self.loadFromDb.result {
                self.notes = notes
            }
            self.group.leave()
        }
        backendQueue.addOperation(loadFromBackend)
    }
    
    override func main() {
        //После wait в параметре notes лежат заметки
        group.wait()
        if let notes = notes {
           model.loadNewNotes(newNotes: notes)
        } else {
            DDLogError("Notes is nil in LoadOperation")
        }
        finish()
        print("LoadNotesOperation - done")
    }
    
}
