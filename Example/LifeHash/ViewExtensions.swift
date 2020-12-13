//
//  ViewExtensions.swift
//  LifeHashExample
//
//  Created by Wolf McNally on 12/13/20.
//

import UIKit

extension NSLayoutConstraint {
    func setPriority(to p: UILayoutPriority) -> NSLayoutConstraint {
        let c = self
        c.priority = p
        return c
    }
}

extension UIView {
    func constrainFrameToSafeArea() {
        guard let superview = superview else { fatalError() }
        let safeArea = superview.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            topAnchor.constraint(equalTo: safeArea.topAnchor),
            bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    func constrainFrameToFrame(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { fatalError() }
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }

    func constrainAspect() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: heightAnchor)
        ])
    }

    func constrainCenterToCenter() {
        guard let superview = superview else { fatalError() }
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }

    func constrainHeight(to height: CGFloat) {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height)
        ])
    }

    func constrainSize(to size: CGSize) {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
}
