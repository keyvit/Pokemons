//
//  UIImage+resized.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 08.08.2021.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
