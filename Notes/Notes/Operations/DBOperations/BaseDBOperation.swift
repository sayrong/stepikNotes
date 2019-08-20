//
//  BaseDBOperation.swift
//  Notes
//
//  Created by Dmitriy on 29/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation

class BaseDBOperation: AsyncOperation {
    let notebook: NoteStorageProtocol
    
    init(notebook: NoteStorageProtocol) {
        self.notebook = notebook
        super.init()
    }
}
