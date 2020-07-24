//
//  ViewController.swift
//  GrandCentralDispatch
//
//  Created by Jakub Charvat on 02/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        runMultiprocessingFibonnaci(useGCD: true)
        runMultiprocessingFibonnaci(useGCD: false)
    }

    
    func runBackgroundCode1() {
        performSelector(inBackground: #selector(log(_:)), with: "Hello, World! 1")
        performSelector(onMainThread: #selector(log(_:)), with: "Hello, World! 2", waitUntilDone: false)
        log("Hello, World! 3")
    }
    
    func runBackgroundCode2() {
        DispatchQueue.global().async { [unowned self] in
            self.log("On BG thread")
            
            DispatchQueue.main.async {
                self.log("On main thread")
            }
        }
    }
    
    func runBackgroundCode3() {
        DispatchQueue.global().async {
            guard let url = URL(string: "https://www.apple.com") else { return }
            guard let str = try? String(contentsOf: url) else { return }
            print(str)
        }
    }

    func runSyncCode() {
        // asynchronous!
        DispatchQueue.global().async {
            print("Background thread 1")
        }

        print("Main thread 1")

        // synchronous!
        DispatchQueue.global().sync {
            print("Background thread 2")
        }

        print("Main thread 2")
    }
    
    func runMultiprocessing1() {
        DispatchQueue.concurrentPerform(iterations: 10) {
            print($0)
        }
    }
    
    func runMultiprocessingFibonnaci(useGCD: Bool) {
        func fibonnaci(of num: Int) -> Int {
            if num < 2 {
                return num
            } else {
                return fibonnaci(of: num - 1) + fibonnaci(of: num - 2)
            }
        }
        
        var array = Array(0 ..< 42)
        let start = CFAbsoluteTimeGetCurrent()
        
        if useGCD {
            DispatchQueue.concurrentPerform(iterations: array.count) {
                array[$0] = fibonnaci(of: $0)
            }
        } else {
            for i in 0 ..< array.count {
                array[i] = fibonnaci(of: array[i])
            }
        }
        
        let end = CFAbsoluteTimeGetCurrent()
        let deltaTime = end - start
        
        print("Used GCD Multithreading: \(useGCD)")
        print("Time: \(deltaTime) secs")
        print("-----------------------")
    }
    
    @objc private func log(_ message: String) {
        print("Printing message: \(message)")
    }
}

