//
//  PlaylistTableViewCell.swift
//  Scapes
//
//  Created by Max Baumbach on 17/08/2019.
//  Copyright © 2019 Scapes. All rights reserved.
//

import UIKit

final class PlaylistTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "com.scapes.playlist.cell"
    
    private lazy var labelAuthor: UILabel = {
        let label = UILabel()
        label.textColor = .systemFill
        label.accessibilityLabel = "Author"
        contentView.addSubview(label)
        return label
    }()
    
    private lazy var labelTitle: UILabel = {
        let label = UILabel()
        label.textColor = .systemFill
        label.accessibilityLabel = "Playlist name"
        contentView.addSubview(label)
        return label
    }()
    
    private lazy var artwork: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .primary
        imageView.accessibilityLabel = "Playlist artwork"
        contentView.addSubview(imageView)
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        applyStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyle()
    }
    
    private func applyStyle() {
        backgroundColor = .secondary
        contentView.backgroundColor = .secondary
        accessoryType = .disclosureIndicator
    }
    
    // MARK: - Update
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelAuthor.text = nil
        labelTitle.text = nil
        artwork.image = nil
    }
    
    func update(title: String, author: String, artwork: Data?) {
        labelAuthor.text = author
        labelAuthor.accessibilityValue = author
        labelTitle.text = title
        labelTitle.accessibilityValue = title
        guard let data = artwork else { setNeedsLayout(); return }
        self.artwork.image = UIImage(data: data)
        setNeedsLayout()
    }
    
    // MARK: - Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeImage = artwork.image?.size ?? CGSize(width: 150, height: 150)
        return CGSize(width: size.width, height: sizeImage.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutArtwork()
        layoutLabels()
    }
    
    private func layoutArtwork() {
        let dimension = contentView.bounds.height - 2*border
        let sizeDefault = CGSize(width: dimension, height: dimension)
        let sizeImage = artwork.image?.size ?? sizeDefault
        let origin = CGPoint(x: border, y: border)
        artwork.frame = CGRect(origin: origin, size: sizeImage)
    }
    
    private func layoutLabels() {
        let width = contentView.bounds.width - 2*border
        let availableWidth = width - artwork.rightBottom.x + border
        let sizeAvailable = CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
        let sizeTitle = labelTitle.sizeThatFits(sizeAvailable)
        
        let sizeAuthor: CGSize
        if labelAuthor.text?.isEmpty == true {
            sizeAuthor = .zero
        } else {
            sizeAuthor = labelAuthor.sizeThatFits(sizeAvailable)
        }
        
        let combinedHeight = sizeTitle.height + sizeAuthor.height
        let originTitle = CGPoint(x: artwork.rightBottom.x + border, y: (contentView.bounds.height - combinedHeight)/2)
        labelTitle.frame = CGRect(origin: originTitle, size: sizeTitle)
        
        let originAuthor = CGPoint(x: labelTitle.frame.origin.x, y: labelTitle.rightBottom.y + border/2)
        labelAuthor.frame = CGRect(origin: originAuthor, size: sizeAuthor)
    }
    

}
