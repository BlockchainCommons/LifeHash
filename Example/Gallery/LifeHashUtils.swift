//import LifeHash
//import simd
//import UIKit
//import WolfConcurrency
//import WolfCache

//extension LifeHash {
//    private static let serializer = Serializer()
//
//    static let lifeHashCache = Cache<UIImage>.init(filename: "LifeHash.cache", sizeLimit: 100_000, includeHTTP: false)
//    static var promises: [URL: [Promise<UIImage>]] = [:]
//
//    /// Additional requests for the same LifeHash image while one is already in progress are recorded,
//    /// and all are responded to when the image is done. This is so almost-simultaneous requests for the
//    /// same data don't trigger duplicate work.
//    static func getImageForInput(_ input: Data) -> Future<UIImage> {
//        func recordPromise(_ promise: Promise<UIImage>, for url: URL) -> Bool {
//            var result: Bool!
//            serializer.dispatch {
//                if let urlPromises = promises[url] {
//                    var p = urlPromises
//                    p.append(promise)
//                    promises[url] = p
//                    result = false
//                } else {
//                    promises[url] = [promise]
//                    result = true
//                }
//            }
//            return result
//        }
//
//        func succeedPromises(for url: URL, with image: UIImage) {
//            serializer.dispatch {
//                guard let urlPromises = promises[url] else { return }
//                promises.removeValue(forKey: url)
//                for promise in urlPromises {
//                    promise.succeed(image)
//                }
//            }
//        }
//
//        let promise = MainEventLoop.shared.makePromise(of: UIImage.self)
//        let url = URL(string: "lifehash:\(input |> toHex)")!
//        //logTrace(url)
//        if recordPromise(promise, for: url) {
//            let future = lifeHashCache.retrieveObject(for: url)
//            future.whenSuccess { image in
//                //logTrace("cache hit")
//                succeedPromises(for: url, with: image)
//            }
//            future.whenFailure { error in
//                //logTrace("cache miss")
//                dispatchOnBackground {
//                    let lifeHash = LifeHash(data: input)
//                    let image = lifeHash.image
//                    lifeHashCache.store(obj: image, for: url)
//                    //logTrace("image generated")
//                    succeedPromises(for: url, with: image)
//                }
//            }
//        }
//        return promise.futureResult
//    }
//}
