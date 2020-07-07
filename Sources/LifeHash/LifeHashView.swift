//
//  LifeHashView.swift
//  LifeHash
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation
import SwiftUI

public struct LifeHashView<MissingView: View>: View {
    @ObservedObject var state: LifeHashState
    private var missingView: MissingView

    public init(state: LifeHashState, missingView: MissingView) {
        self.state = state
        self.missingView = missingView
    }

    public var body: some View {
        Group {
            if state.image != nil {
                Image(uiImage: state.image!)
                    .resizable()
                    .interpolation(.none)
            } else {
                missingView
            }
        }
        .aspectRatio(contentMode: .fit)
    }
}

#if DEBUG
struct LifeHashView_Previews: PreviewProvider {
    struct Preview: View {
        @State var string: String? {
            didSet {
                lifeHashState.input = string
            }
        }

        @State var lifeHashState = LifeHashState()

        let missingView: some View = Image(systemName: "square").resizable().foregroundColor(.blue)

        var body: some View {
            VStack {
                LifeHashView(state: lifeHashState, missingView: missingView)
                    .frame(width: 128)
                Text(string ?? "<nil>")
                Button(action: {
                    self.string = nil
                }) {
                    Text("Clear")
                }

                Button(action: {
                    self.string = Self.randomWord()
                    //self.string = "0"
                }) {
                    Text("Set")
                }
            }
        }

        static func randomWord() -> String {
            let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            let count = (2...10).randomElement()!
            let letters = (0..<count).map { _ in alphabet.randomElement()! }
            return String(letters)
        }
    }

    static var previews: some SwiftUI.View {
        Preview()
    }
}
#endif
