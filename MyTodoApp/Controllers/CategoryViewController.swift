//
//  CategoryViewController.swift
//  MyToDoApp
//
//  Created by Matias Martinelli on 26/08/2023.

import UIKit
import RealmSwift


class CategoryViewController: SwipeTableViewController {

    //We initialize Realm
    let realm = try! Realm()

    let floatingButton = addButton().floatingButton

    //We create the caregories variable to load it with a collection of Results that are Category objercs
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()

        //This fix the bug where the changes in the NavigationBar wont work
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance

        // change to Light Mode:
        overrideUserInterfaceStyle = .light

        loadCategories()

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



    //MARK: - Floating Button Add new Category

    @objc private func didTapButton() {

        var textField = UITextField()

        let backColor = UIColor.randomFlat().hexValue()

        // create the alert
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: UIAlertController.Style.alert)

        // add an action
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            // Wall will happend when the user click the add item on our UIAlert

            //We append the text to the array only if textfield is not empty
            if textField.text! != ""{

                //**
                //We create a new Category object and we use the title property as TextField.text
                let newCategory = Category()
                newCategory.name = textField.text!
                newCategory.backColor = backColor

                self.save(category: newCategory)
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
            alertTextField.placeholder = "Create new Category"
            //We extend the scope of the alertTextField
            textField = alertTextField
        }

        alert.addAction(action)
        //We add the Dismiss button to the alert
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))

        // show the alert
        self.present(alert, animated: true, completion: nil)


    }


    //MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        welcomeMessage()

        //IF categoriesArray it's no nil use it, otherwise just return 1
               //(Nil coalesing operator)
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // We create the cell fot the TableView with the dequeREusableCell method
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let category = categories?[indexPath.row]

        if let cellColor = UIColor(hexString: categories?[indexPath.row].backColor ?? "1D9BF6") {
            // We change the cell background color
            cell.backgroundColor = cellColor
            //We make the textlabel color contrast from the background color
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cellColor, isFlat: true)
        }

        //We populate the cell the the text that we get from the categoyArray
        cell.textLabel?.text = category?.name ?? "No Categories added yet"

        //We return the cell as expected in the function
        return cell
    }

    //MARK: - Data Manipulation Methods

    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving categry context: \(error)")
        }
    }

    func loadCategories(){
        //We load all the category type objects inside our realm
        categories = realm.objects(Category.self)

        tableView.reloadData()
    }

    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                    tableView.reloadData()
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
    }

    //MARK: - TableView Delegate Methods

    //We perfer the segue when the category is selected
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //We create a reference for the destination VC
        let destinationVC = segue.destination as! ToDoListViewController

        // If the indexPath is not nil, we set de selectdCategory of the ToDoListViewController with the category corresponding at the position of the selected row
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

    func welcomeMessage() {

        if categories?.count == 0 {
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
    }}
