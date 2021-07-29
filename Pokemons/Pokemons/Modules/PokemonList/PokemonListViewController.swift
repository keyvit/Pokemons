//
//  PokemonListViewController.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit
import TinyConstraints

protocol PokemonListViewType: AnyObject {
    func setPullToRefreshEnabled(_ isEnabled: Bool)
    func stopRefreshControlIfAny()
    
    func updateData(_ data: [PokemonList.Section])
    func appendItems(items: [PokemonList.Item], to section: PokemonList.SectionType)
    
    func setActivityIndicatorAnimating(_ isAnimating: Bool)
    func hidePagingActivityIndicator()
}

final class PokemonListViewController: UIViewController {
    var presenter: PokemonListPresenterType!
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeCollectionViewLayout()
    )
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .systemGray
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }()
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<PokemonList.SectionType, PokemonList.Item>
    typealias DataSource = UICollectionViewDiffableDataSource<PokemonList.SectionType, PokemonList.Item>
    private lazy var dataSource = makeDataSource()
    private var activityIndicatorSectionFooterView: UIView?
    private var isPaginationActivityIndicatorVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        presenter.viewDidLoad()
    }
}

// MARK: - PokemonListViewType

extension PokemonListViewController: PokemonListViewType {
    func setPullToRefreshEnabled(_ isEnabled: Bool) {
        if isEnabled {
            guard collectionView.refreshControl == nil else { return }
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.refreshControl = nil
        }
    }
    
    func stopRefreshControlIfAny() {
        collectionView.refreshControl?.endRefreshing()
    }
    
    func updateData(_ data: [PokemonList.Section]) {
        var snapshot = Snapshot()
        data.forEach { section in
            snapshot.appendSections([section.type])
            snapshot.appendItems(section.pokemonPreviews, toSection: section.type)
        }
        dataSource.apply(snapshot)
    }
    
    func appendItems(items: [PokemonList.Item], to section: PokemonList.SectionType) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(items, toSection: section)
        dataSource.apply(snapshot)
    }
    
    func setActivityIndicatorAnimating(_ isAnimating: Bool) {
        if isAnimating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func hidePagingActivityIndicator() {
        let activityIndicator = collectionView.visibleSupplementaryViews(
            ofKind: UICollectionView.elementKindSectionFooter
        ).first(where: { $0 is ActivityIndicatorSectionFooterView })
        if let view = activityIndicator,
           collectionView.contentOffset.y + collectionView.frame.height > view.frame.origin.y
        {
            let snapshot = dataSource.snapshot()
            collectionView.scrollToItem(
                at: IndexPath(
                    item: snapshot.sectionIdentifiers.last.map { snapshot.numberOfItems(inSection: $0) - 1 } ?? 0,
                    section: snapshot.numberOfSections - 1
                ),
                at: .bottom,
                animated: true
            )
        }
    }
}

// MARK: - UICollectionViewDelegate

extension PokemonListViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let view = activityIndicatorSectionFooterView else { return }
        
        let isActivityIndicatorVisible = collectionView.contentOffset.y + collectionView.frame.height >
            view.frame.origin.y
        if self.isPaginationActivityIndicatorVisible != isActivityIndicatorVisible {
            self.isPaginationActivityIndicatorVisible = isActivityIndicatorVisible
            if isActivityIndicatorVisible {
                presenter.didShowPaginationActivityIndicator()
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard elementKind == UICollectionView.elementKindSectionFooter else { return }

        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        if case let .all(areMorePokemonsAvailable) = section, areMorePokemonsAvailable {
            activityIndicatorSectionFooterView = view
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        forElementOfKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard elementKind == UICollectionView.elementKindSectionFooter else { return }

        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        if case let .all(areMorePokemonsAvailable) = section, areMorePokemonsAvailable {
            activityIndicatorSectionFooterView = nil
            isPaginationActivityIndicatorVisible = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let pokemon = dataSource.itemIdentifier(for: indexPath) {        
            presenter.didTapPokemon(with: pokemon)
        }
    }
}

// MARK: - Collection View Configuration

private extension PokemonListViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        configureCollectionView()
        
        view.addSubview(activityIndicator)
        activityIndicator.centerInSuperview()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        collectionView.register(cellType: PokemonCollectionViewCell.self)
        collectionView.register(
            supplementaryViewType: LabelSectionHeaderView.self,
            ofKind: UICollectionView.elementKindSectionHeader
        )
        collectionView.register(
            supplementaryViewType: EmptySupplementaryView.self,
            ofKind: UICollectionView.elementKindSectionFooter
        )
        collectionView.register(
            supplementaryViewType: ActivityIndicatorSectionFooterView.self,
            ofKind: UICollectionView.elementKindSectionFooter
        )
        
        view.addSubview(collectionView)
        collectionView.leadingToSuperview()
        collectionView.trailingToSuperview()
        collectionView.top(to: view.safeAreaLayoutGuide)
        collectionView.bottom(to: view.safeAreaLayoutGuide)
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
            guard let self = self else { return nil }
            
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    for: indexPath,
                    viewType: LabelSectionHeaderView.self
                )
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                view.setTitle(section.title)
                
                return view
            case UICollectionView.elementKindSectionFooter:
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                if case let .all(areMorePokemonsAvailable) = section, areMorePokemonsAvailable {
                    return collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        for: indexPath,
                        viewType: ActivityIndicatorSectionFooterView.self
                    )
                } else {
                    return collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        for: indexPath,
                        viewType: EmptySupplementaryView.self
                    )
                }
            default:
                return nil
            }
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
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(10)
        )
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            ),
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
        ]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - User Actions

private extension PokemonListViewController {
    @objc func didPullToRefresh() {
        presenter.didPullToRefresh()
    }
}
