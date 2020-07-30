//
//  MainViewController.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 09/15/2018.
//

import UIKit

class MainViewController: UIViewController {
    private lazy var collectionViewLayout = UICollectionViewFlowLayout() • { 🍒 in
        🍒.itemSize = LifeHashCollectionViewCell.imageSize
        🍒.minimumLineSpacing = 20
        🍒.minimumInteritemSpacing = 10
    }

    private lazy var collectionView = CollectionView(collectionViewLayout: self.collectionViewLayout) • { 🍒 in
        🍒.register(LifeHashCollectionViewCell.self, forCellWithReuseIdentifier: "LifeHash")
        🍒.dataSource = self
        🍒.delegate = self
        🍒.backgroundColor = .black
        🍒.contentInset = UIEdgeInsets(all: 20)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view => [
            collectionView
        ]

        collectionView.constrainFrameToFrame()

        navigationController!.navigationBar.barStyle = .blackTranslucent
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100000
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LifeHash", for: indexPath) as! LifeHashCollectionViewCell
        let hashInput = String(indexPath.item).data(using: .utf8)
        cell.hashInput = hashInput
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {

}
