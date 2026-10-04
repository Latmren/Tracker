//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 02.10.2026.
//

import Foundation

final class TrackerCategoryViewModel {
    // MARK: - Properties

    private let categoryStore: TrackerCategoryStore

    private(set) var selectedCategoryTitle: String?

    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?

    //MARK: - Initialization

    init(
        categoryStore: TrackerCategoryStore,
        selectedCategoryTitle: String? = nil
    ) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle

        categoryStore.delegate = self
    }

    //MARK: - Public Methods

    var categoriesCount: Int {
        categoryStore.categories.count
    }

    func categoryTitle(at index: Int) -> String {
        categoryStore.categories[index].title
    }

    func isCategorySelected(at index: Int) -> Bool {
        categoryStore.categories[index].title == selectedCategoryTitle
    }

    func selectCategory(at index: Int) {
        let category = categoryStore.categories[index]

        selectedCategoryTitle = category.title
        onCategorySelected?(category.title)
    }

    func isCategoryNameAvailable(_ title: String) -> Bool {
        let normalizedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return !categoryStore.categories.contains {
            $0.title.caseInsensitiveCompare(normalizedTitle) == .orderedSame
        }
    }

    func addCategory(title: String) throws {
        let normalizedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard isCategoryNameAvailable(normalizedTitle) else {
            return
        }

        let category = TrackerCategory(
            title: normalizedTitle,
            trackers: []
        )

        try categoryStore.addCategory(category)
    }
}
extension TrackerCategoryViewModel: StoreDelegate {

    func storeDidUpdate() {
        onCategoriesChanged?()
    }
}
