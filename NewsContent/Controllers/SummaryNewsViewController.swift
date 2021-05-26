//
//  SummaryNewsViewController.swift
//  NewsContent
//
//  Created by mozeX on 25.05.2021.
//

import UIKit

class SummaryNewsViewController: UITableViewController {
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var articles: [[String: String]] = []
    var newsManager: NewsManager!
    var currentRow = 0
    
    var selectedPlatform: String? {
        didSet {
            newsManager = NewsManager(self.selectedPlatform!)
        }
    }
    
    var selectedCategory: NewsCategory? {
        didSet {
            newsManager.fetchData(with: self.selectedCategory!.name!, query: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newsManager.delegate = self
        searchBar.delegate = self
        
        //Register our summaryCell
        
        tableView.register(UINib(nibName: E.CellManager.summaryCell, bundle: nil), forCellReuseIdentifier: E.CellManager.summaryCellIdentifier)
        spinner.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        //Going back to previous ViewController
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - LAYOUT SEARCHBAR
    private func layoutSearchBar() {
        if let safePlatform = selectedPlatform {
            if safePlatform == E.Platform.trad {
                searchBar.isHidden = true
                searchBar.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            }
        }
    }
}

//MARK: - NEWS MANAGER DELEGATE
extension SummaryNewsViewController: NewsManagerDelegate {
    func didUpdateNews(_ newsManager: NewsManager, articleStore: [[String: String]]) {
        DispatchQueue.main.async {
            self.articles = articleStore
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
            self.tableView.reloadData()
        }
    }
}

//MARK: - TABLE VIEW DELEGATE, DATASOURCE

extension SummaryNewsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //update current row index
        currentRow = indexPath.row
        
        //perform segue
        
        let identifier = (selectedPlatform! == E.Platform.trad) ?
        E.SegueManager.summaryToWeb : nil
        performSegue(withIdentifier: identifier!, sender: self)
        
        //Animation for row deselection
        tableView.deselectRow(at: indexPath, animated: true)
        }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: E.CellManager.summaryCellIdentifier, for: indexPath) as! SummaryCell
        let article = articles[indexPath.row]
    
        if let articleTitle = article["title"] {
            cell.titleLabel.text = articleTitle
        }
        
        if let date = article["publishedAt"] {
            let formattedDate = Utils.reformatDate(from: date, with: selectedPlatform!)
            cell.dateLabel.text = "Date: \(formattedDate)"
        } else {
            cell.dateLabel.text = "Unknown"
        }
        
        if selectedPlatform == E.Platform.trad {
            cell.sourceLabel.text = "Published by: \n \(article["source"] ?? "Unknown")"
        }
        return cell
    }
}

//MARK: - SEARCHBAR DELEGATE
extension SummaryNewsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        articles.removeAll()
        newsManager.fetchData(with: self.selectedCategory!.name!, query: searchBar.text!)
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            articles.removeAll()
            newsManager.fetchData(with: self.selectedCategory!.name!, query: nil)
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
