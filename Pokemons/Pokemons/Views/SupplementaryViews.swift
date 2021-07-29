//
//  SupplementaryViews.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import UIKit
import Reusable
import TinyConstraints

final class EmptySupplementaryView: UICollectionReusableView, Reusable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        height(0, priority: LayoutPriority(999))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ActivityIndicatorSectionFooterView: UICollectionReusableView, Reusable {
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(activityIndicator)
        activityIndicator.centerInSuperview()
        activityIndicator.topToSuperview(offset: 8)
        activityIndicator.bottomToSuperview(offset: -8)
        
        activityIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class LabelSectionHeaderView: UICollectionReusableView, Reusable {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize,
            weight: .bold
        )
        label.textAlignment = .left
        label.numberOfLines = 1
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.edgesToSuperview(excluding: .trailing)
        titleLabel.trailingToSuperview(relation: .equalOrLess)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
