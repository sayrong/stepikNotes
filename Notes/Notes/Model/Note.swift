//
//  Note.swift
//  NotesApp
//
//  Created by Dmitriy on 20/06/2019.
//  Copyright © 2019 Dmitriy. All rights reserved.
//

import UIKit

enum ImportancyType: String {
    case important
    case unimportant
    case normal
}

struct Note {
    let title: String
    let content: String
    let color: UIColor
    let uid: String
    let importance: ImportancyType
    let selfDestructDate: Date?
    
    
    init(uid: String = UUID().uuidString, title: String, content: String, color: UIColor = UIColor.white, importance: ImportancyType, destructDate: Date? = nil) {
        self.title = title
		self.color = color
		self.uid = uid
        self.content = content
        self.importance = importance
        self.selfDestructDate = destructDate
    }
	
}
