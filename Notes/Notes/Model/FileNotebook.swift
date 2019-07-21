//
//  FileNotebook.swift
//  Notes
//
//  Created by Dima on 24/06/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation
import CocoaLumberjack

class FileNotebook {
    
    private(set) var notes = [Note]()
    var filename: String
    
    init(filename: String) {
        self.filename = filename
    }
    
    public func add(_ note: Note) {
        for i in notes {
            if i.uid == note.uid {
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
    
    public func saveToFile() {
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
            DDLogInfo("File \(notesDir.path) saved")
        }
        
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
    
    public func loadFromFile() {
        
        guard let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            DDLogError("Error get cache dir")
            return
        }
        let notesDir = path.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: notesDir.path) {
            if let arrayJson = extractFromFile(fileUrl: notesDir) {
                notes.removeAll()
                for i in arrayJson {
                    if let tmp = Note.parse(json: i) {
                        notes.append(tmp)
                    }
                }
            }
        } else {
            DDLogError("File \(notesDir.path) not found")
        }
        
    }
    
    
}

