//
//  ViewController.swift
//  NewsContent
//
//  Created by mozeX on 25.05.2021.
//

import UIKit
import CoreData

class CategoriesViewController: UITableViewController {
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categories = [NewsCategory]()
    var currentRow = 0
    var modalView: ModalView!
    var isModal: Bool = false
    var savedMode: Bool = false
    
    var newsChoice: NewsPlatform? {
        didSet {
            loadCategories()
            
            if categories.count == 0 {
                saveDefaultData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: E.CellManager.categoryCell, bundle: nil), forCellReuseIdentifier: E.CellManager.categoryCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
        
        layoutNavbar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
    
    //MARK: - BAR ITEM BUTTON
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        //Going to previous ViewController
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func barButtonPressed(_ sender: UIBarButtonItem) {
        if isModal {
            modalView.removeFromSuperview()
            barButton.image = UIImage(named: "menu")
        } else {
            barButton.image = UIImage(named: "X.filled")
            tableView.isScrollEnabled = false
        }
        isModal = !isModal
    }
    
    private func layoutNavbar() {
        if savedMode {
              UIView.animate(withDuration: 0.3, animations: {
                  self.navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 0.9451, blue: 0.7373, alpha: 1.0)
                  self.navigationController?.navigationBar.layoutIfNeeded()
              })
          } else {
              UIView.animate(withDuration: 0.3, animations: {
                  self.navigationController?.navigationBar.barTintColor = UIColor.systemYellow
                  self.navigationController?.navigationBar.layoutIfNeeded()
              })
          }
    }
    
    //MARK: - Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == E.SegueManager.categoryToSummary || segue.identifier == E.SegueManager.categoryToSave {
            if let destination = segue.destination as? SummaryNewsViewController {
                destination.selectedPlatform = newsChoice?.name
                destination.selectedCategory = categories[currentRow]
            } else if let destination = segue.destination as? SavedNewsViewController {
                destination.selectedPlatform = newsChoice?.name
                destination.selectedCategory = categories[currentRow]
            }
        }
    }
}

//MARK: - UITablView Delegate, Datascource
extension CategoriesViewController {
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: E.CellManager.categoryCellIdentifier, for: indexPath) as! CategoryCell
        
        let name = categories[indexPath.row].name!
        
        cell.categoryImage.image = UIImage(named: name.lowercased())
        cell.categoryLabel.text = name
        
        return cell
    }
    
    //MARK: - Data Delegate Method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentRow = indexPath.row
        
        if savedMode {
            performSegue(withIdentifier: E.SegueManager.categoryToSave, sender: self)
        } else {
            performSegue(withIdentifier: E.SegueManager.categoryToSummary, sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Database
extension CategoriesViewController {
    //MARK: - Default data
    func saveDefaultData() {
        var temp: [String]
        let choice = newsChoice!.name!
        
        if choice == E.Platform.trad {
            temp = ["Business", "General", "Health", "Sports"]
            
            for name in temp {
                let newCategory = NewsCategory(context: self.context)
                newCategory.name = name
                newCategory.count = 0
                newCategory.parentPlatform = newsChoice!
                
                categories.append(newCategory)
                saveCategories()
            }
            
            tableView.reloadData()
        }
        
    }
        
        //MARK: - Save to database
    func saveCategories() {
            do {
                try context.save()
            } catch {
                print("Error saving categories \(error)")
            }
        }
        
    func loadCategories() {
            let request: NSFetchRequest<NewsCategory> = NewsCategory.fetchRequest()
            let predicate = NSPredicate(format: "parentPlatform.name MATCHES %@", newsChoice!.name!)
            request.predicate = predicate
            
            do {
                categories = try context.fetch(request)
            } catch {
                print("Error fetching data from context \(error)")
        }
    }
    
}

