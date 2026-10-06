//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 03.10.2026.
//

import UIKit

final class CategoryViewController: UIViewController {
    //MARK: - Properties

    private let viewModel: TrackerCategoryViewModel

    var onCategorySelected: ((String) -> Void)?

    //MARK: - UI Elements
    
    private let emptyStateView = EmptyStateView(
        image: UIImage(resource: .emptyTrackers),
        text: "Привычки и события можно\nобъединить по смыслу"
    )

    private let tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .insetGrouped
        )

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .ypWhite
        tableView.rowHeight = 75
        return tableView
    }()

    private let addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlackDay
        button.titleLabel?.font = .systemFont(
            ofSize: 16,
            weight: .medium
        )
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization

    init(viewModel: TrackerCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTableView()
        setupActions()
        bindViewModel()

        updateState()
    }

    // MARK: - Setup

    private func setupView() {
        title = "Категория"
        view.backgroundColor = .ypWhite

        navigationItem.hidesBackButton = true

        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(addCategoryButton)

        NSLayoutConstraint.activate([
            addCategoryButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            addCategoryButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            addCategoryButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            addCategoryButton.heightAnchor.constraint(
                equalToConstant: 60
            ),

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
                equalTo: addCategoryButton.topAnchor,
                constant: -16
            ),

            emptyStateView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            emptyStateView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            TrackerCategoryTableViewCell.self,
            forCellReuseIdentifier: TrackerCategoryTableViewCell.reuseIdentifier
        )
    }

    private func setupActions() {
        addCategoryButton.addTarget(
            self,
            action: #selector(didTapAddCategory),
            for: .touchUpInside
        )
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.tableView.reloadData()
            self?.updateState()
        }

        viewModel.onCategorySelected = { [weak self] title in
            self?.onCategorySelected?(title)
            self?.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Private Methods

    private func updateState() {
        let isEmpty = viewModel.categoriesCount == 0

        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
    }

    // MARK: - Actions

    @objc
    private func didTapAddCategory() {
        let viewController = NewCategoryViewController(
            viewModel: viewModel
        )

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.categoriesCount
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier:
                    TrackerCategoryTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? TrackerCategoryTableViewCell
        else {
            return UITableViewCell()
        }

        guard let title = viewModel.categoryTitle(
            at: indexPath.row
        ) else {
            return cell
        }

        let isSelected = viewModel.isCategorySelected(
            at: indexPath.row
        )

        cell.configure(
            title: title,
            isSelected: isSelected
        )

        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        viewModel.selectCategory(at: indexPath.row)
    }
}
