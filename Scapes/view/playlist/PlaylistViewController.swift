//
//  ViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

final class PlaylistViewController: UIViewController {
    
    private lazy var viewSongLink: SongLinkView = {
        let view = SongLinkView()
        return view
    }()
    
    private var viewModel: PlaylistViewModelProtocol
    
    // MARK: - Lifecycle begin
    
    init(viewModel: PlaylistViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = viewSongLink
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        viewSongLink.targetAction = { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchRemainingSongsIfNeeded()
            self.viewSongLink.updateState(state: .loading)
        }
//        addExportButton()
        subscribeToDataChanges()
        title = viewModel.title
    }
    
    // MARK: Lifecycle end
    // MAKR: - setup view
    
    func subscribeToDataChanges() {
        
        viewModel.subscribe(onInitial: { [weak self] in
            guard let self = self else { return }
            self.viewSongLink.tableView.reloadData()
            self.viewSongLink.updateState(state: .show)
            }, onChange: { [weak tableView = self.viewSongLink.tableView] changes in
                guard let tableView = tableView else { return }
                let (deletions, insertions, modifications) = changes
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
                self.viewSongLink.updateState(state: .show)
            }, onEmpty: { [weak self] in
                guard let self = self else { return }
                self.viewSongLink.updateState(state: .show)
        })
        
        viewModel.subscribe { [unowned self] in
            self.viewSongLink.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.viewSongLink.updateState(state: .hide)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.viewSongLink.setNeedsLayout()
        }, completion: { _ in
            self.viewSongLink.tableView.reloadData()
        })
    }
}

extension PlaylistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "kPlaylistCell") as? TitleDetailTableViewCell
            else { fatalError("Cell initialisation failed") }
        let item = viewModel.data[indexPath.row]
        let viewData =  SongLinkViewData(url: item.url,
                                         success: item.notFound,
                                         title: item.title,
                                         artist: item.artist,
                                         album: item.album,
                                         index: item.index)
        cell.update(songViewData: viewData)
        return cell
    }
}

extension PlaylistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        let pasteBoard = UIPasteboard.general
        let item = viewModel.data[indexPath.row]
        pasteBoard.string = item.url
    }
}

extension PlaylistViewController {
    
    private func configureTableView() {
        viewSongLink.tableView.delegate = self
        viewSongLink.tableView.dataSource = self
        viewSongLink.tableView.rowHeight = UITableView.automaticDimension
        viewSongLink.tableView.estimatedRowHeight = 60.0
        viewSongLink.tableView.register(TitleDetailTableViewCell.self, forCellReuseIdentifier: "kPlaylistCell")
    }
}

struct Alert {
    let title: String
    let message: String
}
