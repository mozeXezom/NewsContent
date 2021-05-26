//
//  Constans.swift
//  NewsContent
//
//  Created by mozeX on 25.05.2021.
//

struct E {
    struct SegueManager {
        static let introToCategory = "introToCategory"
        static let categoryToSummary = "categoryToSummary"
        static let summaryToWeb = "summaryToWeb"
        static let categoryToSave = "categoryToSave"
        static let saveToBrowser = "saveToBrowser"
    }
    
    struct CellManager {
        static let categoryCell = "CategoryCell"
        static let summaryCell = "SummaryCell"
        static let categoryCellIdentifier = "categoryReusableCell"
        static let summaryCellIdentifier = "summaryNewsReusableCell"
        static let newsListCellIdentifier = "newsListResuableCell"
    }
    
    struct Platform {
        static let trad = "traditional"
    }
    
    struct URLManager {
        static let traditionalDomain = "https://newsapi.org/v2/top-headlines?country=au&apiKey=e2a69f7f9567451ba484c85614356c30"
    }
}

