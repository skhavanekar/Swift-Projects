//
//  ContactsViewController.swift
//  PhoneBook
//
//  Created by Sameer Khavanekar on 6/23/18.
//  Copyright © 2018 Sameer Khavanekar. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {
    @IBOutlet weak var contactTableView: UITableView!
    
    private var _contacts: []
    

}

extension ContactsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
}
