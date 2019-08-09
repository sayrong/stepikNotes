//
//  SaveNotesBackendOperation.swift
//  Notes
//
//  Created by Dmitriy on 29/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation

enum NetworkError {
    case unreachable
    case baseNotFound
}

enum SaveNotesBackendResult {
    case success
    case failure(NetworkError)
}

class SaveNotesBackendOperation: BaseBackendOperation {
    var result: SaveNotesBackendResult?
    var notes: [Note]
    
    init(notes: [Note]) {
        self.notes = notes
        super.init()
    }
    
    override func main() {
        let manager = NetworkManager.shared()
        if manager.idGistBase == nil {
            if let json = FileNotebook.convertToJson(notes: notes) {
                if let str = String(data: json, encoding: .utf8) {
                    manager.uploadGist(content: str) { (status) in
                        if status {
                            self.result = .success
                            self.finish()
                        } else {
                            self.result = .failure(.unreachable)
                        }
                        
                    }
                }
                
            }
            
        }
        
        
    }
}
