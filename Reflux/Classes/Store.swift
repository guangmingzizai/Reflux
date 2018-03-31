//
//  Store.swift
//  Pods
//
//  Created by wangjianfei on 2018/2/28.
//

import Foundation

open class Store<TState>: NSObject {
    public typealias OutputCallback = (_: TState?) -> Void
    public typealias ErrorCallback = (_: Error) -> Void
    
    private var dispatcher: Dispatcher
    private var dispatchToken: DispatchToken?
    
    private var subscribables: [Subscribable<TState>] = []
    
    deinit {
        dispatcher.unregister(id: dispatchToken!)
    }
    
    public init(dispatcher: Dispatcher) {
        self.dispatcher = dispatcher
        super.init()
        
        dispatchToken = dispatcher.register(callback: {[unowned self] (action) in
            self.onEvent(action: action)
        })
    }
    
    open func onEvent(action: Action) -> Void {
        
    }
    
    /**
     * Getter that exposes the entire state of this store. If your state is not
     * immutable you should override this and not expose _state directly.
     */
    open func getState() -> TState? {
        return nil
    }
    
    /**
     * Constructs the initial state for this store. This is called once during
     * construction of the store.
     */
    open func initialState() -> TState? {
        return nil
    }
    
    @discardableResult
    public func makeTarget(_ target: AnyObject, output: @escaping OutputCallback, completion: VoidBlock? = nil, error: ErrorCallback? = nil, initialCallback: OutputCallback? = nil, finally: VoidBlock? = nil) -> Unsubscribable {
        var subscribable = subscribables.first { $0.target === target }
        if subscribable == nil {
            subscribables = subscribables.filter({ $0.target != nil })
            subscribable = Subscribable<TState>(target: target, output: output, completion: completion, error: error, finally: finally, unsubscribe: { [unowned self] (aSubscribable) in
                if let index = self.subscribables.index(of: aSubscribable) {
                    self.subscribables.remove(at: index)
                }
            })
            subscribables.append(subscribable!)
        }
        if let initialCallback = initialCallback {
            initialCallback(initialState())
        }
        
        return subscribable!
    }
    
    public func removeTarget(_ target: AnyObject) {
        if let index = subscribables.index(where: { $0.target === target }) {
            subscribables.remove(at: index)
        }
    }
    
    public func output(_ state: TState?) {
        subscribables = subscribables.filter({ $0.target != nil })
        
        for subscribable in subscribables {
            subscribable.output(state: state)
        }
    }
    
    public func error(_ error: Error) {
        subscribables = subscribables.filter({ $0.target != nil })
        
        for subscribable in subscribables {
            subscribable.error(error: error)
        }
    }
    
    public func completed() {
        subscribables = subscribables.filter({ $0.target != nil })
        
        for subscribable in subscribables {
            subscribable.completed()
        }
    }
    
}
