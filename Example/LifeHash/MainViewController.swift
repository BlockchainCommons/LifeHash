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
import LifeHash

class MainViewController: UIViewController {
    private var version: LifeHashVersion = .version2 {
        didSet {
            syncToVersion()
        }
    }
    
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
        view.contentInset = UIEdgeInsets(top: 50, left: 20, bottom: 20, right: 20)
        view.isPrefetchingEnabled = false
        return view
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["V2", "Detailed", "Fiducial", "B&W Fiducial"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    @objc func segmentedControlChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            version = .version2
        case 1:
            version = .detailed
        case 2:
            version = .fiducial
        case 3:
            version = .grayscaleFiducial
        default:
            fatalError()
        }
    }
    
    private func syncToVersion() {
        for cell in collectionView.visibleCells {
            guard let cell = cell as? LifeHashCollectionViewCell else { continue }
            cell.set(hashInput: cell.hashInput, version: version)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.constrainFrameToFrame()
        
        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor)
        ])
        
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
            dest.set(hashInput: title.data(using: .utf8), version: version)
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
        cell.hashTitle = title
        cell.set(hashInput: title.data(using: .utf8), version: version)
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToItem(at: indexPath)
    }
}
