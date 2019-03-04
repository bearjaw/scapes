//
//  ViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

class SongLinkViewController: UIViewController {
    
    private lazy var generateView: SongLinkView = {
        let view = SongLinkView()
        return view
    }()
    
    private var viewModel: SongLinkViewModelProtocol
    
    override func loadView() {
        view = generateView
    }
    
    init(viewModel: SongLinkViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePlaylist(playlist: Playlist) {
//        self.playlist = playlist
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.title = playlist?.name
//
//        guard let playlist = playlist else { return }
//        configureTableView()
//
//        self.generateView.updateState(state: .loading)
//        service.provideCachedSongs(for: playlist, content: { [weak self] cache, remainingSongs in
//            self?.items = cache
//            self?.remainingSongs = remainingSongs
//            if remainingSongs.isEmpty {
//                self?.generateView.updateState(state: .hide)
//            } else {
//                self?.generateView.updateState(state: .show)
//            }
//            self?.generateView.tableView.reloadData()
//        })
//        generateView.targetAction = { [weak self] in
//            self?.generateView.updateState(state: .loading)
//            guard let songs = self?.remainingSongs else { return }
//            self?.service.search(in: songs, result: { [weak self] result in
//                self?.items.append(contentsOf: result)
//                if result.count == songs.count {
//                    DispatchQueue.main.async {
//                        self?.generateView.updateState(state: .hide)
//                    }
//                } else {
//                    self?.generateView.updateState(state: .show)
//                }
//                self?.items.sort(by: { $0.index < $1.index })
//                self?.generateView.tableView.reloadData()
//            })
//        }
        addExportButton()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.generateView.setNeedsLayout()
        }, completion: { _ in
            self.generateView.tableView.reloadData()
        })
    }
}

extension SongLinkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "kPlaylistCell") as? TitleDetailTableViewCell
            else { fatalError("Cell initialisation failed") }
        let item = viewModel.items[indexPath.row]
        cell.update(songViewData: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pasteBoard = UIPasteboard.general
        let item = viewModel.items[indexPath.row]
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
//        var exportString = "\(playlist?.name ?? "Playlist") \n"
//        DispatchQueue.global(qos: .userInitiated).async {
//            guard let items = self.viewModel.items else { return }
//            for item in items {
//                if item.url.lowercased().contains("Error".lowercased()) {
//                    exportString.append(contentsOf: "\(item.title) \(item.artist) \n")
//                } else {
//                    exportString.append(contentsOf: "\(item.title) - \(item.artist) \n URL: \(item.url) \n\n")
//                }
//            }
//            DispatchQueue.main.async {
//                let pasteBoard = UIPasteboard.general
//                pasteBoard.string = exportString
//                self?.showAlert(alert: Alert(title: "Done", message: "Copied your playlist to the clipboard"))
//            }
//        }
    }
    
    private func configureTableView() {
        generateView.tableView.delegate = self
        generateView.tableView.dataSource = self
        generateView.tableView.rowHeight = UITableView.automaticDimension
        generateView.tableView.estimatedRowHeight = 60.0
        generateView.tableView.register(TitleDetailTableViewCell.self, forCellReuseIdentifier: "kPlaylistCell")
    }
}

extension SongLinkViewController {
    func showAlert(alert: Alert) {
        let alertController = DarkAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        UIVisualEffectView.appearance(
            whenContainedInInstancesOf: [UIAlertController.classForCoder() as! UIAppearanceContainer.Type]
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
