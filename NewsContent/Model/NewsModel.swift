//
//  NewsModel.swift
//  NewsContent
//
//  Created by mozeX on 25.05.2021.
//

import Foundation

//MARK: - API Section

struct NewsModel: Decodable {
    let articles: [Article]
}

struct Article: Decodable {
    let source: [String: String?]
    let author: String?
    let title: String?
    let description: String?
    let publishedAt: String?
}
