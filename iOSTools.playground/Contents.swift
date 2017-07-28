import UIKit
import Foundation

// base 64

fileprivate extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

// Random

extension Int {
    static func random(min: Int, max: Int) -> Int {
        return min + (Int(arc4random()) % (max - min + 1))
    }
}

let min = -10
let max = 10

var count = 100
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

// Sort

func quicksort(_ arr: [Int]) -> [Int] {
    if arr.count <= 1 {
        print("")
        return arr
    }
    else if arr.count == 2 {
        return (arr[0] < arr[1]) ? arr : [arr[1], arr[0]]
    }
    else {
        var mArr = arr
        let pivot : Int = mArr.remove(at: arr.count / 2)
        let left = mArr.filter({$0 <= pivot})
        let right = mArr.filter({$0 > pivot})
        let center = [pivot]
        print("\(left) <= \(center) < \(right)")
        return quicksort(left) + center + quicksort(right)
    }
}

var unsorted : [Int] = []
count = 5

for _ in 0...count {
    unsorted.append(Int(arc4random()) % count)
}

let sorted = quicksort(unsorted)

print("unsorted: \(unsorted)")
print("  sorted: \(sorted)")


// Fib

func fib(_ n: UInt) -> UInt {
    if n <= 1 {
        return n
    }
    else {
        return fib(n - 2) + fib(n - 1)
    }
}


print("")

// map vs flatmap

let arr = [1,2,3,4,5,4]

print(arr.map({String($0 * 2) + "x"}))
print(arr.flatMap({String($0 * 2) + "x"}))

let mapArr = arr.map { (string: Int) -> String? in
    if string < 2 {
        return nil
    }
    else {
        return String(string * 2) + "x"
    }
}

let flatMapArr = arr.flatMap { (string: Int) -> String? in
    if string < 2 {
        return nil
    }
    else {
        return String(string * 2) + "x"
    }
}

print("")

// convert to optional, nil if failed
print("mapArr: \(mapArr))")

// convert to non-optional, remove nils
// mapping & flattening
print("flatMapArr: \(flatMapArr)")


// class vs static
// The subclasses can override class methods, but cannot override static methods.












