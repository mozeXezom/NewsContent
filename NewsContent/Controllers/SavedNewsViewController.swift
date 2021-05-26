//
//  SavedNewsViewController.swift
//  NewsContent
//
//  Created by mozeX on 25.05.2021.
//

import UIKit
import CoreData

class SavedNewsViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedPlatform: String?
    var selectedCategory: NewsCategory? {
        didSet {
            loadSavedNews()
        }
    }
    
    var savedNews = [SavedNews]()
    var selectedMode: Int = 0
    var selectedRaw = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: E.CellManager.summaryCell, bundle: nil), forCellReuseIdentifier: E.CellManager.newsListCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: - UISegmentControl Actions
    
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        selectedMode = sender.selectedSegmentIndex
        
        //Reload the tableView
        if let visibleRows = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: visibleRows, with: .automatic)
        }
    }
    
    //MARK: - SEGUE PREPATATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == E.SegueManager.saveToBrowser {
            if let destination = segue.destination as? BrowserViewController {
                let article = savedNews[selectedRaw]
                
                destination.newsTitle = article.title
                destination.urlString = article.url
                destination.selectedCategory = selectedCategory
            }
        }
    }
}

extension SavedNewsViewController {
    //MARK: - DataSource Method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedNews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: E.CellManager.newsListCellIdentifier, for: indexPath) as! SummaryCell
        
        let article = savedNews[indexPath.row]
        
        // Custom the summary cell
        cell.selectedMode = selectedMode
        if let articleTitle = article.title {
            cell.titleLabel.text = articleTitle
        }
        
        if let date = article.publishedAt {
            cell.dateLabel.text = "Date: \(date)"
        } else {
            cell.dateLabel.text = "Unknown"
        }
        
        if selectedPlatform! == E.Platform.trad {
            cell.sourceLabel.text = "Published by: \n \(article.source ?? "Unknown")"
        }
        
        return cell
    }
    
    //MARK: - Data Delegate Method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRaw = indexPath.row
        
        if selectedMode == 0 {
            if selectedPlatform == E.Platform.trad {
                    performSegue(withIdentifier: E.SegueManager.saveToBrowser, sender: self)
                }
        } else {
            deleteNews(at: indexPath)
            tableView.reloadData()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Database interation
extension SavedNewsViewController {
    func loadSavedNews() {
        let request: NSFetchRequest<SavedNews> = SavedNews.fetchRequest()
        let predicate = NSPredicate(format: "parentCategory.name MATCHES %@ ", selectedCategory!.name!)
        request.predicate = predicate
        
        do {
            savedNews = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func deleteNews(at indexPath: IndexPath) {
        // Delete From NSObject
        context.delete(savedNews[indexPath.row])
        
        // Delete From current News list
        savedNews.remove(at: indexPath.row)
        
        // Save deletion
        do {
            try context.save()
        } catch {
            print("Error when saving data \(error)")
        }
    }
}

