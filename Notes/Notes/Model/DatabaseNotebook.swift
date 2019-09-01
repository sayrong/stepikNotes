//
//  DatabaseNotebook.swift
//  Notes
//
//  Created by Dmitriy on 20/08/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import CoreData
import UIKit

class DatabaseNoteBook: NoteStorageProtocol {
    
    var context: NSManagedObjectContext
    var bgContext: NSManagedObjectContext
    var notes = [Note]()
    
    init(mainContext: NSManagedObjectContext, bgContext: NSManagedObjectContext) {
        self.context = mainContext
        self.bgContext = bgContext
        self.configure()
    }
    
    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    @objc func managedObjectContextDidSave(notification: Notification) {
        context.perform {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func add(_ note: Note) {
        //check for exist
        var _newNote: NSManagedObject?
        for (i,j) in notes.enumerated() {
            if j.uid == note.uid {
                notes[i] = note
                return
            }
        }
        bgContext.performAndWait {
            _newNote = NSEntityDescription.insertNewObject(forEntityName: "NoteEntity", into: bgContext)
        }
        guard let newNote = _newNote as? NoteEntity else {
            return
        }
        newNote.title = note.title
        newNote.content = note.content
        newNote.uid = note.uid
        newNote.importance = note.importance.rawValue
        newNote.selfDestuctionDate = note.selfDestructDate
        newNote.creationDate = Date()
        if let color = note.color.noteColorParse() {
            var _newColor: NSManagedObject?
            bgContext.performAndWait {
                _newColor = NSEntityDescription.insertNewObject(forEntityName: "ColorEntity", into: bgContext)
            }
            if let newColor = _newColor as? ColorEntity {
                newColor.r = color["r"] as! Double
                newColor.g = color["g"] as! Double
                newColor.b = color["b"] as! Double
                newColor.a = color["a"] as! Double
                newNote.relationshipColor = newColor
            } else {
                print("Error convert to colorEntity")
            }
        }
        notes.insert(note, at: 0)
    }
    
    func remove(with uid: String) {
        let deleteFetch = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        let predicate = NSPredicate(format: "uid = %@", uid)
        deleteFetch.predicate = predicate
        var result = [NoteEntity]()
        
        bgContext.performAndWait {
            do {
                result = try bgContext.fetch(deleteFetch)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        guard !result.isEmpty else { return }
        for obj in result {
            bgContext.performAndWait {
                bgContext.delete(obj)
            }
        }
        //local
        for (i, j) in notes.enumerated() {
            if j.uid == uid {
                notes.remove(at: i)
            }
        }
    }
    
    func save() {
        self.bgContext.perform {
            do {
                try self.bgContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func loadFromStorage() -> [Note] {
        let fetch = NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        fetch.sortDescriptors = [ sort ]
        var fetchResult = [NoteEntity]()
        var noteResult = [Note]()
       
        bgContext.performAndWait {
            do {
                fetchResult = try bgContext.fetch(fetch)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        guard !fetchResult.isEmpty else { return noteResult}
        
        for obj in fetchResult {
            var noteColor = UIColor.white
            if let colorObj = obj.relationshipColor {
                noteColor = UIColor(red: CGFloat(colorObj.r), green: CGFloat(colorObj.g), blue: CGFloat(colorObj.b), alpha: CGFloat(colorObj.a))
            }
            if let _uid = obj.uid,
                let _title = obj.title,
                let _content = obj.content,
                let _impStr = obj.importance,
                let _importance = ImportancyType(rawValue: _impStr)
            {
                let note = Note(uid: _uid, title: _title, content: _content, color: noteColor, importance: _importance, destructDate: obj.selfDestuctionDate)
                noteResult.append(note)
            }
        }
        return noteResult
    }
    
    
    func loadNewNotes(newNotes: [Note]) {
        notes.removeAll()
        self.bgContext.performAndWait {
            if bgContext.registeredObjects.count != 0 {
                bgContext.reset()
            }
        }
        for obj in newNotes {
            self.add(obj)
        }
    }
    
}
