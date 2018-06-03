//
//  ListDataSource.swift
//  Mooskine
//
//  Created by Edno Fedulo on 02/06/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ListDataSource<ObjectType: NSManagedObject, CellType: UITableViewCell>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var fRC:NSFetchedResultsController<ObjectType>!
    
    var configureFunction: (CellType, ObjectType) -> Void
    
    var tableView:UITableView!
    var managedObjectContext: NSManagedObjectContext!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fRC != nil, let sections = fRC.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if fRC != nil, let sections = fRC.sections {
            return sections.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: delete(at: indexPath)
        default: () // Unsupported
        }
    }
    
    func delete(at indexPath: IndexPath){
        let objToDelete = fRC.object(at: indexPath)
        managedObjectContext.delete(objToDelete)
        try? managedObjectContext.save()
    }
    
    func addNotebook(name:String){
        let notebook = Notebook(context: managedObjectContext)
        notebook.name = name
        try? managedObjectContext.save()
    }
    
    func addNote(notebook:Notebook){
        let note = Note(context: managedObjectContext)
        note.attributedText = NSAttributedString(string: "New Note")
        note.notebook = notebook
        try? managedObjectContext.save()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = fRC.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(CellType.self)", for: indexPath) as! CellType
        
        configureFunction(cell, object)
        
        return cell
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
    init(tableView: UITableView, managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<ObjectType>, configure: @escaping (CellType, ObjectType) -> Void) {
        
        self.fRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.configureFunction = configure
        self.tableView = tableView
        self.managedObjectContext = managedObjectContext
        
        super.init()
        
        fRC.delegate = self
        
        do {
            try fRC.performFetch()
        } catch {
            fatalError("the shit just hitted the fan: \(error.localizedDescription)")
        }
        
    }
}
