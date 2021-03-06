//
//  PHPhotoLibrary+rx.swift
//  Snip
//
//  Created by Sameer Khavanekar on 6/24/18.
//  Copyright © 2018 Sameer Khavanekar. All rights reserved.
//

import Foundation
import Photos
import RxSwift

extension PHPhotoLibrary {
    
    static var authorized: Observable<Bool> {
        return Observable.create { observer in
            if authorizationStatus() == .authorized {
                observer.onNext(true)
                observer.onCompleted()
            } else {
                observer.onNext(false)
                
                requestAuthorization({ (newStatus) in
                    observer.onNext(newStatus == .authorized)
                    observer.onCompleted()
                })
            }
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
        
        
    }
    
    
}
