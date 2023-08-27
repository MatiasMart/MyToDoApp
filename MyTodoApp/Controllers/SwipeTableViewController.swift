//
//  SwipeTableViewController.swift
//  MyToDoApp
//
//  Created by Matias Martinelli on 26/08/2023.



import Foundation
import UIKit


class SwipeTableViewController: UITableViewController {

    override func viewDidLoad() {

    }


   override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in

            self.updateModel(at: indexPath)

            completionHandler(true)
        }
        //We add the trash icon
        deleteAction.image = UIImage(systemName: "trash")
        //We set the background color to red
        deleteAction.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    func updateModel(at indexPath: IndexPath) {

    }


}
