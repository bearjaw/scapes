//
//  AMusicPlaylistsTableViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 18/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

class PlaylistsTableViewController: UITableViewController {
    
    private var viewModel: PlaylistsViewModelProtocol
    
    // MARK: - Lifecycle begin
    
    init(viewModel: PlaylistsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(style: .plain)
        title = "Select a playlist"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    // MARK: Lifecycle end
    // MARK: - View setup
    
    private func configureTableView() {
        tableView.backgroundColor = AppearanceService.shared.view()
        tableView.tintColor = .white
        tableView.tableFooterView = UIView()
        tableView.register(TitleDetailTableViewCell.self, forCellReuseIdentifier: TitleDetailTableViewCell.reusueIdentifier)
    }
}

// MARK: - Table view data source
extension PlaylistsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TitleDetailTableViewCell.reusueIdentifier, for: indexPath)
        let playlist = viewModel.data[indexPath.row]
        cell.textLabel?.text = "\(playlist.name), Items:\(playlist.count)"
        cell.textLabel?.textColor = AppearanceService.shared.textBody()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = self.viewModel.data[indexPath.row]
        let viewModel = PlaylistViewModel(playlist: playlist)
        let songLinkVC = PlaylistViewController(viewModel: viewModel)
        navigationController?.pushViewController(songLinkVC, animated: true)
    }
}
