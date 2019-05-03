//
//  MainViewController.swift
//  LifeHash Gallery
//
//  Created by Wolf McNally on 5/3/19.
//

import WolfKit
import LifeHash

class MainViewController: ViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    private lazy var frontImageView = LifeHashView() • {
        $0.contentMode = .scaleAspectFit
        $0.alpha = 0
    }

    private lazy var backImageView = LifeHashView() • {
        $0.contentMode = .scaleAspectFit
        $0.alpha = 0
    }

    override func build() {
        super.build()

        view.backgroundColor = .black

        view => [
            backImageView,
            frontImageView
        ]

        backImageView.constrainFrameToFrame()
        frontImageView.constrainFrameToFrame()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //updateImage(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }

    private func updateImage(animated: Bool) {
        swap(&frontImageView, &backImageView)
        view.bringSubviewToFront(frontImageView)

        let index = Int.random(in: 0 ..< 1_000_000)
        let string = String(index)
        let data = string |> toUTF8
        frontImageView.input = data
        _ = animation(animated, duration: 2) {
            self.frontImageView.alpha = 1
        }.map { _ in
            self.backImageView.alpha = 0
        }
    }

    private var canceler: Cancelable?

    private func startTimer() {
        canceler = dispatchRepeatedOnMain(atInterval: 30) { [unowned self] _ in
            self.updateImage(animated: true)
        }
    }

    private func stopTimer() {
        canceler?.cancel()
    }
}
