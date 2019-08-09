//
//  NetworkManager.swift
//  Notes
//
//  Created by Dmitriy on 09/08/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation


struct Gists: Codable {
    //Дата создания
    let created_at: String?
    //Количество комментариев
    let comments: Int?
    let files: [String: GistFile]
    let owner: Owner?
    let `public`: Bool?
    let description: String?
    let id: String?
    
    static func parseResponse(data: Data) -> [Gists]? {
        var result = [Gists]()
        do {
            result = try JSONDecoder().decode([Gists].self, from: data)
        } catch {
            print("Error \(error.localizedDescription)")
            return nil
        }
        return result
    }
    
    //Default init
    init(created_at: String?, comments: Int?, files: [String: GistFile], owner: Owner?, `public`: Bool?, description: String?, id: String?) {
        self.created_at = created_at
        self.comments = comments
        self.files = files
        self.owner = owner
        self.public = `public`
        self.description = description
        self.id = id
    }
    
    
    //Для создания POST запроса
    init(description: String, filename: String, content:String) {
        let file = GistFile(filename: filename, type: nil, language: nil, raw_url: nil, size: nil, content: content)
        self.init(created_at: nil, comments: nil, files: [filename:file], owner: nil, public: nil, description: description, id: nil)
    }
    
}

struct Owner: Codable {
    let login: String
    let avatar_url: String
}

struct GistFile: Codable {
    let filename: String?
    let type: String?
    let language: String?
    let raw_url: String?
    let size: Int?
    let content: String?
}

class NetworkManager {
    
    //Singleton
    private static var sharedNetworkManager: NetworkManager = {
        let network = NetworkManager()
        return network
    }()
    
    class func shared() -> NetworkManager {
        return sharedNetworkManager
    }
    
    var token = ""
    var idGistBase: String?
    
    func loadGistsFromApi(completion: @escaping ([Gists]?)->()) {
        let components = URLComponents(string: "https://api.github.com/users/sayrong/gists")
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    break
                default:
                    print("Status: \(response.statusCode)")
                }
            }
            guard let data = data else { return }
            let res = Gists.parseResponse(data: data)
            if let res = res {
                completion(res)
            }
        }
        task.resume()
    }
    
    func uploadGist(content: String, completion: @escaping (Bool)->()) {
        
        var isOk: Bool = false
        
        let gist = Gists(description: "Stepic db for application Notes", filename: "ios-course-notes-db", content: content)
        
        var data: Data
        do {
            data = try JSONEncoder().encode(gist)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        print(String(data: data, encoding: .utf8)!)
        
        guard let url = URL(string: "https://api.github.com/gists") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = data
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    print("Success")
                    isOk = true
                default:
                    print("Status: \(response.statusCode)")
                }
            }
            completion(isOk)
        }.resume()
    }
    
}
