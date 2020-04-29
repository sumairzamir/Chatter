//
//  CombinationsViewController.swift
//  MuayThaiNotes
//
//  Created by Sumair Zamir on 26/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//FORCE PORTRAIT MODE ONLY

class CombinationsViewController: UITableViewController {
    
    @IBOutlet weak var addCombinationButton: UIBarButtonItem!
    
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Combinations>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        
        
    }
    
    @IBAction func addCombinationAction(_ sender: Any) {
        addCombination()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let reuseIdentifier = "CombinationsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CombinationsCell
        
        let aCombination = fetchedResultsController.object(at: indexPath)
        
//        cell.textLabel?.text = aCombination.comboNumber
        cell.combinationLabel?.text = aCombination.comboNumber
        return cell
    }
    
    func addCombination() {
        
        let combination = Combinations(context: dataController.viewContext)
        combination.comboNumber = "Combination \(fetchedResultsController.fetchedObjects!.count + 1)"
        combination.creationDate = Date()
        try? dataController.viewContext.save()
        
    }
    
    
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Combinations> = Combinations.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "comboId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError()
        }
    }
    
}

extension CombinationsViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            break
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            break
        default:
            break
        }
    }
    
//  Is this needed?
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        let indexSet = IndexSet(integer: sectionIndex)
//        switch type {
//        case .insert: tableView.insertSections(indexSet, with: .fade)
//        case .delete: tableView.deleteSections(indexSet, with: .fade)
//        case .update, .move:
//            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
//        }
//    }

    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
