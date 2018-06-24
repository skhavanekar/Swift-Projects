//
//  UIViewController+rx.swift
//  Snip
//
//  Created by Sameer Khavanekar on 6/24/18.
//  Copyright © 2018 Sameer Khavanekar. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {
    
    func alert(title: String, message: String) -> Completable {
        return Completable.create { [weak self](observer) -> Disposable in
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                observer(.completed)
            }))
            self?.present(alertVC, animated: true, completion: nil)
            return Disposables.create()
        }
    }
    
    
}
