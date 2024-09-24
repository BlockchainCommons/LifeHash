
import Foundation
import Dispatch

public typealias Block = () -> Void
public typealias BoolBlock = (Bool) -> Void

public let mainQueue = DispatchQueue.main
public let backgroundQueue = DispatchQueue.global()

public protocol Cancelable: AnyObject {
    var isCanceled: Bool { get }
    func cancel()
}

// A block that takes a Canceler. The block will not be called again if it sets the <isCanceled> variable of the Canceler to true.
public typealias CancelableBlock = (Cancelable) -> Void

// A Canceler is returned by that either execute a block asyncronously once or at intervals. If the <isCanceled> variable is set to true, the block will never be executed, or the calling of the block at intervals will stop.
public class Canceler: Cancelable {
    public init() { }
    public var isCanceled = false
    public func cancel() { isCanceled = true }
}

public func checkMainThread() {
    precondition(Thread.isMainThread)
}

private func _dispatchOnQueue(_ queue: DispatchQueue, cancelable: Cancelable, _ f: @escaping CancelableBlock) {
    queue.async {
        f(cancelable)
    }
}

private func _dispatchOnQueue(_ queue: DispatchQueue, afterDelay delay: TimeInterval, cancelable: Cancelable, f: @escaping CancelableBlock) {
    queue.asyncAfter(deadline: DispatchTime.now() + delay) {
        f(cancelable)
    }
}

// Dispatch a block asynchronously on the give queue. This method returns immediately. Blocks dispatched asynchronously will be executed at some time in the future.
@discardableResult public func dispatchOnQueue(_ queue: DispatchQueue, _ f: @escaping Block) -> Cancelable {
    let canceler = Canceler()
    _dispatchOnQueue(queue, cancelable: canceler) { cancelable in
        if !cancelable.isCanceled {
            f()
        }
    }
    return canceler
}

// Dispatch a block asynchronously on the main queue.
@discardableResult public func dispatchOnMain(f: @escaping Block) -> Cancelable {
    return dispatchOnQueue(mainQueue, f)
}

// Dispatch a block asynchronously on the background queue.
@discardableResult public func dispatchOnBackground(f: @escaping Block) -> Cancelable {
    return dispatchOnQueue(backgroundQueue, f)
}

// After the given delay, dispatch a block asynchronously on the given queue. Returns a Canceler object that, if its <isCanceled> attribute is true when the dispatch time arrives, the block will not be executed.
@discardableResult public func dispatchOnQueue(_ queue: DispatchQueue, afterDelay delay: TimeInterval, f: @escaping Block) -> Cancelable {
    let canceler = Canceler()
    _dispatchOnQueue(queue, afterDelay: delay, cancelable: canceler) { canceler in
        if !canceler.isCanceled {
            f()
        }
    }
    return canceler
}

// After the given delay, dispatch a block asynchronously on the main queue. Returns a Canceler object that, if its <isCanceled> attribute is true when the dispatch time arrives, the block will not be executed.
@discardableResult public func dispatchOnMain(afterDelay delay: TimeInterval, f: @escaping Block) -> Cancelable {
    return dispatchOnQueue(mainQueue, afterDelay: delay, f: f)
}

// After the given delay, dispatch a block asynchronously on the background queue. Returns a Canceler object that, if its <isCanceled> attribute is true when the dispatch time arrives, the block will not be executed.
@discardableResult public func dispatchOnBackground(afterDelay delay: TimeInterval, f: @escaping Block) -> Cancelable {
    return dispatchOnQueue(backgroundQueue, afterDelay: delay, f: f)
}

private func _dispatchRepeated(on queue: DispatchQueue, atInterval interval: TimeInterval, cancelable: Cancelable, _ f: @escaping CancelableBlock) {
    _dispatchOnQueue(queue, afterDelay: interval, cancelable: cancelable) { cancelable in
        if !cancelable.isCanceled {
            f(cancelable)
        }
        if !cancelable.isCanceled {
            _dispatchRepeated(on: queue, atInterval: interval, cancelable: cancelable, f)
        }
    }
}

// Dispatch the block immediately, and then again after each interval passes. An interval of 0.0 means dispatch the block only once.
@discardableResult public func dispatchRepeated(on queue: DispatchQueue, atInterval interval: TimeInterval, f: @escaping CancelableBlock) -> Cancelable {
    let canceler = Canceler()
    _dispatchOnQueue(queue, cancelable: canceler) { cancelable in
        if !cancelable.isCanceled {
            f(cancelable)
        }
        if interval > 0.0 {
            if !cancelable.isCanceled {
                _dispatchRepeated(on: queue, atInterval: interval, cancelable: cancelable, f)
            }
        }
    }
    return canceler
}

@discardableResult public func dispatchRepeatedOnMain(atInterval interval: TimeInterval, f: @escaping CancelableBlock) -> Cancelable {
    return dispatchRepeated(on: mainQueue, atInterval: interval, f: f)
}

@discardableResult public func dispatchRepeatedOnBackground(atInterval interval: TimeInterval, f: @escaping CancelableBlock) -> Cancelable {
    return dispatchRepeated(on: backgroundQueue, atInterval: interval, f: f)
}
