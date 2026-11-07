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
    }

    //MARK: - Public Methods

    private func category(at index: Int) -> TrackerCategory? {
        let categories = categoryStore.categories

        guard categories.indices.contains(index) else {
            return nil
        }

        return categories[index]
    }

    var categoriesCount: Int {
        categoryStore.categories.count
    }

    func categoryTitle(at index: Int) -> String? {
        category(at: index)?.title
    }

    func isCategorySelected(at index: Int) -> Bool {
        guard let category = category(at: index) else {
            return false
        }

        return category.title == selectedCategoryTitle
    }

    func selectCategory(at index: Int) {
        guard let category = category(at: index) else {
            return
        }

        selectedCategoryTitle = category.title
        onCategorySelected?(category.title)
    }

    func isCategoryNameValid(_ name: String) -> Bool {
        validatedCategoryTitle(name) != nil
    }

    private func validatedCategoryTitle(_ title: String) -> String? {
        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedTitle.isEmpty,
            !categoryStore.categories.contains(where: {
                $0.title.caseInsensitiveCompare(trimmedTitle) == .orderedSame
            })
        else {
            return nil
        }

        return trimmedTitle
    }

    func addCategory(title: String) throws {

        guard let normalizedTitle = validatedCategoryTitle(title) else {
            return
        }

        let category = TrackerCategory(
            title: normalizedTitle,
            trackers: []
        )

        try categoryStore.addCategory(category)

        onCategoriesChanged?()
    }
}
