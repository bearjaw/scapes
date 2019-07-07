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
    }
    // MARK: Lifecycle end
    // MARK: - View setup
    
    private func configureTableView() {
        tableView.backgroundColor = AppearanceService.shared.view()
        tableView.tintColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(TitleDetailTableViewCell.self, forCellReuseIdentifier: TitleDetailTableViewCell.reusueIdentifier)
    }
    
    private func observePlaylists() {
        viewModel.subscribe(to: { [unowned self] in
            self.tableView.reloadData()
        }, onChange: { [unowned self] deletions, insertions, modifications in
            self.tableView.performBatchUpdates({
                self.tableView.deleteRows(at: deletions, with: .automatic)
                self.tableView.insertRows(at: insertions, with: .automatic)
                self.tableView.reloadRows(at: modifications, with: .none)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TitleDetailTableViewCell.reusueIdentifier, for: indexPath)
        let playlist = viewModel.item(at: indexPath)
        cell.textLabel?.text = "\(playlist.name), Items:\(playlist.count)"
        cell.textLabel?.textColor = AppearanceService.shared.textBody()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlist = viewModel.item(at: indexPath)
        let viewModel = PlaylistContainerViewModel(playlist: playlist)
        let container = PlaylistContainerViewController(viewModel: viewModel)
        navigationController?.pushViewController(container, animated: true)
    }
}
