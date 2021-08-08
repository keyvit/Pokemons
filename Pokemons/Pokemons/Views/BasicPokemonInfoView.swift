//
//  BasicPokemonInfoView.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 29.07.2021.
//

import UIKit
import Kingfisher

private struct Constants {
    let imageSizeDimension: CGFloat = 120
    let placeholder = AppConstants.imagePlaceholder.resized(to: CGSize(width: 50, height: 50))
}
private let consts = Constants()

// MARK: - BasicPokemonInfoView

final class BasicPokemonInfoView: UIView {
    private lazy var imagesContainerView = UIView()
    private lazy var frontImageView = UIImageView()
    private lazy var backImageView = UIImageView()
    
    private lazy var keyValueStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configure(with model: BasicPokemonInfo) {
        let imageProcessor = ResizingImageProcessor(
            referenceSize: CGSize(width: consts.imageSizeDimension, height: consts.imageSizeDimension),
            mode: .aspectFit
        )
        
        frontImageView.kf.setImage(
            with: model.frontImage,
            placeholder: consts.placeholder,
            options: [.processor(imageProcessor)]
        )
        backImageView.kf.setImage(
            with: model.backImage,
            placeholder: consts.placeholder,
            options: [.processor(imageProcessor)]
        )
        
        if keyValueStackView.arrangedSubviews.count > 1 {
            keyValueStackView.arrangedSubviews
                .dropFirst()
                .forEach {
                    keyValueStackView.removeArrangedSubview($0)
                    $0.removeFromSuperview()
                }
        }
        
        for char in model.characteristics {
            let view = KeyValueView()
            view.configure(key: char.characteristic, value: char.value)
            keyValueStackView.addArrangedSubview(view)
        }
    }
}

// MARK: Setup

private extension BasicPokemonInfoView {
    func setupView() {
        preservesSuperviewLayoutMargins = true
        
        imagesContainerView.addSubview(frontImageView)
        imagesContainerView.addSubview(backImageView)
        
        for imageView in [frontImageView, backImageView] {
            imageView.centerYToSuperview()
            imageView.height(consts.imageSizeDimension)
            imageView.aspectRatio(1)
            imageView.contentMode = .center
        }
        frontImageView.heightToSuperview(multiplier: 0.85, priority: .defaultHigh)
        frontImageView.centerXToSuperview(multiplier: 0.5)
        backImageView.centerXToSuperview(multiplier: 1.5)
        
        addSubview(imagesContainerView)
        imagesContainerView.edgesToSuperview(excluding: .bottom)
        
        addSubview(keyValueStackView)
        keyValueStackView.leading(to: self.layoutMarginsGuide)
        keyValueStackView.trailing(to: self.layoutMarginsGuide)
        keyValueStackView.topToBottom(of: imagesContainerView)
        keyValueStackView.bottomToSuperview(offset: -keyValueStackView.spacing)
    }
}

// MARK: - KeyValueView

private final class KeyValueView: UIView {
    private lazy var keyLabel = UILabel()
    private lazy var valueLabel = UILabel()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 16
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configure(key: String, value: String) {
        keyLabel.text = key
        valueLabel.text = value
    }
}

// MARK: Setup

private extension KeyValueView {
    func setupView() {
        addSubview(stackView)
        stackView.edgesToSuperview()
        
        stackView.addArrangedSubview(keyLabel)
        stackView.addArrangedSubview(valueLabel)
        keyLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
    }
}
