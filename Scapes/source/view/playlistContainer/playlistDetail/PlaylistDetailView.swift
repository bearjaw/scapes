//
//  PlaylistDetailView.swift
//  Scapes
//
//  Created by Max Baumbach on 30/05/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

final class PlaylistDetailView: UIView {
    private lazy var thumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        addSubview(imageView)
        return imageView
    }()
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .title
        addSubview(label)
        return label
    }()
    
    private lazy  var statusView: UIView = { return UIView() }()
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutThumbnail()
        layoutTitle()
        layoutStatusView()
    }
    
    private func layoutThumbnail() {
        let dimension = (bounds.height-2*border)*0.4
        let size = CGSize(width: dimension, height: dimension)
        let origin = CGPoint(x: border, y: border)
        thumbnail.frame = CGRect(origin: origin, size: size)
    }
    
    private func layoutTitle() {
        let width = bounds.width - 3*border - thumbnail.bounds.width
        let usableSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let sizeTitle = title.sizeThatFits(usableSize)
        let origin = CGPoint(x: thumbnail.rightBottom.x + border, y: border)
        title.frame = CGRect(origin: origin, size: sizeTitle)
    }
    
    private func layoutStatusView() {
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 150)
    }
    // MARK: - Update
    
    func update(title: String?, thumbnail: UIImage?) {
        self.title.text = title
        self.thumbnail.image = thumbnail
        backgroundColor = .primary
        setNeedsLayout()
    }
}
