//
//  PhotoCollectionVC.swift
//  VirtualTourist
//
//  Created by Arch Studios on 6/25/19.
//  Copyright © 2019 AS. All rights reserved.
//

import UIKit
import CoreData

class PhotoCollectionVC: UIViewController {
    
    //////////////////////////////////////////////////
    //MARK:- Outlets
    //////////////////////////////////////////////////
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //////////////////////////////////////////////////
    //MARK:- Properties
    //////////////////////////////////////////////////
    var pin: Pin!
    var page = 1
    var perPage = 8
    
    var context: NSManagedObjectContext {
        return DataController.shared.context
    }
    
    var fetchResultsController: NSFetchedResultsController<Photo>!
    
    // This variable is for NSFetchedResultsControllerDelegate to distinguish between asking for a new collection and deleting a photo
    var deleteCollectionPhotos = false
    
    var editButton: UIBarButtonItem!
    
    var isEditButtonTapped = false
    
    var collectionBackgroundColor = UIColor.init(red: 246/255, green: 166/255, blue: 35/255, alpha: 1.0)
    
    
    //////////////////////////////////////////////////
    //MARK:- Life Cycle
    //////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.isHidden = true
        fetch()
    }
    
    var fetchResultsControllerHasPins: Bool {
        return (fetchResultsController?.fetchedObjects?.count ?? 0) != 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Flickr.photosArr = []
        fetchResultsController = nil
    }
    
    
    //////////////////////////////////////////////////
    //MARK:- Custom Functions and Actions
    //////////////////////////////////////////////////
    func fetch() {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDesc = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sortDesc]
        let predicate = NSPredicate(format: "pin == %@", pin)
        request.predicate = predicate
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
            if !fetchResultsControllerHasPins {
                fetchPhoto()
            }
        } catch {
            fatalError("ERROR: Can't fetch Photo")
        }
        
    }
    
    
    fileprivate func fetchPhoto() {
        self.newCollectionButton.isEnabled = false
        
        // setting up activity indicator
        if fetchResultsControllerHasPins {
            activityIndicator.isHidden = true
        } else {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        
        let urlString = Flickr.getURL(latitude: pin.latitude, longitude: pin.longitude, page: page, perPage: perPage)
        
        Flickr.getPhotoURL(urlString: urlString) { (complete, errorMessage) in
            DispatchQueue.main.async {
                
                guard errorMessage == nil else {
                    self.alert(title: "Error", message: errorMessage!)
                    return
                }
                
                guard let complete = complete else {
                    self.alert(title: "Error", message: "Problem fetching data")
                    return
                }
                
                if complete && (Flickr.photosArr.count > 0) {
                    self.navigationItem.title = ""
                    
                    for url in Flickr.photosArr {
        
                        let photo = Photo(context: self.context)
                        photo.pin = self.pin
                        photo.photoURL = url
                        photo.page = Int32(self.page)
                        
                    }
                    
                    self.page += 1
                    Flickr.photosArr = []
                   
                } else {
                    if self.page <= 1 {
                        self.navigationItem.title = "Pin has no photos"
                    } else {
                        self.navigationItem.title = "No more photos"
                    }
                    
                }
                self.newCollectionButton.isEnabled = true
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    
    @IBAction func newCollectionTapped(_ sender: UIBarButtonItem) {
        if fetchResultsControllerHasPins {
            deleteFecthPhotos()
        }
        fetchPhoto()
    }
    
    
    func deleteFecthPhotos() {
        deleteCollectionPhotos = true
        
        guard let photos = fetchResultsController.fetchedObjects else {return}
        
        for photo in photos {
            context.delete(photo)
        }
        
        do {
            try context.save()
        } catch {
            print("Can't delete photos from fetchResultsController")
        }
        
        deleteCollectionPhotos = false
        
    }
    
    
    func save() {
        DispatchQueue.main.async {
            do {
                try self.context.save()
            } catch {
                print("Can't delete photos from fetchResultsController")
            }
        }
    }
    
    func setupNavigationBar() {
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        
        navigationItem.rightBarButtonItem = editButton
        
    }
    
    @objc func editButtonTapped() {
        if isEditButtonTapped {
        
            isEditButtonTapped = false
            editButton.style = .plain
            editButton.title = "Edit"
            self.view.backgroundColor = collectionBackgroundColor
            navigationItem.title = ""
            collectionView.backgroundColor = collectionBackgroundColor
            newCollectionButton.isEnabled = true
            
        } else {
            isEditButtonTapped = true
            editButton.style = .done
            editButton.title = "Done"
            self.view.backgroundColor = .darkGray
            collectionView.backgroundColor = .darkGray
            navigationItem.title = "Delete Mode"
            newCollectionButton.isEnabled = false
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            guard let vc = segue.destination as? DetailVC else {
                alert(title: "Error", message: "Can't show this Image")
                return
            }
            
            guard let photo = sender as? Photo else {
                alert(title: "Error", message: "Can't send this Image to be shown")
                return
            }
            guard let imageData = photo.photoData else {
                print("Can't fetch photo")
                return
            }
            
            vc.photo = UIImage(data: imageData)
        }
    }
}



//////////////////////////////////////////////////
//MARK:-
//MARK:- Extensions
//////////////////////////////////////////////////

//MARK:- NSFetchedResultsControllerDelegate
extension PhotoCollectionVC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        if let indexPath = indexPath, type == .delete && !deleteCollectionPhotos {
            collectionView.deleteItems(at: [indexPath])
            return
        }

        if let indexPath = indexPath, type == .insert {
            collectionView.insertItems(at: [indexPath])
            return
        }

        if let newIndexPath = newIndexPath, let oldIndexPath = indexPath, type == .move {
            collectionView.moveItem(at: oldIndexPath, to: newIndexPath)
            return
        }

        if type != .update {
            collectionView.reloadData()
        }
    }
    
}



//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension PhotoCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // numberOfSections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    // numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultsController?.fetchedObjects?.count ?? 0
    }
    
    
    // cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoImage", for: indexPath) as? PhotoCell else {
            fatalError("Can't dequeue cell")
        }
        cell.imageView.image = nil
        let photo = fetchResultsController.object(at: indexPath)
        
        if photo.photoData != nil {
            let imageData = photo.photoData
            let image = UIImage(data: imageData!)
            cell.imageView.image = image
            return cell
        }

        
        if let imageUrl = photo.photoURL {
            let ai = cell.activityIndicator
            ai?.startAnimating()
            let url = URL(string: imageUrl)
            Flickr.getImage(url: url!) { (data, errorMessage, error) in
                guard error == nil else {
                    self.alert(title: "Error", message: error!.localizedDescription)
                    return
                }
                
                guard errorMessage == nil else{
                    self.alert(title: "Error", message: errorMessage!)
                    return
                }
                
                guard let data = data else {return}
                photo.photoData = data
                
                DispatchQueue.main.async {
                    ai?.stopAnimating()
                    cell.imageView.image = UIImage(data: data)
                }
                
                self.save()
            }
            
        }
        
        return cell
    }
    
    
    // didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = fetchResultsController.object(at: indexPath)
        
        if isEditButtonTapped {
            context.delete(photo)
            do {
                try context.save()
            } catch {
                alert(title: "Error", message: "Didn't erase selected photo")
            }
        } else {
            performSegue(withIdentifier: "toDetail", sender: photo)
        }
        
        
    }
    
}

