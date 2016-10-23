import UIKit

/*
    Name: Shruthi Vinjamuri
    Email: shruthi@uwm.edu
    This assignment is done using swift 3.0
 */

/*
 This function takes an integer and returns an integer. The output will contain the
 same digits as the input but in sorted order (e.g. 12345 becomes 54321, 10305 becomes 53100).
 */
func sortDigits(number: Int) -> Int {
    var numbers: [Int] = []
    var retValue = number
    while retValue > 0 {
        numbers.append(retValue % 10)
        retValue /= 10
    }
    numbers.sort(by: {$0 > $1})
    for value in numbers {
        retValue = retValue*10 + value
    }
    return retValue
}

func test1(){
    sortDigits(number: 12345)
    sortDigits(number: 10305)
    sortDigits(number: 8923106)
    sortDigits(number: 0)
    sortDigits(number: 11111)
    
}

/*
 This function removes the words which end with ly from a sentence.
 */
func deadverbs(sentence: String) -> String {
    let words = sentence.components(separatedBy: " ")
    var retValue: String = ""
    for value in words {
        if !value.hasSuffix("ly") {
            retValue += value + " "
        }
    }
    return retValue.trimmingCharacters(in: NSCharacterSet.whitespaces)
}

func test2(){
    // No adverb
    deadverbs(sentence: "Hello this is swift")
    // all words are adverbs
    deadverbs(sentence: "Helloly thisly isly swiftly")
    // Single word with ly between
    deadverbs(sentence: "Hellothislyislyswift")
    //just one adverb
    deadverbs(sentence: "Hello this isly swift")
}

/*
    Returns an optional tuple containing min and max values from the input list.
 */
func minAndMax(numbers: [Int]) -> (min: Int, max: Int)? {
    if numbers.count < 1 {
        return nil
    }
    var minValue = Int.max
    var maxValue = Int.min
    for value in numbers {
        if value < minValue {
            minValue = value
        }
        
        if value > maxValue {
            maxValue = value
        }
    }
    return (minValue, maxValue)
}

func test3(){
    // unwrapping using if let
    if let tuple = minAndMax(numbers: []) {
        // firstTuple has non-nil value
        print("Max value is: \(tuple.max) and min value is: \(tuple.min)")
    }
    else {
        print("There are no min and max values found.")
    }
    
    //unwrapping using bang operator
    let tuple = minAndMax(numbers: [3,1,7,5,1,9])!
    print("Max value is: \(tuple.max) and min value is: \(tuple.min)")
    
    let secondTuple = minAndMax(numbers: [12,98,34,88,2834,984])
    print("Max value is: \(secondTuple!.max) and min value is: \(secondTuple!.min)")
    
    // Unwrapping using '?'. Should just return nil for max and min values
    let thirdTuple = minAndMax(numbers: [])
    print("Max value is: \(thirdTuple?.max) and min value is: \(thirdTuple?.min)")
    
    // unwrapping using 'if let'
    if let tuple = minAndMax(numbers: [70, 32, 88, 19, 0, 4]) {
        // firstTuple has non-nil value
        print("Max value is: \(tuple.max) and min value is: \(tuple.min)")
    }
    else {
        print("There are no min and max values found.")
    }
    
    minAndMax(numbers: [1,1,1,1,1,1,1])
    minAndMax(numbers: [Int.max, Int.min])
}

/*
    Filters and transforms the input list values based on the passed in functions.
 */
func filterAndTransform<T, R>(values: [T], filter: (T) -> Bool, transform: (T) -> R) -> [R] {
    var returnValues: [R] = []
    for value in values {
        if filter(value) {
            returnValues.append(transform(value))
        }
    }
    return returnValues
}

func test4(){
    
    /*
     1. Filters a list of integers so that odd numbers are thrown out and transforms them into a string.
     Example: [1, 2, 3, 4, 5, 6] becomes ["2", "4", "6"]
     */
    func filterOdds(value: Int) -> Bool{
        return value % 2 == 0
    }
    func transformToString(value: Int) -> String {
        return String(value)
    }
    filterAndTransform(values: [1,2,3,4,5,6], filter: filterOdds, transform: transformToString)
    // All odds and output should be empty
    filterAndTransform(values: [5,7,3,1,9], filter: filterOdds, transform: transformToString)
    // All evens and output should be entire input number should be transformed
    filterAndTransform(values: [56,88,54,12,0], filter: filterOdds, transform: transformToString)
    
    /*
     2. Transforms a list of integers (unfiltered) so that the digits are sorted in the output list.
    Example: [13, 42, 35, 64] becomes [31, 42, 53, 64]
     */
    func returnTrue(value: Int) -> Bool {
        return true
    }
    
    filterAndTransform(values: [13, 42, 35, 64], filter: returnTrue, transform: sortDigits)
    // Empty Input
    filterAndTransform(values: [], filter: returnTrue, transform: sortDigits)
}

test1()
test2()
test3()
test4()
