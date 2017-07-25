//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

extension Int {
    static func random(min: Int, max: Int) -> Int {
        return min + (Int(arc4random()) % (max - min + 1))
    }
}

let min = -10
let max = 10

let count = 100
var avg : Float = 0.0

for _ in 0..<count {
    let val = Int.random(min: min, max: max)
    print(val)
    
    if val < min {
        print("error")
    }
    
    if val > max {
        print("error")
    }
    
    avg += Float(val)
}

avg = avg / Float(count)
