//
//  PlaylistContainerView.swift
//  Scapes
//
//  Created by Max Baumbach on 10/06/2019.
//  Copyright © 2019 Max Baumbach. All rights reserved.
//

import UIKit

final class PlaylistContainerView: UIView {
    private var detailView: UIView?
    private var listView: UIView?
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutDetail()
        layoutList()
    }
    
    private func layoutDetail() {
        guard let detailView = detailView else { return }
        let usableSize = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        let size = detailView.sizeThatFits(usableSize)
        let origin: CGPoint = .zero
        detailView.frame = CGRect(origin: origin, size: size)
    }
    
    private func layoutList() {
        guard let listView = listView,
        let detailView = detailView else { return }
        let usableHeight = bounds.height - safeAreaInsets.top - detailView.bounds.height
        let origin = CGPoint(x: 0, y: detailView.rightBottom.y)
        let size = CGSize(width: bounds.width, height: usableHeight)
        listView.frame = CGRect(origin: origin, size: size)
    }
    
    // MARK: - Update
    
    func addDetailView(_ view: UIView) {
        detailView?.removeFromSuperview()
        addSubview(view)
        detailView = view
        setNeedsLayout()
    }
    
    func addListView(_ view: UIView) {
        listView?.removeFromSuperview()
        addSubview(view)
        listView = view
        setNeedsLayout()
    }

}
