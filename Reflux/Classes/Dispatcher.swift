//
//  Dispatcher.swift
//  Pods
//
//  Created by wangjianfei on 2018/2/28.
//

import Foundation

public typealias DispatchToken = String
public typealias Callback = (_: Action) -> Void

fileprivate let prefix = "ID_"

public class Dispatcher {
    
    private var callbacks: [DispatchToken: Callback] = [:]
    public var isDispatching: Bool = false // Is this Dispatcher currently dispatching.
    private var isHandled: [DispatchToken: Bool] = [:]
    private var isPending: [DispatchToken: Bool] = [:]
    private var lastID: Int = 1
    private var pendingAction: Action? = nil
    
    public init() {
        
    }
    
    /**
     * Registers a callback to be invoked with every dispatched payload. Returns
     * a token that can be used with `waitFor()`.
     */
    public func register(callback: @escaping Callback) -> DispatchToken {
        lastID += 1
        let id = "\(prefix)\(lastID)"
        callbacks[id] = callback
        return id
    }
    
    /**
     * Removes a callback based on its token.
     */
    public func unregister(id: DispatchToken) -> Void {
        guard callbacks.contains(where: { $0.key == id }) else {
            print("Dispatcher.unregister(...): `\(id)` does not map to a registered callback.")
            return
        }
        callbacks.removeValue(forKey: id)
    }
    
    /**
     * Waits for the callbacks specified to be invoked before continuing execution
     * of the current callback. This method should only be used by a callback in
     * response to a dispatched payload.
     */
    public func waitFor(ids: [DispatchToken]) -> Void {
        guard isDispatching else {
            print("Dispatcher.waitFor(...): Must be invoked while dispatching.")
            return
        }
        
        for id in ids {
            if let _ = isPending[id] {
                guard isHandled[id] == true else {
                    print("Dispatcher.waitFor(...): Circular dependency detected while waiting for `\(id)`.")
                    return
                }
                continue
            }
            if callbacks[id] != nil {
                invokeCallback(id)
            } else {
                print("Dispatcher.waitFor(...): `\(id)` does not map to a registered callback.")
            }
        }
    }
    
    /**
     * Dispatches a payload to all registered callbacks.
     */
    open func dispatch(_ action: Action) -> Void {
        guard !isDispatching else {
            print("Dispatch.dispatch(...): Cannot dispatch in the middle of a dispatch.")
            return
        }
        
        startDispatching(action)
        for (id, _) in callbacks {
            if isPending[id] == true {
                continue
            }
            invokeCallback(id)
        }
        stopDispatching()
    }
    
    /**
     * Call the callback stored with the given id. Also do some internal
     * bookkeeping.
     */
    private func invokeCallback(_ id: DispatchToken) -> Void {
        isPending[id] = true
        if let callback = callbacks[id], let pendingAction = pendingAction {
            callback(pendingAction)
        }
        isHandled[id] = true
    }
    
    /**
     * Set up bookkeeping needed when dispatching.
     */
    private func startDispatching(_ action: Action) -> Void {
        for (id, _) in callbacks {
            isPending[id] = false
            isHandled[id] = false
        }
        pendingAction = action
        isDispatching = true
    }
    
    /**
     * Clear bookkeeping used for dispatching.
     *
     * @internal
     */
    private func stopDispatching() -> Void {
        pendingAction = nil
        isDispatching = false
    }
}
