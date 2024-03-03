import SwiftUI
import LifeHash

// Thanks to Peter Salz, `https://github.com/psalzAppDev` for this SwiftUI
// implementation!
// https://github.com/BlockchainCommons/LifeHash/issues/5

struct ContentView: View {
    @Namespace
    private var lifeHashDetailAnimation

    @State
    private var version: LifeHashVersion = .version2

    @State
    private var data: [String] = []

    @State
    private var selectedData: String? = nil
    
    @State
    private var frontmostData: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                gridView
                detailView(selectedData: selectedData)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("LifeHash")
            .task {
                let number = 100_000
                data = (1...number).map(String.init)
            }
        }
    }

    @ViewBuilder
    func detailView(selectedData: String?) -> some View {
        Color.clear
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
            .overlay {
                if let selectedData {
                    VStack(spacing: 32) {
                        LifeHashView(
                            state: LifeHashState(
                                input: selectedData.data(using: .utf8),
                                version: version
                            ),
                            missingView: {
                                Image(systemName: "square")
                                    .resizable()
                                    .foregroundStyle(.blue)
                            }
                        )
                        .matchedGeometryEffect(
                            id: "Icon_\(selectedData)",
                            in: lifeHashDetailAnimation,
                            isSource: false
                        )
                        
                        Text(selectedData)
                            .font(.title.bold())
                            .matchedGeometryEffect(
                                id: "Title_\(selectedData)",
                                in: lifeHashDetailAnimation,
                                isSource: false
                            )
                    }
                    .matchedGeometryEffect(
                        id: selectedData,
                        in: lifeHashDetailAnimation,
                        anchor: .top
                    )
                    .padding(64)
                }
            }
            .onTapGesture {
                withAnimation(.default) {
                    self.frontmostData = self.selectedData
                    self.selectedData = nil
                }
            }
            .opacity(selectedData == nil ? 0 : 1)
    }

    @ViewBuilder
    var gridView: some View {
        VStack(spacing: 32) {
            Picker("", selection: $version) {

                Text("V2")
                    .tag(LifeHashVersion.version2)

                Text("Detailed")
                    .tag(LifeHashVersion.detailed)

                Text("Fiducial")
                    .tag(LifeHashVersion.fiducial)

                Text("B&W Fiducial")
                    .tag(LifeHashVersion.grayscaleFiducial)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96))]) {
                    ForEach(data, id: \.self) { str in
                        Group {
                            if str != selectedData {
                                VStack {
                                    LifeHashView(
                                        state: LifeHashState(
                                            input: str.data(using: .utf8),
                                            version: version
                                        ),
                                        missingView: {
                                            Image(systemName: "square")
                                                .resizable()
                                                .foregroundStyle(.blue)
                                        }
                                    )
                                    .matchedGeometryEffect(
                                        id: "Icon_\(str)",
                                        in: lifeHashDetailAnimation,
                                        isSource: false
                                    )
                                    
                                    Text(str)
                                        .matchedGeometryEffect(
                                            id: "Title_\(str)",
                                            in: lifeHashDetailAnimation,
                                            isSource: false
                                        )
                                }
                                .matchedGeometryEffect(
                                    id: str,
                                    in: lifeHashDetailAnimation,
                                    anchor: .top
                                )
                                .onTapGesture {
                                    withAnimation(.default) {
                                        frontmostData = str
                                        selectedData = str
                                    }
                                }
                            } else {
                                Rectangle()
                                    .opacity(0)
                            }
                        }
                        .zIndex(str == frontmostData ? 1 : 0)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.top)
    }
}

#Preview {
    ContentView()
}
