//
//  NewsManager.swift
//  NewsContent
//
//  Created by mozeX on 25.05.2021.
//

import Foundation

protocol NewsManagerDelegate {
    func didUpdateNews(_ newsManager: NewsManager, articleStore: [[String: String]])
}

class NewsManager {
    
    var platform: String
    
    var delegate: NewsManagerDelegate?
    
    init(_ platform: String) {
        self.platform = platform
    }
    
    func fetchData(with category: String, query text: String?) {
        
        let urlString = customizeURL(with: category, with: text)
        
        if let url = URL.init(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    return
                } else {
                    if let newsData = data {
                        if let articleStore = self.parseJSON(newsData) {
                            var articles: [[String: String]] = []
                            
                            //Converting stored objects
                            if let store = articleStore as? NewsModel {
                                
                                let objects = store.articles
                                for obj in objects {
                                    if let title = obj.title, let author = obj.author, let description = obj.description, let date = obj.publishedAt, let sourceName = obj.source["name"] {
                                        let tempDict: [String: String] = [
                                            "title": title,
                                            "author": author,
                                            "description": description,
                                            "publishedAt": date,
                                            "source": sourceName ?? "Unknown"
                                        ]
                                        articles.append(tempDict)
                                    }
                                }
                            }
                            self.delegate?.didUpdateNews(self, articleStore: articles)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    private func parseJSON(_ newsData: Data) -> Any? {
        let decoder = JSONDecoder()
        do {
            var decodedData: Any?
            
            if platform == E.Platform.trad {
                decodedData = try decoder.decode(NewsModel.self, from: newsData)
            }
            return decodedData
        } catch {
            return nil
        }
    }
    
    private func customizeURL(with category: String, with query: String?) -> String {
        var urlString: String = "Unknown"
        
        if platform == E.Platform.trad {
            urlString = E.URLManager.traditionalDomain
            urlString += "&category=\(category)&pageSize=100"
        }
        
        return urlString
    }
}
