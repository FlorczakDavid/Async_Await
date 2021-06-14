//
//  ViewController.swift
//  Async_Await
//
//  Created by david florczak on 14/06/2021.
//

import UIKit

struct Post: Codable {
    let title: String
    let body: String
}

class ViewController: UIViewController, UITableViewDataSource {
    
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")
    
    private var posts = [Post]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        
        
        //MARK: - Async call here
        
        async { [weak self] in
            let result = await fetchPosts()
            switch result {
            case.success(let posts):
                self?.posts = posts
                tableView.reloadData()
            case.failure(let error):
                print(error)
            }
        }
    }
    
    enum MyError : Error {
        case failedToGetPosts
    }
    
    //MARK: - Async func Here
    
    private func fetchPosts() async -> Result<[Post], Error> {
        guard let url = url else { return .failure(MyError.failedToGetPosts) }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let posts = try JSONDecoder().decode([Post].self, from: data)
            return .success(posts)
        } catch { return .failure(error) }
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = posts[indexPath.row].title
        cell.detailTextLabel?.text = posts[indexPath.row].body
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

}

