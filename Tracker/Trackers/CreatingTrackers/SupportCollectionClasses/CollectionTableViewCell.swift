//
//  CollectionTableViewCell.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 16.09.2026.
//

import UIKit

enum CollectionType {
    case emoji
    case color
}

class CollectionTableViewCell: UITableViewCell {

    //MARK: - Properties

    private let type: CollectionType

    var onEmojiSelected: ((String) -> Void)?
    var onColorSelected: ((UIColor) -> Void)?

    //MARK: - UI Elements

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false

        return collectionView
    }()

    //MARK: - Init

    init(
        type: CollectionType,
        reuseIdentifier: String?
    ) {
        self.type = type
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        setupCollectionView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    //MARK: - Setup

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.allowsMultipleSelection = false

        collectionView.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: "EmojiCell"
        )

        collectionView.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: "ColorCell"
        )

        contentView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            //            collectionView.topAnchor.constraint(
            //                equalTo: contentView.topAnchor
            //            ),
            collectionView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            collectionView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            collectionView.heightAnchor.constraint(
                equalToConstant: 156
            ),
        ])
    }
}

// MARK: - CollectionView

extension CollectionTableViewCell: UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        switch type {
        case .emoji:
            guard
                let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: "EmojiCell",
                        for: indexPath
                    ) as? EmojiCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.layer.cornerRadius = 16
            cell.configure(with: emojis[indexPath.item])

            return cell

        case .color:
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ColorCell",
                    for: indexPath
                ) as? ColorCollectionViewCell
            else {
                return UICollectionViewCell()
            }

            cell.layer.cornerRadius = 11
            cell.configure(with: colors[indexPath.item])
            cell.layer.borderColor =
                colors[indexPath.item].withAlphaComponent(0.3).cgColor

            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch type {
        case .emoji:
            onEmojiSelected?(emojis[indexPath.item])
        case .color:
            onColorSelected?(colors[indexPath.item])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch type {
        case .emoji:
            return emojis.count
        case .color:
            return colors.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth

        let cellWidth = availableWidth / CGFloat(params.cellCount)

        return CGSize(width: cellWidth, height: cellWidth)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        params.cellSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0,
            left: 6,
            bottom: 0,
            right: 6
        )
    }

}
