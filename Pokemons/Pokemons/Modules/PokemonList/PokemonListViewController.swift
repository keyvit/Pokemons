//
//  PokemonListViewController.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit
import TinyConstraints

protocol PokemonListViewType: AnyObject {
    func updateData(_ data: [PokemonList.Section])
}

final class PokemonListViewController: UIViewController {
    var presenter: PokemonListPresenterType!
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<PokemonList.SectionType, PokemonList.Item>
    typealias DataSource = UICollectionViewDiffableDataSource<PokemonList.SectionType, PokemonList.Item>
    private lazy var dataSource = makeDataSource()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeCollectionViewLayout()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        presenter.viewDidLoad()
    }
}

// MARK: - PokemonListViewType

extension PokemonListViewController: PokemonListViewType {
    func updateData(_ data: [PokemonList.Section]) {
        var snapshot = Snapshot()
        data.forEach { section in
            snapshot.appendSections([section.type])
            snapshot.appendItems(section.pokemonPreviews, toSection: section.type)
        }
        dataSource.apply(snapshot)
    }
}

// MARK: - UICollectionViewDelegate

extension PokemonListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let pokemon = dataSource.itemIdentifier(for: indexPath) {        
            // TODO:
        }
    }
}

// MARK: - Collection view configuration

private extension PokemonListViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.register(cellType: PokemonCollectionViewCell.self)
        collectionView.register(
            supplementaryViewType: LabelSectionHeaderView.self,
            ofKind: UICollectionView.elementKindSectionHeader
        )
        
        view.addSubview(collectionView)
        collectionView.edgesToSuperview(excluding: .top)
        collectionView.top(to: view.safeAreaLayoutGuide)
    }
    
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView
        ) { [weak presenter] collectionView, indexPath, pokemonPreview in
            let cell = collectionView.dequeueReusableCell(for: indexPath) as PokemonCollectionViewCell
            cell.configure(with: pokemonPreview)
            cell.delegate = presenter
            
            return cell
        }
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self, kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                for: indexPath,
                viewType: LabelSectionHeaderView.self
            )
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            view.setTitle(section.title)
            
            return view
        }
        
        return dataSource
    }
    
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 12
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1)
        ))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(0.5)
            ),
            subitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = .init(top: 4, leading: spacing, bottom: spacing, trailing: spacing)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(32)
        )
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
