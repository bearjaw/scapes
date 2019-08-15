//
//  PlaylistContainerIViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 10/06/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

final class PlaylistContainerViewController: UIViewController {
    
    private var viewModel: PlaylistContainerViewModelProtocol
    private var detailViewController: UIViewController?
    
    private lazy var containerView: PlaylistContainerView = { PlaylistContainerView() }()
    
    init(viewModel: PlaylistContainerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = containerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addExportButton()
        configureTableView()
        subscribeToDataChanges()
        containerView.targetAction = { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchRemainingSongsIfNeeded()
            self.containerView.updateState(state: .loading)
        }
    }
    
    // MARK: - View setup
    
    func subscribeToDataChanges() {
        viewModel.subscribe(onInitial: { [weak self] in
            guard let self = self else { return }
            self.containerView.tableView.reloadData()
            self.containerView.updateState(state: .show)
            }, onChange: { [weak tableView = self.containerView.tableView] changes in
                guard let tableView = tableView else { return }
                let (deletions, insertions, modifications) = changes
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: deletions, with: .automatic)
                    tableView.insertRows(at: insertions, with: .automatic)
                    tableView.reloadRows(at: modifications, with: .automatic)
                }, completion: nil)
                self.containerView.updateState(state: .show)
            }, onEmpty: {
                self.containerView.updateState(state: .show)
        })
        
        viewModel.subscribe { [unowned self] in
            self.containerView.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.containerView.updateState(state: .hide)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.containerView.setNeedsLayout()
        }, completion: { _ in
            self.containerView.tableView.reloadData()
        })
    }
    
    private func configureTableView() {
        containerView.tableView.delegate = self
        containerView.tableView.dataSource = self
        containerView.tableView.rowHeight = UITableView.automaticDimension
        containerView.tableView.estimatedRowHeight = 60.0
        containerView.tableView.register(TitleDetailTableViewCell.self, forCellReuseIdentifier: "kPlaylistCell")
        configureHeader()
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.view.backgroundColor = .primary
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func configureHeader() {
        guard let playlist = self.viewModel.playlist.value else { return }
        let viewModel = PlaylistDetailViewModel(playlist: playlist)
        let detail = PlaylistDetailViewController(viewModel: viewModel)
        let size = CGSize(width: view.bounds.width, height: 150)
        detail.view.frame = CGRect(origin: .zero, size: size)
        containerView.tableView.tableHeaderView = detail.view
        detailViewController = detail
    }
    
    private func addExportButton() {
        let bbi = UIBarButtonItem(barButtonSystemItem: .action,
                                  target: self,
                                  action: #selector(PlaylistContainerViewController.exportPlaylist)
        )
        navigationItem.rightBarButtonItem = bbi
    }
}

extension PlaylistContainerViewController: UITableViewDataSource {
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

extension PlaylistContainerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        let pasteBoard = UIPasteboard.general
        let item = viewModel.data[indexPath.row]
        pasteBoard.string = item.url
    }
}

extension PlaylistContainerViewController {
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
    
    @objc func exportPlaylist() {
        var exportString = "\(viewModel.playlist.value?.name ?? "Unknown Playlist") \n"
        DispatchQueue.global(qos: .userInitiated).async {
            for item in self.viewModel.data {
                if item.url.lowercased().isEmpty {
                    exportString.append(contentsOf: "\(item.title) \(item.artist) \n Couldn't find that song.")
                } else {
                    exportString.append(contentsOf: "\(item.title) - \(item.artist) \n URL: \(item.url) \n\n")
                }
            }
            DispatchQueue.main.async {
                let pasteBoard = UIPasteboard.general
                pasteBoard.string = exportString
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                self.showAlert(alert: Alert(title: "Done", message: "Copied your playlist to the clipboard"))
            }
        }
    }
}
