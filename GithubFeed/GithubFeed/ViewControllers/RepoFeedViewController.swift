//
//  RepoFeedViewController.swift
//  GithubFeed
//
//  Created by Sameer Khavanekar on 6/24/18.
//  Copyright © 2018 Sameer Khavanekar. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class RepoFeedViewController: UITableViewController {
    private let _repo = "skhavanekar/Swift-Projects"
    private let _events = Variable<[GitFeedEvent]>([])
    private let _disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = _repo
        
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        
        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(RepoFeedViewController.refresh), for: .valueChanged)
        
        refresh()
    }
    
    @objc func refresh() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.fetchEvents(repo: strongSelf._repo)
        }
    }
    
    func fetchEvents(repo: String) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _events.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = _events.value[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = event.actor.name
        cell.detailTextLabel?.text = event.repo + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
        cell.imageView?.kf.setImage(with: event.actor.imageURL, placeholder: UIImage(named: "blank-avatar"))
        return cell
    }

}
