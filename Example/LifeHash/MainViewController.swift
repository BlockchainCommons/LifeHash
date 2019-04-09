//
//  MainViewController.swift
//  LifeHash
//
//  Created by Wolf McNally on 09/15/2018.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import WolfKit

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
