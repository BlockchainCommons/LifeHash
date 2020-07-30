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
import WolfWith
import WolfViews
import WolfViewControllers
import WolfPipe
import WolfNesting
import WolfFoundation

class MainViewController: ViewController {
    private lazy var collectionViewLayout = UICollectionViewFlowLayout() • { 🍒 in
        🍒.itemSize = LifeHashCollectionViewCell.size
        🍒.minimumLineSpacing = 10
        🍒.minimumInteritemSpacing = 10
    }

    private lazy var collectionView = CollectionView(collectionViewLayout: self.collectionViewLayout) • { 🍒 in
        🍒.register(LifeHashCollectionViewCell.self, forCellWithReuseIdentifier: "LifeHash")
        🍒.dataSource = self
        🍒.delegate = self
        🍒.backgroundColor = .systemBackground
        🍒.contentInset = UIEdgeInsets(all: 20)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view => [
            collectionView
        ]

        collectionView.constrainFrameToFrame()

        navigationController!.navigationBar.isTranslucent = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "toDetail":
            let dest = segue.destination as! DetailViewController
            let title = String(collectionView.indexPathsForSelectedItems!.first!.item)
            dest.hashTitle = title
            dest.hashInput = title |> toUTF8
        default:
            fatalError()
        }
    }

    func navigateToItem(at indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100000
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LifeHash", for: indexPath) as! LifeHashCollectionViewCell
        let title = String(indexPath.item)
//        let title = "166"
        cell.hashTitle = title
        cell.hashInput = title |> toUTF8
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToItem(at: indexPath)
    }
}
