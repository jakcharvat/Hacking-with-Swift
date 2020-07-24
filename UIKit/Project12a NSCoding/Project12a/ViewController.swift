//
//  ViewController.swift
//  Project12a
//
//  Created by Jakub Charvat on 28/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people: [Person] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Names to Faces"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        load()
    }
    
    @objc private func addNewPerson() {
        let picker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
}


//MARK: - Collection View
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        
        let person = people[indexPath.item]
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        
        cell.name.text = person.name
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let ac = UIAlertController(title: "Choose an action", message: "What would you like to do with the selected person?", preferredStyle: .actionSheet)
        let renameAction = UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            self?.renamePerson(at: indexPath)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deletePerson(at: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.popoverPresentationController?.sourceView = collectionView.cellForItem(at: indexPath)
        
        ac.addAction(renameAction)
        ac.addAction(deleteAction)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    
    private func renamePerson(at indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?.first?.text else { return }
            person.name = newName
            
            self?.collectionView.reloadItems(at: [indexPath])
            self?.save()
        }
        
        ac.addTextField()
        ac.addAction(cancelAction)
        ac.addAction(saveAction)
        
        present(ac, animated: true)
    }
    
    private func deletePerson(at indexPath: IndexPath) {
        let ac = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
        ac.popoverPresentationController?.sourceView = collectionView.cellForItem(at: indexPath)
        let keepAction = UIAlertAction(title: "Keep", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.people.remove(at: indexPath.item)
            self?.save()
            self?.collectionView.deleteItems(at: [indexPath])
        }
        
        ac.addAction(keepAction)
        ac.addAction(deleteAction)
        
        present(ac, animated: true)
    }
}


//MARK: - Image Picker Delegate
extension ViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let indexPath = IndexPath(item: people.count, section: 0)
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        
        save()
        collectionView.insertItems(at: [indexPath])
        
        dismiss(animated: true)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


//MARK: - User Defaults
extension ViewController {
    private func save() {
        guard let saveData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) else { return }
        UserDefaults.standard.set(saveData, forKey: "people")
    }
    
    private func load() {
        guard let data = UserDefaults.standard.object(forKey: "people") as? Data else { return }
        guard let people = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Person] else { return }
        
        self.people = people
    }
}
