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

struct CallbackItem {
    var callback: Callback
    var queue: DispatchQueue?
}

public class Dispatcher {
    private var callbacks: [DispatchToken: CallbackItem] = [:]
    public var isDispatching: Bool = false // Is this Dispatcher currently dispatching.
    private var isHandled: [DispatchToken: Bool] = [:]
    private var isPending: [DispatchToken: Bool] = [:]
    private var lastID: Int64 = 1
    private var pendingAction: Action? = nil
    private var mutex: pthread_mutex_t
    private var pendingActions: [Action] = []
    
    public init() {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
         
        defer { pthread_mutexattr_destroy(&attr) }
         
        mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, &attr)
    }
    
    @inline(__always)
    fileprivate func lock() {
        let result = pthread_mutex_lock(&mutex)
        precondition(result == 0, "Failed to lock \(self) with error \(result).")
    }

    @inline(__always)
    fileprivate func unlock() {
        let result = pthread_mutex_unlock(&mutex)
        precondition(result == 0, "Failed to unlock \(self) with error \(result).")
    }
    
    /**
     * Registers a callback to be invoked with every dispatched payload. Returns
     * a token that can be used with `waitFor()`.
     */
    public func register(callback: @escaping Callback, on aQueue: DispatchQueue? = nil) -> DispatchToken {
        lock()
        lastID += 1
        let token = "\(prefix)\(lastID)"
        callbacks[token] = CallbackItem(callback: callback, queue: aQueue)
        unlock()
        return token
    }
    
    /**
     * Removes a callback based on its token.
     */
    public func unregister(id: DispatchToken) -> Void {
        lock()
        guard callbacks.contains(where: { $0.key == id }) else {
            print("Dispatcher.unregister(...): `\(id)` does not map to a registered callback.")
            return
        }
        callbacks.removeValue(forKey: id)
        unlock()
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
        lock()
        guard !self.isDispatching else {
            pendingActions.append(action)
            return
        }
        
        self.startDispatching(action)
        for (id, _) in self.callbacks {
            if self.isPending[id] == true {
                continue
            }
            self.invokeCallback(id)
        }
        self.stopDispatching()
        unlock()
        
        if let action = pendingActions.popLast() {
            dispatch(action)
        }
    }
    
    /**
     * Call the callback stored with the given id. Also do some internal
     * bookkeeping.
     */
    private func invokeCallback(_ id: DispatchToken, onQueue: Bool = true) -> Void {
        isPending[id] = true
        if let callbackItem = callbacks[id], let pendingAction = pendingAction {
            if onQueue, let queue = callbackItem.queue {
                queue.async {
                    callbackItem.callback(pendingAction)
                }
            } else {
                callbackItem.callback(pendingAction)
            }
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
