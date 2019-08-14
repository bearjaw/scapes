//
//  PlaylistContainerView.swift
//  Scapes
//
//  Created by Max Baumbach on 10/06/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

enum GetButtonState {
    case loading
    case hide
    case show
}

final class PlaylistContainerView: UIView {
    var targetAction: () -> Void = {}
    
    private(set) var tableView = UITableView(frame: .zero, style: .plain)
    private var state: GetButtonState = .show
    
    private var buttonGet = UIButton()
    private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .text
        return spinner
    }()
    
    private let buttonText = "Get Song Links"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondary
        tableView.backgroundColor = .primary
        tableView.tintColor = .text
        tableView.tableFooterView = UIView()
        addSubview(tableView)
        
        buttonGet.setTitle(buttonText, for: .normal)
        buttonGet.backgroundColor = .button
        buttonGet.titleLabel?.textColor = .text
        buttonGet.layer.cornerRadius = 8
        buttonGet.alpha = 0.0
        buttonGet.addTarget(self, action: #selector(fetchPlaylist), for: .touchUpInside)
        addSubview(buttonGet)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let horizontalSpace: CGFloat = 10.0
        let verticalSpace: CGFloat = 10.0
        let buttonHeight = 50.0
        let yButton = Double(bounds.size.height-2*verticalSpace-safeAreaInsets.bottom)-buttonHeight
        let xButton = Double(2*horizontalSpace)
        switch state {
        case .hide:
            let horizontalSpace: CGFloat = 10.0
            let newHeight = self.bounds.size.height - self.safeAreaInsets.bottom - horizontalSpace
            self.tableView.frame = (CGRect(x: 0.0, y: 0.0, width: self.bounds.size.width, height: newHeight))
        case .show, .loading:
            let verticalSpace: CGFloat = 10.0
            let buttonHeight: CGFloat = 50.0
            let yButton: CGFloat = self.bounds.size.height-2*verticalSpace-self.safeAreaInsets.bottom-buttonHeight
            self.tableView.frame = (CGRect(x: 0.0,
                                           y: 0.0,
                                           width: self.bounds.size.width,
                                           height: yButton - 2*verticalSpace
            ))
        }
        
        buttonGet.frame = CGRect(x: xButton,
                                 y: yButton,
                                 width: Double(bounds.size.width - 4*horizontalSpace),
                                 height: buttonHeight)
    }
    
    // MARK: - Update
    
    func updateState(state: GetButtonState) {
        self.state = state
        switch state {
        case .loading:
            buttonGet.addSubview(spinner)
            buttonGet.setTitle("", for: .normal)
            let xSpinner: CGFloat = (buttonGet.bounds.size.width - spinner.bounds.size.width)/2
            let ySpinner: CGFloat = (buttonGet.bounds.size.height - spinner.bounds.size.height)/2
            spinner.frame = (CGRect(x: xSpinner,
                                    y: ySpinner,
                                    width: spinner.bounds.width,
                                    height: spinner.bounds.height)
            )
            spinner.startAnimating()
        case .hide:
            UIView.animate(withDuration: 0.2) {
                self.buttonGet.alpha = 0.0
                self.spinner.stopAnimating()
                self.spinner.removeFromSuperview()
                self.buttonGet.setTitle(self.buttonText, for: .normal)
                let horizontalSpace: CGFloat = 10.0
                let newHeight = self.bounds.size.height - self.safeAreaInsets.bottom - horizontalSpace
                self.tableView.frame = (CGRect(x: 0.0, y: 0.0, width: self.bounds.size.width, height: newHeight))
            }
        case .show:
            UIView.animate(withDuration: 0.2) {
                self.buttonGet.alpha = 1.0
                self.spinner.stopAnimating()
                self.spinner.removeFromSuperview()
                self.buttonGet.setTitle(self.buttonText, for: .normal)
                let verticalSpace: CGFloat = 10.0
                let buttonHeight: CGFloat = 50.0
                let yButton: CGFloat = self.bounds.size.height-2*verticalSpace-self.safeAreaInsets.bottom-buttonHeight
                self.tableView.frame = (CGRect(x: 0.0,
                                               y: 0.0,
                                               width: self.bounds.size.width,
                                               height: yButton - 2*verticalSpace
                ))
            }
        }
    }
    
    // MARK: - Action
    @objc func fetchPlaylist() {
        targetAction()
    }
}
