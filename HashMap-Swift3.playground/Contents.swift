//: Playground - noun: a place where people can play

import Foundation

class HashEntry<K, V> {
    let key: K
    var value: V?
    var next: HashEntry<K, V>?
    
    init(key: K, value: V?, next: HashEntry<K, V>?) {
        self.key = key
        self.value = value
        self.next = next
    }
    
    convenience init(key: K, value: V?) {
        self.init(key: key, value: value, next: nil)
    }
}

class HashTable<K: Hashable, V: Equatable> {
    private var buckets: [HashEntry<K, V>?]
    
    init(intialCapacity: Int) {
        self.buckets = [HashEntry<K, V>?](repeating: nil, count: intialCapacity)
    }
    
    convenience init() {
        self.init(intialCapacity: 8)
    }
    
    // Generates the index from the input hash bounded by the bucket length
    private func getIndexOfEntry(hash: Int, length: Int) -> Int {
        return hash & (length - 1)
    }
    
    /*
     Takes a value and returns true if the value is present
     */
    public func containsValue(value: V?) -> Bool {
        
        for index in 0 ..< buckets.count { // Iterate over the buckets
            var entry = buckets[index]
            while entry != nil {        // Iterate over the entries for a bucket
                if entry?.value == value {
                    return true
                }
                entry = entry?.next
            }
        }
        return false
    }
    /*
     Takes a key and returns a value or nil
     */
    public func get(key: K) -> V? {
        // Get the head of the entries where the input key might be present
        var entry = buckets[getIndexOfEntry(hash: key.hashValue, length: buckets.count)]
        while entry != nil {    // Iterate over the entries to search for the input key
            if entry?.key == key {
                return entry?.value
            }
            entry = entry?.next
        }
        return nil
    }
    
    /*
     Input: key of generic type
     Return: true if the key is present, otherwise false
     */
    public func contains(key: K) -> Bool {
        // Return true if a value if found for key using get
        return get(key: key) != nil
    }
    
    /*
     Takes a key and value, associates the value with that key, and then returns the
     previous value associated with that key (if any)
     */
    public func put(key: K, value: V?) -> V? {
        let bucketIndex = getIndexOfEntry(hash: key.hashValue, length: buckets.count)
        var entry = buckets[bucketIndex]
        // Iterate over the list of entries to search for the input key
        while entry != nil {
            if entry?.key == key {      // Key found, update the new value and return old value
                let oldValue = entry?.value
                entry?.value = value
                return oldValue
            }
            entry = entry?.next
        }
        
        // Key not present: Create a new HashEntry, add it to the bucket and
        // append the existing entries to the newly added entry
        buckets[bucketIndex] = HashEntry<K, V>(key: key, value: value, next: buckets[bucketIndex])
        return nil
    }
}

/*
 Takes a string s and an integer n, and returns a list of tuples with components word and count.
 The output list should contain at most n elements. Each element of the output list should be a
 word in s and the number of times it occurs in s.
 */
func mostFrequent(s: String, n: Int) -> [(word: String, count: Int)] {
    let words = s.components(separatedBy: " ")
    let hashTable = HashTable<String, Int>()
    var setOfWords = Set<String>()
    for word in words {
        if hashTable.contains(key: word) {
            // key is already present so increment the value by 1
            hashTable.put(key: word, value: hashTable.get(key: word)! + 1)
        }
        else {
            // new key found, add this key with value of 1
            hashTable.put(key: word, value: 1)
            setOfWords.insert(word)
        }
    }
    
    var countOfWords: [(String, Int)] = []
    // Count the occurences of each word, update this count as value and word as key
    for word in setOfWords {
        countOfWords.append((word, hashTable.get(key: word)!))
    }
    // Sort based on the count of the word
    countOfWords.sort(by: { $0.1 > $1.1})
    let maxIndex = n > countOfWords.count ? countOfWords.count : n
    return Array(countOfWords[0..<maxIndex])
}

func testMostFrequent() {
    // Should return any of the three words
    mostFrequent(s: "the is a word", n: 3)
    // Should return all the words with their respective occurences
    mostFrequent(s: "the is word hello is a word the there the", n: 88)
    // Should return only the word 'had' with its count: 11
    mostFrequent(s: "James while John had had had had had had had had had had had a better effect on the teacher", n: 1)
    // Should return only 'that' and 'exists' words with their respective counts of 6 & 4
    mostFrequent(s: "that that exists exists in that that that that exists exists in", n: 2)
    
    // Regression testing of hashtable
    mostFrequent(s: "wallball is a type of school yard game similar to butts up, aces-kings-queens, Chinese handball, and American handball American handball is sometimes actually referred to as wallball. The sport was played by a few schools in the San Francisco Bay Area and New York City, then began gaining much popularity, resulting in a popular worldwide sport. wallball is now played globally with the international federation, Wall Ball International, promoting the game The game requires the ball to be hit to the floor before hitting the wall, but in other respects is similar to squash. It can be played as a singles, doubles or elimination game. wallball is derived from many New York City street games played by young people often involving the Spalding hi-bounce balls created in 1949", n: 10)
}

testMostFrequent()

