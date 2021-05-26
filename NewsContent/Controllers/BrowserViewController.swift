//
//  BrowserViewController.swift
//  NewsContent
//
//  Created by mozeX on 25.05.2021.
//

import UIKit
import WebKit
import CoreData

class BrowserViewController: UIViewController {

    @IBOutlet weak var browserView: WKWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var savedButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: NewsCategory? {
        didSet {
            loadCategories()
        }
    }
    
    var selectedPlatform: String?
    var newsTitle: String?
    var newsAuthor: String?
    var urlString: String?
    var newsDate: String?
    var isSaved: Bool = false
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        browserView.navigationDelegate = self
        
        if isSaved {
            savedButton.setTitle("Saved", for: .normal)
            savedButton.isUserInteractionEnabled = false
        }
        
        loadWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
        timer?.invalidate()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func savedButtonPressed(_ sender: UIButton) {
        if !isSaved {
            saveNews()
            
            savedButton.setTitle("Saved", for: .normal)
            savedButton.isUserInteractionEnabled = false
        }
    }
}

//MARK: - WEBVIEW DELEGATE

extension BrowserViewController: WKNavigationDelegate {
    private func loadWebView() {
        if let safeString = urlString {
            spinner.startAnimating()
            if let url = URL(string: safeString) {
                
                let request = URLRequest(url: url)
                self.browserView.load(request)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
        spinner.isHidden = true
        
        //Counting feature for live news only
        if !isSaved {
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                self.countNewsToCategory()
            }
        }
    }
}

//MARK: - DATABASE

extension BrowserViewController {
    func loadCategories() {
        let request: NSFetchRequest<SavedNews> = SavedNews.fetchRequest()
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "parentCategory.name MATCHES %@ ", selectedCategory!.name!), NSPredicate(format: "title MATCHES %@", newsTitle!)])
        request.predicate = predicate
        
        do {
            let savedNews = try context.fetch(request)
            
            //Handle saved news
            if savedNews.count > 0 {
                isSaved = true
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func saveNews() {
        //Initialize the context
        let news = SavedNews(context: self.context)
        
        //Putting data
        news.title = newsTitle
        news.author = newsAuthor
        news.publishedAt = newsDate
        news.url = urlString
        news.parentCategory = selectedCategory
        
        do {
            try context.save()
        } catch {
            print("Error when saving data \(error)")
        }
    }
    
    func countNewsToCategory() {
        //Initialize the context
        let request: NSFetchRequest<NewsCategory> = NewsCategory.fetchRequest()
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name MATCHES %@", selectedCategory!.name!),
            NSPredicate(format: "parentPlatform.name MATCHES %@", selectedPlatform!)
        ])
        request.predicate = predicate
        do {
            let category = try context.fetch(request)
            
            // Assume that there is only 1 category in 1 platform
            if category.count == 1 {
                let count = category[0].count + 1
                category[0].setValue(count, forKey: "count")
                do {
                    try context.save()
                } catch {
                    print("Error when saving data for counting \(error)")
                }
            }
        } catch {
            print("Error fetching data from category \(error)")
        }
    }
}
