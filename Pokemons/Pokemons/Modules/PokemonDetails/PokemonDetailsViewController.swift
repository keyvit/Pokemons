//
//  PokemonDetailsViewController.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 27.07.2021.
//

import UIKit
import TinyConstraints

private struct Constants {
    let reusableCellID = "UITableViewCell"
}
private let consts = Constants()

protocol PokemonDetailsViewType: AnyObject {
    func configure(basicInfo: BasicPokemonInfo, sections: [PokemonDetails.Section])
}

final class PokemonDetailsViewController: UIViewController {
    var presenter: PokemonDetailsPresenterType!
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<PokemonDetails.SectionType, PokemonDetails.Item>
    private lazy var dataSource = makeDataSource()
    private lazy var tableView = UITableView()
    private lazy var basicInfoView = BasicPokemonInfoView(
        frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 500))
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = basicInfoView.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        if basicInfoView.frame.size.height != size.height || tableView.tableHeaderView == nil {
            basicInfoView.frame.size.height = size.height
            tableView.tableHeaderView = basicInfoView
        }
    }
}

// MARK: PokemonDetailsViewType

extension PokemonDetailsViewController: PokemonDetailsViewType {
    func configure(basicInfo: BasicPokemonInfo, sections: [PokemonDetails.Section]) {
        basicInfoView.configure(with: basicInfo)
        
        var snapshot = Snapshot()
        sections.forEach { section in
            snapshot.appendSections([section.type])
            snapshot.appendItems(section.items, toSection: section.type)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: View Configuration

private extension PokemonDetailsViewController {
    func configureView() {
        view.backgroundColor = .white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: consts.reusableCellID)
        tableView.dataSource = dataSource
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.allowsSelection = false
        
        view.addSubview(tableView)
        tableView.edges(to: view.safeAreaLayoutGuide)
    }
    
    func makeDataSource() -> PokemonDetailsTableViewDataSource {
        PokemonDetailsTableViewDataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: consts.reusableCellID, for: indexPath)
            cell.textLabel?.text = item
            
            return cell
        }
    }
}

// MARK: - PokemonDetailsTableViewDataSource

private final class PokemonDetailsTableViewDataSource:
    UITableViewDiffableDataSource<PokemonDetails.SectionType, PokemonDetails.Item> {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        snapshot().sectionIdentifiers[section].title
    }
}
