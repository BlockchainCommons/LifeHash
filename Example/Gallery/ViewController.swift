//
//  MainViewController.swift
//  LifeHash Gallery
//
//  Created by Wolf McNally on 5/3/19.
//

import WolfKit

class MainViewController: ViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    private lazy var frontView = GroupView() • {
        $0.alpha = 0
    }

    private lazy var backView = GroupView() • {
        $0.alpha = 0
    }

    override func build() {
        super.build()

        view.backgroundColor = .black

        view => [
            backView,
            frontView
        ]

        backView.constrainFrameToSafeArea()
        frontView.constrainFrameToSafeArea()
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
        swap(&frontView, &backView)
        frontView.updateImage(traits: traitCollection)
        view.bringSubviewToFront(frontView)
        _ = animation(animated, duration: 2) {
            self.frontView.alpha = 1
        }.map { _ in
            self.backView.alpha = 0
        }
    }

    private var canceler: Cancelable?

    private func startTimer() {
        canceler = dispatchRepeatedOnMain(atInterval: 20) { [unowned self] _ in
            self.updateImage(animated: true)
        }
    }

    private func stopTimer() {
        canceler?.cancel()
    }
}
