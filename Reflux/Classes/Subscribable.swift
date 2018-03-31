//
//  Subscribable.swift
//  Pods
//
//  Created by wangjianfei on 2018/2/28.
//

import Foundation

public protocol Unsubscribable {
    var subscribed: Bool { get }
    func unsubscribe() -> Void
}

public class Subscribable<TState>: NSObject, Unsubscribable {
    
    public typealias OutputCallback = (_: TState?) -> Void
    public typealias ErrorCallback = (_: Error) -> Void
    public typealias UnsubscribeCallback = (_: Subscribable<TState>) -> Void
    
    private(set) public weak var target: AnyObject? = nil
    private var outputCallback: OutputCallback
    private var completionCallback: VoidBlock?
    private var errorCallback: ErrorCallback?
    private var finallyCallback: VoidBlock?
    private var unsubscribeCallback: UnsubscribeCallback
    
    public var subscribed: Bool = false
    
    init(target: AnyObject, output: @escaping OutputCallback, completion: VoidBlock? = nil, error: ErrorCallback? = nil, finally: VoidBlock? = nil, unsubscribe: @escaping UnsubscribeCallback) {
        self.target = target
        self.outputCallback = output
        self.completionCallback = completion
        self.errorCallback = error
        self.finallyCallback = finally
        self.unsubscribeCallback = unsubscribe
        
        subscribed = true
    }
    
    func output(state: TState?) {
        if let _ = target {
            outputCallback(state)
        } else {
            unsubscribe()
        }
    }
    
    func error(error: Error) {
        if let _ = target {
            if let errorCallback = errorCallback {
                errorCallback(error)
            }
            if let finallyCallback = finallyCallback {
                finallyCallback()
            }
        } else {
            unsubscribe()
        }
    }
    
    func completed() {
        if let _ = target {
            if let completionCallback = completionCallback {
                completionCallback()
            }
            if let finallyCallback = finallyCallback {
                finallyCallback()
            }
        } else {
            unsubscribe()
        }
    }
    
    public func unsubscribe() {
        subscribed = false
        unsubscribeCallback(self)
    }
    
}
