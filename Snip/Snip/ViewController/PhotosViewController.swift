//
//  PhotosViewController.swift
//  Snip
//
//  Created by Sameer Khavanekar on 6/23/18.
//  Copyright © 2018 Sameer Khavanekar. All rights reserved.
//

import UIKit
import Photos
import RxSwift

private let reuseIdentifier = "Cell"

class PhotosViewController: UICollectionViewController {
    private lazy var photos = PhotosViewController.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()
    
    private let _disposeBag = DisposeBag()
    private let _selectedPhotosSubject = PublishSubject<UIImage>()
    
    var selectedPhotos: Observable<UIImage> {
        return _selectedPhotosSubject.asObservable()
    }
    private lazy var thumbnailSize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authorizedObserver = PHPhotoLibrary.authorized.share()
        
        // If user has authorized access to photo Library
        authorizedObserver
            .skipWhile{ $0 == false }
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            }).disposed(by: _disposeBag)
        
        // If user denies access to photo library
        authorizedObserver
            .takeLast(1)
            .filter{ $0 == false }
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self._showErrorMessage()
            })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _selectedPhotosSubject.onCompleted()
    }

    // MARK: UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        })
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.flash()
        }
        
        imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, info in
            guard let image = image, let info = info else { return }
            
            if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool, !isThumbnail {
                self?._selectedPhotosSubject.onNext(image)
            }
        })
    }
    
    private func _showErrorMessage() {
        alert(title: "Access Denied!", message: "You can grant access from settings!")
            .asObservable()
            .take(5.0, scheduler: MainScheduler.instance) // After 5 seconds automatically dismiss alert.
            .subscribe(onCompleted: { [weak self] in
                self?.dismiss(animated: false, completion: nil)
                _ = self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: _disposeBag)
    }

}

class PhotoCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    var representedAssetIdentifier: String!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func flash() {
        imageView.alpha = 0
        setNeedsDisplay()
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.imageView.alpha = 1
        })
    }
}

