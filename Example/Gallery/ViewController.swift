//
//  MainViewController.swift
//  LifeHash Gallery
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 5/3/19.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    private lazy var frontView: GroupView = {
        let view = GroupView()
        view.alpha = 0
        return view
    }()

    private lazy var backView: GroupView = {
        let view = GroupView()
        view.alpha = 0
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        view.addSubview(backView)
        view.addSubview(frontView)

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
        UIView.animate(withDuration: 2) {
            self.frontView.alpha = 1
        } completion: { _ in
            self.backView.alpha = 0
        }
    }

    private var cancellable: AnyCancellable?

    private func startTimer() {
        cancellable = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateImage(animated: true)
            }
        updateImage(animated: true)
    }

    private func stopTimer() {
        cancellable = nil
    }
}
