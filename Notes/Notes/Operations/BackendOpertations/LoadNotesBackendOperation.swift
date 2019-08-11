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
    
    private func searchDb(_ gist: [Gists], network: NetworkManager) -> Bool {
        for i in gist {
            if i.files.first?.value.filename == "ios-course-notes-db" {
                network.idGistBase = i.id
                let url = URL(string: i.files.first!.value.raw_url!)
                if let content = try? Data(contentsOf: url!) {
                    let str = String(data:content, encoding: .utf8)
                    if let notes = FileNotebook.extractFromString(string: str!) {
                        self.result = .success(notes)
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func findGistId(completion: @escaping(Bool)->()) {
        let network = NetworkManager.shared()
        //загружаем гисты из сети
        network.loadGistsFromApi { (gist) in
            guard let gist = gist else {
                completion(false)
                return
            }
            //ищем базу
            let baseFound = self.searchDb(gist, network: network)
            completion(baseFound)
        }
    }
    
    override func main() {
        findGistId { (baseFound) in
            if !baseFound {
                self.result = .failure(.unreachable)
            }
           self.finish()
        }
    }
    
}
