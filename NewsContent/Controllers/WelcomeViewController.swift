//
//  WelcomeViewController.swift
//  NewsBucket
//
//  Created by Peter Du on 12/5/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import UIKit
import CoreData

class WelcomeViewController: UIViewController {

    @IBOutlet weak var traditionalNewsButton: UIButton!
    
    var platforms = [NewsPlatform]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var newsChoice = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        traditionalNewsButton.layer.cornerRadius = 10
        
        // Load data from CoreData
        loadPlatforms()
        
        // Write data if there is no data yet
        if platforms.count == 0 {
            saveDefaultData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.navigationBar.barTintColor = UIColor.systemYellow
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if sender == traditionalNewsButton {
            newsChoice = E.Platform.trad
        }
        
        performSegue(withIdentifier: E.SegueManager.introToCategory, sender: self)
    }
    
    //MARK: - Segue preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == E.SegueManager.introToCategory {
            if let destination = segue.destination as? CategoriesViewController {
                let tradi = E.Platform.trad
                destination.newsChoice = (newsChoice == E.Platform.trad) ? platforms[0] : nil
                }
       }
    }
    
    //MARK: - Default Data
    func saveDefaultData() {
        let temp = ["traditional", "developer"]
        for name in temp {
            let newPlatform = NewsPlatform(context: self.context)
            newPlatform.name = name
            platforms.append(newPlatform)
            savePlatform()
        }
    }
}

//MARK: - Database
extension WelcomeViewController {
    func savePlatform() {
        do {
            try context.save()
        } catch {
            print("Error saving platforms \(error)")
        }
    }
    
    func loadPlatforms() {
        let request: NSFetchRequest<NewsPlatform> = NewsPlatform.fetchRequest()
        
        do {
            platforms = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
}
