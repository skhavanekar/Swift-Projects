//
//  RepoFeedViewController.swift
//  GithubFeed
//
//  Created by Sameer Khavanekar on 6/24/18.
//  Copyright © 2018 Sameer Khavanekar. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

func cachedFileURL(_ fileName: String) -> URL {
    return FileManager.default
        .urls(for: .cachesDirectory, in: .allDomainsMask)
        .first!
        .appendingPathComponent(fileName)
}

class RepoFeedViewController: UITableViewController {
    private let _repo = "skhavanekar/Swift-Projects"
    private let _events = Variable<[GitFeedEvent]>([])
    private let _disposeBag = DisposeBag()
    
    private let _eventsFileURL = cachedFileURL("events.plist")
    private let _modifiedFileURL = cachedFileURL("modified.plist")
    private let _lastModified = Variable<NSString?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = _repo
        
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        
        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(RepoFeedViewController.refresh), for: .valueChanged)
        
        let eventsArray = NSArray(contentsOf: _eventsFileURL) as? [[String: Any]] ?? []
        _events.value = eventsArray.compactMap { GitFeedEvent(JSON: $0)! }
        _lastModified.value = try? NSString(contentsOf: _modifiedFileURL, usedEncoding: nil)
        
        refresh()
        
        
    }
    
    @objc func refresh() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.fetchEvents(repo: strongSelf._repo)
        }
    }
    
    func fetchEvents(repo: String) {
            
        let topReposUrlString = "https://api.github.com/search/repositories?q=language:swift&per_page=5"
        
        let response = Observable.from([topReposUrlString])
            .map { urlString -> URLRequest in
                let url = URL(string: urlString)!
                var request = URLRequest(url: url)
                return request
            }
            .flatMap { request in
                URLSession.shared.rx.json(request: request)
            }
            .flatMap { response -> Observable<String> in
                guard let response = response as? [String: Any],
                    let items = response["items"] as? [[String: Any]] else {
                        return Observable.empty()
                }
                return Observable.from(items.map { $0["full_name"] as! String })
            }
            .map { [weak self] repo in
                let url = URL(string: "https://api.github.com/repos/\(repo)/events")!
                var request = URLRequest(url: url)
                if let modifiedHeader = self?._lastModified.value {
                    request.addValue(modifiedHeader as String, forHTTPHeaderField: "Last-Modified")
                }
                return request
            }
            .flatMap { request in
                URLSession.shared.rx.response(request: request)
            }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        response.filter { response, _ in
                return 200..<300 ~= response.statusCode
            }
            .map { _, data -> [[String: Any]] in
                guard let responseData = try? JSONSerialization.jsonObject(with: data, options: []),
                    let result = responseData as? [[String: Any]] else {
                        return []
                }
                return result
            }
            .filter { objects in
                    objects.count > 0
            }
            .map { objects in
                    objects.flatMap {
                        return GitFeedEvent(JSON: $0) }
            }
            .subscribe(onNext: { [weak self] newEvents in
                self?._processEvents(newEvents)
            }).disposed(by: _disposeBag)
        
        response
            .filter { response, _ in
            return 200..<400 ~= response.statusCode
            }
            .flatMap { response, _ -> Observable<NSString> in
                guard let value = response.allHeaderFields["Last-Modified"] as? NSString else {
                    return Observable.empty()
                }
                return Observable.just(value)
            }
            .subscribe(onNext: { [weak self] modifiedHeader in
                guard let `self` = self else { return }
                self._lastModified.value = modifiedHeader
                
                try? modifiedHeader.write(to: self._modifiedFileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            })
            .disposed(by: _disposeBag)
    }
    
    private func _processEvents(_ newEvents: [GitFeedEvent]) {
        var updatedEvents = newEvents + _events.value
        if updatedEvents.count > 50 {
            updatedEvents = Array<GitFeedEvent>(updatedEvents.prefix(upTo: 50))
        }
        _events.value = updatedEvents
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        let jsonEvents = updatedEvents.map { $0.toJSON() } as NSArray
        jsonEvents.write(to: _eventsFileURL, atomically: true)
        
        //_lastModified.value = try? NSString(contentsOf: _modifiedFileURL, encoding: nil)
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
        cell.detailTextLabel?.text = event.repo.name + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
        cell.imageView?.kf.setImage(with: event.actor.imageURL, placeholder: UIImage(named: "blank-avatar"))
        return cell
    }

}
