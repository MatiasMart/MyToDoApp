//
//  TodoListViewController.swift
//  MyToDoApp
//
//  Created by Matias Martinelli on 26/08/2023.


import UIKit
import RealmSwift
import Chameleon


class ToDoListViewController: SwipeTableViewController {

    //We initialize Realm
    let realm = try! Realm()
    var todoItems: Results<Item>?

    @IBOutlet weak var searchBar: UISearchBar!


    let floatingButton = addButton().floatingButton

    //As soon as selectedCategory has a value, we load the items
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }

    //We create a file path for out data
    let dataFilePath = FileManager.default.urls(for: .documentDirectory , in: .userDomainMask).first?.appendingPathComponent("Item.plist")


    let defaults = UserDefaults.standard


    override func viewDidLoad() {

        super.viewDidLoad()

        //This fix the bug where the changes in the NavigationBar wont work
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        if let colorHex = selectedCategory?.backColor {
            let color = UIColor(hexString: colorHex)!
            appearance.backgroundColor = UIColor(hexString: colorHex)
            title = selectedCategory!.name
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)]
            searchBar.barTintColor = color
            searchBar.searchTextField.backgroundColor = UIColor.flatWhite()
        }
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance

        // change to Light Mode:
        overrideUserInterfaceStyle = .light

        //Button
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        

    }

    //Button
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        floatingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 345).isActive = true
        floatingButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
    }

    //MARK: - TableView DataSource Methods
    //We need to created the two necesary methods for the TableView DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        welcomeMessage()
        //IF todoItems it's no nil use it, otherwise just return 1
        //(Nil coalesing operator)
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // We create the cell fot the TableView with the dequeREusableCell method
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        //If todoItems it's no nil, then grab the item at the index row
        if let item = todoItems?[indexPath.row] {

            //We populate the cell the the text that we get from the itemArray
            cell.textLabel?.text = item.title
            //We make the checkmark blue
            cell.tintColor = UIColor.systemBlue
            //We change the cell background color
            if let color = UIColor(hexString: selectedCategory!.backColor)?.darken(byPercentage: CGFloat(indexPath.row)*0.4/CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
            }


            // We use the Ternary operator to check if item.done its true or false, and we set the value of the accessory depending on that boolean
            cell.accessoryType = item.done ? .checkmark : .none

        } else {
            cell.textLabel?.text = "No Items Added"
        }

        //We return the cell as expected in the function
        return cell
    }

    //MARK: - TableView Delegate Methods


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //If todoItems it's no nil, we are going to try to modfy its done attribute
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }



        tableView.reloadData()


        //We make the grey selection indicator desapear after row selected
        tableView.deselectRow(at: indexPath, animated: true)

    }

    //MARK: - Floating Button Add new Item

   @objc private func didTapButton() {

         var textField = UITextField()

         // create the alert
         let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: UIAlertController.Style.alert)

         // add an action
         let action = UIAlertAction(title: "Add Item", style: .default) { action in
             // Wall will happend when the user click the add item on our UIAlert

             //We append the text to the array only if textfield is not empty
             if textField.text! != ""{

                 if let currentCategory = self.selectedCategory {
                     do {
                         try self.realm.write {
                             let newItem = Item()
                             newItem.title = textField.text!
                             newItem.dateCreated = Date()
                             currentCategory.items.append(newItem)
                         }
                     } catch {
                         print("Error saving categry context: \(error)")
                     }

                 }

                 //We reload the table view to show the new data
                 self.tableView.reloadData()

             } else {

                 //If the textField its empty we show an alert
                 let alert = UIAlertController(title: "You forgot to add something to your list!", message: "", preferredStyle: UIAlertController.Style.alert)

                 self.present(alert, animated: true, completion: nil)

                 //We dismiss the alert after 1.5 seconds
                 DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
                 {
                     self.dismiss(animated: true, completion: nil)
                 }
             }
         }

         //We create the textField
         alert.addTextField { (alertTextField) in
             //We add a placeholder for the textField
             alertTextField.placeholder = "Create new item"
             //We extend the scope of the alertTextField
             textField = alertTextField
         }

         alert.addAction(action)

         //We add the Dismiss button to the alert
         alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))

         // show the alert
         self.present(alert, animated: true, completion: nil)
     }


    //MARK: - Model Manipulation Methods

    //We create a new function to get the information from the DataBase
    func loadItems(){

        //We load all the items that are related to the selected category
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }


    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                    tableView.reloadData()
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
    }

}

//MARK: - UISearchBar Delegate Methods

extension ToDoListViewController: UISearchBarDelegate {

    //Every time the user type we search for that character and if the search bar its empty we bring all the items
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        //We set the cancel button color to systemBlue
        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)

        //We make the cancel button apear
        searchBar.showsCancelButton = true

        //We populte todoItems only with the filtered items
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

        //If the searchbar it's empty, we call loaditems() so the user can see all the items in the list
        //without the need to hit search again
        if searchBar.text?.count == 0 {
            loadItems()
        }
        tableView.reloadData()

    }


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
    }


    //When the search button it's clickeed we clear the searchbar, we remove the cancel button,
    // we remove the keyboard, and we lead the full list of items
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = nil
            searchBar.showsCancelButton = false

            // remove focus from the searchbar
            searchBar.endEditing(true)
            searchBar.resignFirstResponder()

            loadItems()
            }

    func welcomeMessage() {

        if todoItems?.count == 0 {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text = "Add your frist Item"
            emptyLabel.textAlignment = NSTextAlignment.center

            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none

            let imageV = UIImageView(frame: CGRect(x: 50, y: 100, width: 200, height: 150))
            imageV.center = view.center
            imageV.clipsToBounds = true
            imageV.image = UIImage(named: "curved.png", in: Bundle(for: type(of: self)), compatibleWith: nil)
            imageV.transform = imageV.transform.rotated(by: .pi / 1.9)

            view.addSubview(imageV)
        }else {
            // Remove the empty label and image view
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine

            for subview in view.subviews {
                if let imageView = subview as? UIImageView {
                    imageView.removeFromSuperview()
                }
            }
        }
    }

}
