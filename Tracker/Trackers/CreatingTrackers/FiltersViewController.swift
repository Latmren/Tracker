//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 06.11.2026.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(
        _ viewController: FilterViewController,
        didSelect filter: FilterNames
    )
}

enum FilterNames: Int, CaseIterable {
    case all
    case allToday
    case completed
    case incomplete
}


final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: FilterViewControllerDelegate?
    
    private let selectedFilter: FilterState
    
    // MARK: - UI Elements:
    
    private let tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .insetGrouped
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .ypWhite
        return tableView
    }()
    

    
    // MARK: - Initialization
    
    
    init(selectedFilter: FilterState) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        
        title = String(localized: .filterTitle)
        
        view.backgroundColor = .ypWhite
        
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
            ),
        ])
    }
    
}
    // MARK: - UITableViewDataSource, UITableViewDelegate

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        FilterNames.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = UITableViewCell(
            style: .default,
            reuseIdentifier: nil
        )
        guard let filterOption = FilterNames(rawValue: indexPath.row) else {
            assertionFailure("Unknown table row")
            return UITableViewCell()
        }

        switch filterOption {
        case .all:
            cell.textLabel?.text = String(localized: .filterAllTrackers)
            cell.accessoryType = .none
        case .allToday:
            cell.textLabel?.text = String(localized: .filterTodayTrackers)
            cell.accessoryType = .none
        case .completed:
            cell.textLabel?.text = String(localized: .filterCompleted)
            cell.accessoryType = (selectedFilter == .completed) ? .checkmark : .none
            cell.tintColor = .blue
        case .incomplete:
            cell.textLabel?.text = String(localized: .filterIncomplete)
            cell.accessoryType = (selectedFilter == .incomplete) ? .checkmark : .none
            cell.tintColor = .blue
        }

        cell.backgroundColor = .ypBackground

        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        guard let filterOption = FilterNames(rawValue: indexPath.row) else {
            assertionFailure("Unknown table row")
            return
        }
        
        delegate?.filterViewController(self, didSelect: filterOption)
        
        dismiss(animated: true)
    }
}
