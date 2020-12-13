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
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = LifeHashCollectionViewCell.size
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(LifeHashCollectionViewCell.self, forCellWithReuseIdentifier: "LifeHash")
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .systemBackground
        view.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
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
            dest.hashInput = title.data(using: .utf8)
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
        cell.hashInput = title.data(using: .utf8)
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToItem(at: indexPath)
    }
}
