//
//  NetworkManager.swift
//  Notes
//
//  Created by Dmitriy on 09/08/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import Foundation
import CocoaLumberjack

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
    
    //Если известен id нашей базы, запрашиваем сразу ее
    //В противном случае получаем все наши гисты
    func loadGistsFromApi(completion: @escaping ([Gists]?)->()) {
        guard !token.isEmpty else {
            completion(nil)
            return
        }
        let urlComponent = idGistBase == nil ? "" : "\\" + idGistBase!
        let components = URLComponents(string: "https://api.github.com/gists" + urlComponent)
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(nil)
                return
            }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    break
                default:
                    print("Status: \(response.statusCode) - loadGistsFromApi")
                    completion(nil)
                    return
                }
            }
            guard let data = data else {
                DDLogError("Nil data in loadGistsFromApi")
                completion(nil)
                return
            }
            let res = Gists.parseResponse(data: data)
            completion(res)
        }
        task.resume()
    }
    
    //Подготовка контента для базы
    private func prepareContent(content: String) -> Data? {
        let gist = Gists(description: "Stepic db for application Notes", filename: "ios-course-notes-db", content: content)
        
        var data: Data
        do {
            data = try JSONEncoder().encode(gist)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        return data
    }
    
    //Первичная загрузка базы или изменение
    func uploadGist(content: String, completion: @escaping (Bool)->()) {
        
        var isOk: Bool = false
        guard !token.isEmpty else {
            completion(isOk)
            return
        }
        guard let data = prepareContent(content: content) else { return }
        let urlComponent = idGistBase == nil ? "" : "/" + idGistBase!
        let strUlr = "https://api.github.com/gists" + urlComponent
        guard let url = URL(string: strUlr) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = idGistBase == nil ? "POST" : "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = data
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(isOk)
                return
            }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    isOk = true
                    //на случай если нету базы и мы делаем POST
                    if self.idGistBase == nil {
                        let urlWithId = URL(string: response.allHeaderFields["Location"] as! String)
                        self.idGistBase = urlWithId?.lastPathComponent
                    }
                default:
                    print("Status: \(response.statusCode)")
                    completion(isOk)
                }
            }
            completion(isOk)
        }.resume()
    }
    
    
}
