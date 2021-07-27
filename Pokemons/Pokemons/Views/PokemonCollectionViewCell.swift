//
//  PokemonCollectionViewCell.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit
import Reusable
import TinyConstraints
import Kingfisher

private struct Constants {
    let placeholder = Asset.pokeball.image
}
private let consts = Constants()

protocol PokemonCollectionViewCellDelegate: AnyObject {
    func pokemonCollectionViewCell(withId id: Int, didTapFavorite isFavorite: Bool)
}

final class PokemonCollectionViewCell: UICollectionViewCell, Reusable {
    weak var delegate: PokemonCollectionViewCellDelegate?
    
    typealias ViewModel = PokemonPreview
    private var viewModel: ViewModel?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        
        return stackView
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.contentMode = .bottom
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    private lazy var favoriteButton: FavoriteButton = {
        let button = FavoriteButton(type: .system)
        button.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func configure(with viewModel: ViewModel) {
        self.viewModel = viewModel
        
        iconImageView.kf.setImage(with: viewModel.image, placeholder: consts.placeholder)
        nameLabel.text = viewModel.name
        favoriteButton.setMode(viewModel.isFavorite ? .dislike : .like)
    }
}

// MARK: - Decomposition

private extension PokemonCollectionViewCell {
    func commonInit() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        
        let addStretchableView = {
            let stretchableView = UIView()
            stretchableView.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
            self.stackView.addArrangedSubview(stretchableView)
        }
        
        contentView.addSubview(stackView)
        addStretchableView()
        stackView.addArrangedSubview(iconImageView)
        addStretchableView()
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(favoriteButton)
        
        stackView.heightToSuperview(multiplier: 0.9)
        stackView.widthToSuperview(multiplier: 0.85)
        stackView.centerInSuperview()
        iconImageView.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        iconImageView.centerYToSuperview(multiplier: 0.5)
        iconImageView.height(to: contentView, multiplier: 0.4, relation: .equalOrLess)
    }
    
    @objc func didTapFavorite() {
        guard let viewModel = viewModel else { return }
        delegate?.pokemonCollectionViewCell(withId: viewModel.id, didTapFavorite: !viewModel.isFavorite)
    }
}
