//
//  GenerateView.swift
//  Scapes
//
//  Created by Max Baumbach on 27/11/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

class SongLinkView: UIView {
    
    var targetAction: () -> Void = {}
    
    var tableView = UITableView(frame: .zero, style: .plain)
    private var state: GetButtonState = .show
    
    private var buttonGet = UIButton()
    private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.color = AppearanceService.shared.textButton()
       return spinner
    }()
    
    private let buttonText = "Get Song Links"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppearanceService.shared.view()
        tableView.backgroundColor = AppearanceService.shared.view()
        tableView.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = UIView()
        addSubview(tableView)
        
        buttonGet.setTitle(buttonText, for: .normal)
        buttonGet.backgroundColor = AppearanceService.shared.button()
        buttonGet.titleLabel?.textColor = AppearanceService.shared.textButton()
        buttonGet.layer.cornerRadius = 8
        buttonGet.alpha = 0.0
        buttonGet.addTarget(self, action: #selector(fetchPlaylist), for: .touchUpInside)
        addSubview(buttonGet)
    }
    
    @objc func fetchPlaylist() {
        targetAction()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
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
}

enum GetButtonState {
    case loading
    case hide
    case show
}
