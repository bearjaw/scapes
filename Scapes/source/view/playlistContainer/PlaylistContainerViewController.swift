//
//  PlaylistContainerIViewController.swift
//  Scapes
//
//  Created by Max Baumbach on 10/06/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

enum PlaylistSection: CaseIterable {
    case items
}

final class PlaylistContainerViewController: UIViewController {
    
    private var viewModel: PlaylistContainerViewModelProtocol
    private var detailViewController: UIViewController?
    
    private lazy var containerView: PlaylistContainerView = { PlaylistContainerView() }()
    private var dataSource: UITableViewDiffableDataSource<PlaylistSection, SongLinkIntermediate>?
    
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.containerView.setNeedsLayout()
        }, completion: { _ in
            self.containerView.tableView.reloadData()
        })
    }
    
    // MARK: - View setup
    
    func subscribeToDataChanges() {
        viewModel.subscribe(onInitial: { [weak self] in
            guard let self = self else { return }
            self.containerView.tableView.reloadData()
            self.containerView.updateState(state: .show)
            }, onChange: { [weak self] changes in
                guard let self = self, let dataSource = self.dataSource else { return }
                dataSource.apply(changes)
                DispatchQueue.main.async {
                    self.containerView.updateState(state: .show)
                }
            }, onCompleted: { completed in
                DispatchQueue.main.async {
                    self.containerView.updateState(state: completed ? .hide : .show)
                }
        })
    }
    
    private func configureTableView() {
        containerView.tableView.delegate = self
        containerView.tableView.rowHeight = UITableView.automaticDimension
        containerView.tableView.estimatedRowHeight = 60.0
        containerView.tableView.register(TitleDetailTableViewCell.self, forCellReuseIdentifier: TitleDetailTableViewCell.reuseIdentifier)
        dataSource = UITableViewDiffableDataSource<PlaylistSection, SongLinkIntermediate>(tableView: containerView.tableView, cellProvider: { (tableView, indexPath, item) -> TitleDetailTableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleDetailTableViewCell.reuseIdentifier, for: indexPath) as? TitleDetailTableViewCell else {
                fatalError("Error: Wrong cell dequeued. Expected: \(TitleDetailTableViewCell.self) but got")
            }
            cell.update(songViewData: item)
            return cell
        })
        configureHeader()
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.view.backgroundColor = .primary
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func configureHeader() {
        let playlist = self.viewModel.playlist
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
        var exportString = viewModel.playlist.name
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
