//
//  ImageWriter.swift
//  Snip
//
//  Created by Sameer Khavanekar on 6/23/18.
//  Copyright © 2018 Sameer Khavanekar. All rights reserved.
//

import Foundation
import RxSwift
import Photos

class ImageWriter {
    
    enum ImageErrors: Error {
        case imageSaveFailed
    }
    
    class func save(_ image: UIImage) -> Single<String> {
        return Single<String>.create { (observer) -> Disposable in
            var savedAssetId: String? = nil
            
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                savedAssetId = request.placeholderForCreatedAsset?.localIdentifier
            }, completionHandler: { (success, error) in
                DispatchQueue.main.async {
                    if success, let id = savedAssetId {
                        observer(.success(id))
                    } else {
                        observer(.error(error ?? ImageErrors.imageSaveFailed))
                    }
                }
            })
            return Disposables.create()
        }
    }
}
