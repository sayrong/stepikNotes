//
//  LoadNotesBackendOperation.swift
//  Notes
//
//  Created by Dmitriy on 29/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation

enum LoadNotesBackendResult {
    case success([Note])
    case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {
    var result: LoadNotesBackendResult?
    
    override func main() {
        let network = NetworkManager.shared()
        if network.idGistBase == nil {
            let _ = network.loadGistsFromApi { (gist) in
                if let gist = gist {
                    for i in gist {
                        if i.files.first?.value.filename == "ios-course-notes-db" {
                            network.idGistBase = i.id
                            let url = URL(string: i.files.first!.value.raw_url!)
                            if let content = try? Data(contentsOf: url!) {
                                let str = String(data:content, encoding: .utf8)
                                if let notes = FileNotebook.extractFromString(string: str!) {
                                    self.result = .success(notes)
                                    self.finish()
                                    return
                                }
                            }
                        }
                    }
                }
                self.result = .failure(.unreachable)
                self.finish()
            }
        }
        
    }
}
