//
//  Action.swift
//  Pods
//
//  Created by wangjianfei on 2018/2/28.
//

import Foundation

/// All actions that want to be able to be dispatched to a store need to conform to this protocol
/// Currently it is just a marker protocol with no requirements.
public protocol Action { }

extension Action {
    public func trigger(_ dispatcher: Dispatcher) {
        dispatcher.dispatch(self)
    }
}

public protocol ActionHandler: class {
    func onEvent(action: Action) -> Void
}
