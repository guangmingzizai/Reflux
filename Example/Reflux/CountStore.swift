//
//  CountStore.swift
//  Reflux_Example
//
//  Created by wangjianfei on 2018/2/28.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import Reflux

class CountStore: Store<Int> {
    
    init() {
        super.init(dispatcher: countDispatcher)
    }
    
    private var count = 0
    
    override func initialState() -> Int? {
        return count
    }
    
    override func onEvent(action: Action) {
        switch action {
        case _ as CountAction:
            count += 1
            output(count)
        default:
            break
        }
    }
    
}
