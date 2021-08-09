//
//  FavoriteButton.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit

final class FavoriteButton: UIButton {
    var palette: PaletteType = DefaultPalette()
    
    enum Mode {
        case like
        case dislike
    }
    private var mode: Mode = .dislike
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 4
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setBorderColor()
    }
    
    func setMode(_ mode: Mode) {
        let title: String
        let image: UIImage?
        switch mode {
        case .like:
            title = L10n.FavoriteButton.like
            let config = UIImage.SymbolConfiguration(pointSize: 10)
            image = Asset.like(configuration: config).image
        case .dislike:
            title = L10n.FavoriteButton.dislike
            image = nil
        }
        setImage(image, for: .normal)
        setTitle(title.localizedUppercase, for: .normal)
    }
}

// MARK: - Decomposition

private extension FavoriteButton {
    func commonInit() {
        layer.borderWidth = 1
        setBorderColor()
        
        tintColor = .systemBlue
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        imageEdgeInsets.left = 4
        semanticContentAttribute = .forceRightToLeft
        setMode(.dislike)
    }
    
    func setBorderColor() {
        layer.borderColor = palette.outlineColor.cgColor
    }
}
