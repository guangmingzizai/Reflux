//
//  ViewController.swift
//  Reflux
//
//  Created by guangmingzizai@qq.com on 02/28/2018.
//  Copyright (c) 2018 guangmingzizai@qq.com. All rights reserved.
//

import UIKit
import Reflux

class ViewController: UIViewController {

    private let store: CountStore = CountStore()
    private var storeUnsubscribable: Unsubscribable?
    
    @IBOutlet weak var countLabel: UILabel!
    
    deinit {
        storeUnsubscribable?.unsubscribe()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeUnsubscribable =
        store.makeTarget(self, output: { [unowned self] (count: Int?) in
            if let count = count {
                self.countLabel.text = "Count: \(count)"
            }
        })
    }
    
    @IBAction func onTapAddButton(_ sender: Any) {
        countDispatcher.dispatch(CountAction())
    }
    
}

