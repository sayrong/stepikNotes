//
//  FileNotebook.swift
//  Notes
//
//  Created by Dima on 24/06/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation
import CocoaLumberjack

protocol NoteStorageProtocol: class{
    var notes: [Note] { get }
    func add(_ note: Note)
    func remove(with uid: String)
    func save()
    func loadFromStorage() -> [Note]
    func loadNewNotes(newNotes: [Note])
}

class FileNotebook: NoteStorageProtocol {
    
    private(set) var notes = [Note]()
    var filename: String
    
    init(filename: String) {
        self.filename = filename
    }
    
    //если обнаруживаем заметку с таким же id, то заменяем ее на новую
    public func add(_ note: Note) {
        for (i,j) in notes.enumerated() {
            if j.uid == note.uid {
                notes[i] = note
                return
            }
        }
        notes.insert(note, at: 0)
    }
    
    public func remove(with uid: String) {
        for (i, j) in notes.enumerated() {
            if j.uid == uid {
                notes.remove(at: i)
            }
        }
    }
    
    private func getFile() -> Data? {
        var data: Data? = nil
        var result = [[String:Any]]()
        for i in notes {
            result.append(i.json)
        }
        do {
            data = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
        } catch {
            DDLogError(error.localizedDescription)
        }
        return data
    }
    
    
    
    public func save() {
        var result = false
        guard let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            DDLogError("Error get cache dir")
            return
        }
        let notesDir = path.appendingPathComponent(filename)
        if let data = getFile() {
            result = FileManager.default.createFile(atPath: notesDir.path, contents: data, attributes: nil)
        }
        if result == false {
            DDLogError("Some error while creating file")
        } else {
            DDLogInfo("File saved")
        }
        
    }
    
    static func convertToJson(notes: [Note]) -> Data? {
        var data: Data? = nil
        var result = [[String:Any]]()
        for i in notes {
            result.append(i.json)
        }
        do {
            data = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
        } catch {
            DDLogError(error.localizedDescription)
        }
        return data
    }
    
    
    static func extractFromString(string: String) -> [Note]? {
        var result = [Note]()
        //в случае пустой базы - пустая строка
        if string.isEmpty {
            return result
        }
        guard let data = string.data(using: .utf8) else { return nil }
        if let arrayJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] {
            for i in arrayJson {
                if let tmp = Note.parse(json: i) {
                    result.append(tmp)
                }
            }
            return result
        }
        return nil
    }
    
    private func extractFromFile(fileUrl: URL) -> [[String:Any]]? {
        do {
            let data = try Data(contentsOf: fileUrl)
            let file = try JSONSerialization.jsonObject(with: data, options: [])
            if let arrayJson = file as? [[String:Any]] {
                return arrayJson
            } else {
                DDLogError("Cast error")
            }
        } catch {
            DDLogError(error.localizedDescription)
        }
        return nil
    }
    
    //Возвращает заметки из файла
    public func loadFromStorage() -> [Note] {
        var result = [Note]()
        
        guard let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            DDLogError("Error get cache dir")
            return result
        }
        let notesDir = path.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: notesDir.path) {
            if let arrayJson = extractFromFile(fileUrl: notesDir) {
                for i in arrayJson {
                    if let tmp = Note.parse(json: i) {
                        result.append(tmp)
                    }
                }
            }
        } else {
            DDLogError("Local file with notes not found")
        }
        return result
    }
    
    public func loadNewNotes(newNotes: [Note]) {
        notes.removeAll()
        for i in newNotes {
            notes.append(i)
        }
    }
    
    
}

