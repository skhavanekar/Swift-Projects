//
//  CollagePreviewViewController.swift
//  Snip
//
//  Created by Sameer Khavanekar on 6/23/18.
//  Copyright © 2018 Sameer Khavanekar. All rights reserved.
//

import UIKit
import RxSwift

class CollagePreviewViewController: UIViewController {
    @IBOutlet weak var addPhotoButton: UIBarButtonItem!
    @IBOutlet weak var collageImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    private var _images = Variable<[UIImage]>([])
    private var _disposeBag = DisposeBag()
    private let _maxImages = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imagesObserver = _images.asObservable().throttle(0.5, scheduler: MainScheduler.instance).share(replay: 1, scope: SubjectLifetimeScope.forever) // Throttle request coming in
            
        imagesObserver
            .debounce(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self](images) in
            guard let imageView = self?.collageImageView else { return }
            imageView.image = UIImage.collage(images: images, size: imageView.frame.size)
        }).disposed(by: _disposeBag)
        
        imagesObserver
            .subscribe(onNext: { [weak self](images) in
            self?._updateUI(images)
        }).disposed(by: _disposeBag)
    }
    
    private func _updateUI(_ images: [UIImage]) {
        clearButton.isEnabled = images.count > 0
        addPhotoButton.isEnabled = images.count < _maxImages
        saveButton.isEnabled = images.count > 0 && images.count % 2 == 0
    }
    
    private func _updateNavigation() {
        let image = self.collageImageView.image?.scaled(CGSize(width: 22, height: 22)).withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
    }
    
    @IBAction func clearAction(_ sender: Any) {
        _images.value = []
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let image = collageImageView.image else { return }
        ImageWriter.save(image).subscribe(onSuccess: { (savedId) in
            print("Image saved as \(savedId)")
        }) { (error) in
            print("Error saving image \(error)")
        }.disposed(by: _disposeBag)
    }
    
    @IBAction func addAction(_ sender: Any) {
        let selectPhotoViewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        let sharedObservable = selectPhotoViewController.selectedPhotos.share()
        _addPhotoViewObserver(sharedObservable)
        self.navigationController?.pushViewController(selectPhotoViewController, animated: true)
    }
    
    private func _addPhotoViewObserver(_ sharedObservable: Observable<UIImage>) {
        // Just allow landscape images
        sharedObservable
            .takeWhile({ [weak self](image) -> Bool in
                (self?._images.value.count ?? 0) < (self?._maxImages ?? 6)
            })
            .filter{ $0.size.width > $0.size.height }
            .subscribe(onNext: { [weak self](image) in
                guard let images = self?._images else { return }
                images.value.append(image)
            }) {
                print("Disposed!")
            }.disposed(by: _disposeBag)
        
        
        sharedObservable
            .ignoreElements()
            .subscribe(onCompleted: { [weak self] in
                self?._updateNavigation()
            }).disposed(by: _disposeBag)
    }
    
    
}
