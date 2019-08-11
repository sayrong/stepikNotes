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
    case dataConvertingError
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
    
    private func prepareContent() -> String? {
        if let json = FileNotebook.convertToJson(notes: notes) {
            if let str = String(data: json, encoding: .utf8) {
                return str
            }
        }
        return nil
    }
    
    override func main() {
        let manager = NetworkManager.shared()
        
        guard let content = prepareContent() else {
            result = .failure(.dataConvertingError)
            finish()
            return
        }
        
        manager.uploadGist(content: content) { (status) in
            if status {
                self.result = .success
            } else {
                self.result = .failure(.unreachable)
            }
            self.finish()
        }
    }
}
