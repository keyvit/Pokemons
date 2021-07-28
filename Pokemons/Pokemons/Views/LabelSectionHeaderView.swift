//
//  LabelSectionHeaderView.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 28.07.2021.
//

import UIKit
import Reusable
import TinyConstraints

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
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

// MARK: - Initial Config

private extension LabelSectionHeaderView {
    func commonInit() {
        addSubview(titleLabel)
        titleLabel.edgesToSuperview(excluding: .trailing)
        titleLabel.trailingToSuperview(relation: .equalOrLess)
    }
}
