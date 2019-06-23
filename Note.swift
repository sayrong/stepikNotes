//
//  Note.swift
//  NotesApp
//
//  Created by Dmitriy on 20/06/2019.
//  Copyright © 2019 Dmitriy. All rights reserved.
//

import UIKit

enum ImportancyType {
    case important
    case unimportant
    case ordinary
}

struct Note {
    let title: String
    let content: String
    let color: UIColor
    let uid: String
    let importance: ImportancyType
    let selfDeleteDate: Date?
    
    
    init(title: String, content: String, color: UIColor?, uuid: String?, importance: ImportancyType, selfDeleteDate: Date?) {
        self.title = title
        self.content = content
        
        if let _color = color {
            self.color = _color
        } else {
            self.color = UIColor.white
        }
        
        if let _uuid = uuid {
            self.uid = _uuid
        } else {
            self.uid = UUID().uuidString
        }
        
        self.importance = importance
        self.selfDeleteDate = selfDeleteDate
    }
    
    init(title: String, content: String, importance: ImportancyType) {
        self.init(title: title, content: content, color: nil, uuid: nil, importance: importance, selfDeleteDate: nil)
    }
    
}
