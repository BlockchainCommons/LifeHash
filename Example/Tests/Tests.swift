import XCTest
//import WolfColor
import WolfKit

class Tests: XCTestCase {
    func test1() {
        print(Color.red |> toLABColor |> toColor)
    }
////    func test1() {
////        var maxGenerations = Int.min
////        for i in 0 ..< 10 {
////            let data = makeRandomData(count: 32)
////            print(data |> toHex)
////
////            let lifeHash = LifeHash(data: data)
//////            lifeHash.fracGrid.dump()
////            print("\(i) generations: \(lifeHash.generations)")
////            maxGenerations = max(maxGenerations, lifeHash.generations)
////        }
////
////        print("maxGenerations: \(maxGenerations)")
////    }
////
////    func test2() {
////        let lifeHash = LifeHash(string: "Hello, world!")
////        lifeHash.fracGrid.dump()
////        lifeHash.colorGrid.dump()
////    }
//
//    private func selectValue(spreadFrac: Frac, centerFrac: Frac, contrast: Frac, interval: Interval<Frac>, reverse: Bool) {
//        let spreadInterval = (0.5 - spreadFrac / 2 .. 0.5 + spreadFrac / 2)
//        let c = (centerFrac - 0.5) * (1.0 - spreadFrac)
//        let centeredSpreadInterval = spreadInterval.a + c .. spreadInterval.b + c
//        let mid = 0.5.lerpedFromFrac(to: centeredSpreadInterval)
//        let attenuatedIntervalA = contrast.lerpedFromFrac(to: mid .. centeredSpreadInterval.a)
//        let attenuatedIntervalB = contrast.lerpedFromFrac(to: mid .. centeredSpreadInterval.b)
//        let attenuatedInterval = attenuatedIntervalA .. attenuatedIntervalB
//        let finalInterval = attenuatedInterval.lerped(from: 0 .. 1, to: interval)
//        let reversedInterval = reverse ? finalInterval.swapped() : finalInterval
//        print(spreadInterval)
//        print(centeredSpreadInterval)
//        print(attenuatedInterval)
//        print(finalInterval)
//        print(reversedInterval)
//        print("")
//    }
//
//    func test3() {
//        selectValue(spreadFrac: 0.2, centerFrac: 0.0, contrast: 1.0, interval: 0.0 .. 0.5, reverse: false)
//        selectValue(spreadFrac: 0.2, centerFrac: 0.5, contrast: 1.0, interval: 0.0 .. 0.5, reverse: false)
//        selectValue(spreadFrac: 0.2, centerFrac: 1.0, contrast: 1.0, interval: 0.0 .. 0.5, reverse: false)
//        selectValue(spreadFrac: 0.2, centerFrac: 1.0, contrast: 0.5, interval: 0.0 .. 0.5, reverse: false)
//        selectValue(spreadFrac: 0.2, centerFrac: 1.0, contrast: 0.5, interval: 0.0 .. 0.5, reverse: true)
//        selectValue(spreadFrac: 0.2, centerFrac: 1.0, contrast: 0.0, interval: 0.0 .. 0.5, reverse: false)
//    }
}
