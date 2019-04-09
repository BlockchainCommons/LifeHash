//
//  LifeHashView.swift
//  LifeHash_Example
//
//  Created by Wolf McNally on 12/5/18.
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

import LifeHash
import WolfKit

class LifeHashView: ImageView {
    private typealias `Self` = LifeHashView

    private var canceler: Cancelable?

    private static let cache = Cache<UIImage>.init(filename: "LifeHash.cache", sizeLimit: 100_000, includeHTTP: false)

    override func setup() {
        super.setup()
        layer.magnificationFilter = .nearest
        //logger?.setGroup(.cache)
    }

    var hashInput: Data? = nil {
        didSet { syncToInput() }
    }

    func reset() {
        resetView()
        hashInput = nil
    }

    private func set(image: UIImage) {
        self.backgroundColor = .clear
        self.image = image
    }

    private func resetView() {
        backgroundColor = .darkGray
        image = nil
    }

    private func syncToInput() {
        resetView()

        guard let hashInput = hashInput else { return }

        let url = URL(string: "lifehash:\(hashInput |> toHex)")!
        let future = Self.cache.retrieveObject(for: url)
        future.whenSuccess { image in
            guard hashInput == self.hashInput else { return }
            dispatchOnMain {
                guard hashInput == self.hashInput else { return }
                self.set(image: image)
            }
        }
        future.whenFailure { error in
            guard hashInput == self.hashInput else { return }
            dispatchOnBackground {
                let lifeHash = LifeHash(data: hashInput)
                let image = lifeHash.image
                Self.cache.store(obj: image, for: url)
                guard hashInput == self.hashInput else { return }
                dispatchOnMain {
                    guard hashInput == self.hashInput else { return }
                    self.set(image: image)
                }
            }
        }
    }
}
