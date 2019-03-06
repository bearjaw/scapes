//
//  ViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

class SongLinkViewController: UIViewController {
    
    private lazy var viewSongLink: SongLinkView = {
        let view = SongLinkView()
        return view
    }()
    
    private var viewModel: SongLinkViewModelProtocol
    
    // MARK: - Lifecycle begin
    
    init(viewModel: SongLinkViewModelProtocol) {
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
        addExportButton()
        subscribeToDataChanges()
    }
    
    // MARK: Lifecycle end
    // MAKR: - setup view
    
    func subscribeToDataChanges() {
        viewModel.subscribe(onInitial: { [weak self] in
            guard let self = self else { return }
            self.viewSongLink.tableView.reloadData()
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
            }, onEmpty: { [weak self] in
                guard let self = self else { return }
                self.viewSongLink.updateState(state: .show)
                
        })
        
        viewModel.subscribe { [weak self] in
            self?.viewSongLink.updateState(state: .hide)
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

extension SongLinkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "kPlaylistCell") as? TitleDetailTableViewCell
            else { fatalError("Cell initialisation failed") }
        let item = viewModel.data[indexPath.row]
        cell.update(songViewData: item)
        return cell
    }
}

extension SongLinkViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pasteBoard = UIPasteboard.general
        let item = viewModel.data[indexPath.row]
        pasteBoard.string = item.url
    }
}

extension SongLinkViewController {
    fileprivate func addExportButton() {
        let bbi = UIBarButtonItem(barButtonSystemItem: .action,
                                  target: self,
                                  action: #selector(SongLinkViewController.exportPlaylist)
        )
        navigationItem.rightBarButtonItem = bbi
    }
    
    @objc func exportPlaylist() {
        var exportString = "\(viewModel.title) \n"
        DispatchQueue.global(qos: .userInitiated).async {
            for item in self.viewModel.data {
                if item.url.lowercased().contains("Error".lowercased()) {
                    exportString.append(contentsOf: "\(item.title) \(item.artist) \n")
                } else {
                    exportString.append(contentsOf: "\(item.title) - \(item.artist) \n URL: \(item.url) \n\n")
                }
            }
            DispatchQueue.main.async {
                let pasteBoard = UIPasteboard.general
                pasteBoard.string = exportString
                self.showAlert(alert: Alert(title: "Done", message: "Copied your playlist to the clipboard"))
            }
        }
    }
    
    private func configureTableView() {
        viewSongLink.tableView.delegate = self
        viewSongLink.tableView.dataSource = self
        viewSongLink.tableView.rowHeight = UITableView.automaticDimension
        viewSongLink.tableView.estimatedRowHeight = 60.0
        viewSongLink.tableView.register(TitleDetailTableViewCell.self, forCellReuseIdentifier: "kPlaylistCell")
    }
}

extension SongLinkViewController {
    func showAlert(alert: Alert) {
        let alertController = DarkAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        guard let coder = UIAlertController.classForCoder() as? UIAppearanceContainer.Type else { return }
        UIVisualEffectView.appearance(
            whenContainedInInstancesOf: [coder]
            ).effect = UIBlurEffect(style: .dark)
        present(alertController, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                alertController.dismiss(animated: true, completion: nil)
            }
        })
    }
}

struct Alert {
    let title: String
    let message: String
}
