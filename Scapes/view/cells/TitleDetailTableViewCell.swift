//
//  TitleDetailTableVIewCell.swift
//  Scapes
//
//  Created by Max Baumbach on 18/12/2018.
//  Copyright © 2018 Max Baumbach. All rights reserved.
//

import UIKit

class TitleDetailTableViewCell: UITableViewCell {
    
    private var labelSongTitle: UILabel = {
        let label = UILabel()
        label.textColor = AppearanceService.shared.textTitle()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        return label
    }()
    
    private var labelArtist: UILabel = {
        let label = UILabel()
        label.textColor = AppearanceService.shared.textSubHeadline()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    private var labelAlbum: UILabel = {
        let label = UILabel()
        label.textColor = AppearanceService.shared.textSubHeadline()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    private var labelLink: UILabel = {
        let label = UILabel()
        label.textColor = AppearanceService.shared.textLink()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 0
        return label
    }()
    
    private let verticalSpace: CGFloat = 10.0
    private let horizontalSpace: CGFloat = 5.0
    private let spaceDivision: CGFloat = 3.0
    private let verticalSpaceMultiplier: CGFloat = 2.0
    private let horizontalSpaceMultiplier: CGFloat = 2.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = AppearanceService.shared.view()
        addSubview(labelSongTitle)
        addSubview(labelArtist)
        addSubview(labelAlbum)
        addSubview(labelLink)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(songViewData: SongLinkViewData) {
        labelSongTitle.text = songViewData.title
        labelArtist.text = "\(songViewData.artist) – "
        labelAlbum.text = songViewData.album
        labelLink.text = songViewData.url
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelSongTitle.text = ""
        labelArtist.text = ""
        labelAlbum.text = ""
        labelLink.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maxSize = (CGSize(width: bounds.width - 4*verticalSpaceMultiplier*verticalSpace,
                              height: (bounds.height/spaceDivision) - 2*verticalSpace))
        let sizeSong = labelSongTitle.sizeThatFits(maxSize)
        let sizeArtist = labelArtist.sizeThatFits(maxSize)
        let sizeAlbum = labelAlbum.sizeThatFits(CGSize(width: maxSize.width - sizeArtist.width, height: maxSize.height))
        let sizeLink = labelLink.sizeThatFits(maxSize)
        
        var originX: CGFloat = 0.0
        var originY: CGFloat = 0.0
        labelSongTitle.frame = (CGRect(x: originX + verticalSpaceMultiplier*verticalSpace,
                                       y: originY + horizontalSpaceMultiplier*horizontalSpace,
                                       width: sizeSong.width,
                                       height: sizeSong.height
        ))
        originY = labelSongTitle.rightBottom().y
        
        labelArtist.frame = (CGRect(x: originX + verticalSpaceMultiplier*verticalSpace,
                                       y: originY + horizontalSpace,
                                       width: sizeArtist.width,
                                       height: sizeArtist.height
        ))
        originX = labelArtist.rightBottom().x
        
        labelAlbum.frame = (CGRect(x: originX,
                                       y: originY + horizontalSpace,
                                       width: sizeAlbum.width,
                                       height: sizeAlbum.height
        ))
        originX = 0.0
        originY = labelAlbum.rightBottom().y
        
        labelLink.frame = (CGRect(x: originX + verticalSpaceMultiplier*verticalSpace,
                                       y: originY + horizontalSpaceMultiplier*horizontalSpace,
                                       width: sizeLink.width,
                                       height: sizeLink.height
        ))
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let maxSize = (CGSize(width: size.width - 4*verticalSpaceMultiplier*verticalSpace,
                              height: (size.height/spaceDivision) - 2*verticalSpace))
        let sizeSong = labelSongTitle.sizeThatFits(maxSize)
        let sizeArtist = labelArtist.sizeThatFits(maxSize)
        let sizeAlbum = labelAlbum.sizeThatFits(CGSize(width: maxSize.width - sizeArtist.width, height: maxSize.height))
        let sizeLink = labelLink.sizeThatFits(maxSize)
        return (CGSize(width: size.width, height:
                        horizontalSpaceMultiplier*verticalSpace
                        + sizeSong.height
                        + horizontalSpace
                        + max(sizeArtist.height, sizeAlbum.height)
                        + horizontalSpaceMultiplier*verticalSpace
                        + sizeLink.height
                        + horizontalSpaceMultiplier*horizontalSpace
        ))
    }
}
