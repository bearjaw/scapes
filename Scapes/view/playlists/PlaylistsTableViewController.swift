//
//  AMusicPlaylistsTableViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 18/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

class PlaylistsTableViewController: UITableViewController {
    
    private var viewModel: PlaylistViewModelProtocol
    
    // MARK: - Lifecycle begin
    
    init(viewModel: PlaylistViewModelProtocol) {
        self.viewModel = viewModel
        super.init(style: .plain)
        tableView.backgroundColor = AppearanceService.shared.view()
        tableView.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = UIView()
        title = "Select a playlist"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TitleDetailTableViewCell.self, forCellReuseIdentifier: "kPlaylistCellIdentifier")
    }
    // MARK: Lifecycle end
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kPlaylistCellIdentifier", for: indexPath)
        let playlist = viewModel.data[indexPath.row]
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
