//
//  AMusicPlaylistsTableViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 18/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

final class PlaylistsTableViewController: UITableViewController {
    
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
        observePlaylists()
        configureNavbar()
    }
    // MARK: Lifecycle end
    // MARK: - View setup
    
    private func configureTableView() {
        tableView.backgroundColor = .secondary
        tableView.tintColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.reuseIdentifier)
    }
    
    private func observePlaylists() {
        viewModel.subscribe(to: { [unowned self] in
            self.tableView.reloadData()
        }, onChange: { [unowned self] deletions, insertions, modifications in
            self.tableView.performBatchUpdates({
                self.tableView.deleteRows(at: deletions, with: .automatic)
                self.tableView.insertRows(at: insertions, with: .automatic)
                self.tableView.reloadRows(at: modifications, with: .automatic)
            }, completion: nil)
        })
    }
}

// MARK: - Table view data source
extension PlaylistsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.reuseIdentifier, for: indexPath) as? PlaylistTableViewCell else {
            fatalError("Error: Wrong cell dequeued for identifier. Expected \(PlaylistTableViewCell.self)")
        }
        let playlist = viewModel.item(at: indexPath)
        cell.update(title: playlist.name, author: "", artwork: playlist.artwork)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = viewModel.item(at: indexPath)
        
        let viewModel = PlaylistContainerViewModel(playlist: playlist, plugins: plugins())
        let container = PlaylistContainerViewController(viewModel: viewModel)
        navigationController?.pushViewController(container, animated: true)
    }
    
    private func plugins() -> [Plugin] {
        let databasePlugin = SongsDatabasePlugin()
        let fetchSongsPlugin = FetchSongsPlugin()
        let exportPlugin = ExportPlaylistPlugin()
        let downloadPlugin = DownloadSongPlugin(database: databasePlugin)
        let plugins: [Plugin] = [fetchSongsPlugin, databasePlugin, downloadPlugin, exportPlugin]
        return plugins
    }
}
