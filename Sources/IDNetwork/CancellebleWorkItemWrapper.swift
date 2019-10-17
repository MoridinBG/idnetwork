//
//  CancellebleURLSessionTask.swift
//  
//
//  Created by Ivan Dilchovski on 17.10.19.
//

import Foundation
import PromiseKit

protocol WorkItem {
    var isRunning: Bool { get }
    func cancel()
}

class CancellebleWorkItemWrapper: Cancellable {
    var workItem: WorkItem?
    
    func cancel() {
        workItem?.cancel()
    }
    
    var isCancelled: Bool {
        return workItem?.isRunning ?? true
    }
}
