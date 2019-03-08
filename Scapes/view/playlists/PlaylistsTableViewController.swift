//
//  AMusicPlaylistsTableViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 18/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

class PlaylistsTableViewController: UITableViewController {
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        tableView.backgroundColor = AppearanceService.shared.view()
        tableView.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = UIView()
        title = "Select a playlist"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var playlists: [Playlist] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlists = PlaylistProvider.fetchPlaylist()
        tableView.register(TitleDetailTableViewCell.self, forCellReuseIdentifier: "kPlaylistCellIdentifier")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kPlaylistCellIdentifier", for: indexPath)
        let playlist = playlists[indexPath.row]
        cell.textLabel?.text = "\(playlist.name), Items:\(playlist.count)"
        cell.textLabel?.textColor = AppearanceService.shared.textBody()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = self.viewModel.data[indexPath.row]
        let viewModel = SongLinkViewModel(playlist: playlist)
        let songLinkVC = SongLinkViewController(viewModel: viewModel)
        navigationController?.pushViewController(songLinkVC, animated: true)
    }
}
