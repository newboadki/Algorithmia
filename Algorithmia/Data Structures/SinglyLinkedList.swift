//
//  SinglyLinkedList.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 30/04/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation


/// Helper class to implement copy-on-write
fileprivate class IndirectStorage<T> {
    
    var head: SinglyLinkedListNode<T>?
    
    var tail: SinglyLinkedListNode<T>?
    
    init(head: SinglyLinkedListNode<T>?, tail: SinglyLinkedListNode<T>?) {
        self.head = head
        self.tail = tail
    }
    
    convenience init() {
        self.init(head: nil, tail: nil)
    }
}



// MARK: - NODE -

/// A node is the building block of a linked list.
/// It can be used on its own to create linked lists. However users of this class,
/// will need to manipulate references directly.
public class SinglyLinkedListNode<T> {
    
    /// Data container
    public var value: T
    
    /// Link to the next node
    public var next: SinglyLinkedListNode<T>?
    
    /// Designated initializer
    ///
    /// - Parameter value: A value
    public init(value: T) {
        self.value = value
    }
}



// MARK: - LINKED LIST -

/// Data structure to hold a collection of items.
/// Each nodes contains a reference to the next node.
/// The last node does not reference any other node.
/// This class implements value semantics based on copy-on-write.
///
/// However, the elements contained in the list, will be shallow copied if they
/// implement reference semantics.
public struct SinglyLinkedList<T>
{
    // MARK: - PROPERTIES
    
    // A level of inderiction, with reference semantics to allow easy
    // detection of when there are more than one references of the storage.
    private var storage: IndirectStorage<T>
    
    /// Whenever there's a change that potentially can change the value, this reference to the
    /// storage should be used to guarantee that a new copy is created and written on.
    private var storageForWritting: IndirectStorage<T> {
        
        mutating get {
            if !isKnownUniquelyReferenced(&self.storage) {
                self.storage = self.copyStorage()
            }
            return self.storage
        }
    }
    
    /// Returns the last element in the collection
    public var last: T? {
        get {
            return self.storage.tail?.value
        }        
    }
    
    
    
    // MARK: - INITIALIZERS
    
    /// Creates a list with the given node.
    /// NOTE: This method can break value semantics by accepting a node.
    ///
    /// - Parameter head: First node
    internal init(head: SinglyLinkedListNode<T>)
    {
        self.storage = IndirectStorage()
        self.append(node: head)
    }
    
    
    /// Creates a list with a single element
    ///
    /// - Parameter value: element to populate the list with
    public init(value: T)
    {
        let node = SinglyLinkedListNode<T>(value: value)
        self.init(head: node)
    }
    
    
    /// Creates an empty list
    public init()
    {
        self.storage = IndirectStorage()
    }
    
    
    /// Creates a copy of the linked list in a diffent memory location.
    ///
    /// - Returns: The copy to a new storage or a reference to the old one if no copy was necessary.
    private func copyStorage() -> IndirectStorage<T> {
        // If the list is empty, next time an item will be created, it won't affect
        // other instances of the list that came from copies derived from value types.
        // like assignments or parameters
        guard (self.storage.head != nil) && (self.storage.tail != nil) else {
            return IndirectStorage(head: nil, tail: nil)
        }
        
        // Create a new position in memory.
        // Note that we are shallow copying the value. If it was reference type
        // we just make a copy of the reference.
        let copiedHead = SinglyLinkedListNode<T>(value: self.storage.head!.value)
        var previousCopied: SinglyLinkedListNode<T> = copiedHead
        
        // Iterate through current list of nodes and copy them.
        var current: SinglyLinkedListNode<T>? = self.storage.head?.next
        
        while (current != nil) {
            // Create a copy
            let currentCopy = SinglyLinkedListNode<T>(value: current!.value)
            
            // Create links
            previousCopied.next = currentCopy
            
            // Update pointers
            current = current?.next
            previousCopied = currentCopy
        }
        
        return IndirectStorage(head: copiedHead, tail: previousCopied)
    }
    
    
    /// Convenience method to append a value directly to the list
    ///
    /// - Parameter value: value to be added
    public mutating func append(value: T)
    {
        let node = SinglyLinkedListNode<T>(value: value)
        self.append(node: node)
    }
    
    
    /// Appends a new node to the list. This method can easily break value semantics. It is left
    /// for internal use.
    /// - Discussion: If the node to be inserted contains a loop, the node is appended but tail is set to nil.
    ///   This is a private method, therefore this can only happen directly under the control of this class.
    /// - Parameter node: node to be appended. (It can be a list, even contain loops).
    private mutating func append(node: SinglyLinkedListNode<T>)
    {
        if self.storage.tail != nil
        {
            // Copy on write: we are about to modify next a property in
            // a potentially shared node. Make sure it's new if necessary.
            self.storageForWritting.tail?.next = node
            if !self.containsLoop() {
                let (tail, _) = findTail(in: node)
                self.storageForWritting.tail = tail // There
            } else {
                self.storageForWritting.tail = nil
            }
        }
        else
        {
            // This also means that there's no head.
            // Otherwise the state would be inconsistent.
            // This will be checked when adding and deleting nodes.
            self.storageForWritting.head = node
            if !self.containsLoop() {
                let (tail, _) = findTail(in: node)
                self.storageForWritting.tail = tail // There
            } else {
                self.storageForWritting.tail = nil
            }
        }
    }
    
    
    /// Convenience method to prepend a value directly to the list
    ///
    /// - Parameter value: value to be added as the new head of the list
    public mutating func prepend(value: T)
    {
        let node = SinglyLinkedListNode<T>(value: value)
        self.prepend(node: node)
    }
    
    
    /// Adds a new node to the current head. This method can easily break value semantics. It is left
    /// for internal use.
    ///
    /// - Parameter node: the node that will be the new head of the list.
    private mutating func prepend(node: SinglyLinkedListNode<T>)
    {
        let (tailFromNewNode, _) = findTail(in: node)
        tailFromNewNode.next = self.storageForWritting.head
        self.storageForWritting.head = node
        
        if self.storage.tail == nil {
            self.storageForWritting.tail = tailFromNewNode
        }
    }
    
    
    mutating func deleteItem(at index:Int) -> T
    {
        precondition((index >= 0) && (index < self.count))
        
        var previous: SinglyLinkedListNode<T>? = nil
        var current = self.storageForWritting.head
        var i = 0
        var elementToDelete: SinglyLinkedListNode<T>
        
        while (i < index) {
            previous = current
            current = current?.next
            i += 1
        }
        
        // Current is now the element to delete (at index position.tag)
        elementToDelete = current!
        if (self.storage.head === current) {
            self.storageForWritting.head = current?.next
        }
        
        if (self.storage.tail === current) {
            self.storageForWritting.tail = previous
        }
        
        previous?.next = current?.next
        
        return elementToDelete.value
    }
    
    /// This is commented out becuase this solution for finding duplicates uses a set, which would
    /// contrain type T to be hashable, preventing easy types of Linked lists like List<Int> or List<Float>
    /// - Complexity: O(N)
    /// - Abstract: Uses Additional space to keep track of already seen elements
    /*
    public mutating func deleteDuplicates()
    {
        var visited = Set<T>()
        var current = self.head
        var previous: SinglyLinkedListNode<T>? = nil
        
        while (current != nil)
        {
            if (visited.contains((current?.value)!))
            {
                
                if (self.head === current) {
                    self.head = current?.next
                }
                
                if (self.tail === current) {
                    self.tail = previous
                }
                
                // delete current node
                previous?.next = current?.next
                // we don't update the previous
                self.endIndex = SinglyLinkedListIndex<T>(node: nil, tag: (self.endIndex.tag - 1))
            }
            else
            {
                visited.insert((current?.value)!)
                previous = current
            }
            current = current?.next
        }
    }
     */
    
    
    /// Returns the node located at the k-th to last position
    ///
    /// - Parameter kthToLast: 1 <= k <= N
    private func find(kthToLast: UInt, startingAt node: SinglyLinkedListNode<T>?, count: UInt) -> SinglyLinkedListNode<T>?
    {
        guard kthToLast <= count else {
            return nil
        }
        
        guard (node != nil) else {
            return nil
        }
        
        let i = (count - kthToLast)
        
        if (i == 0) {
            return node
        }
        
        return find(kthToLast: kthToLast, startingAt: node?.next, count: (count - 1))
    }
    
    
    /// Returns the kth-to-last element in the list
    ///
    /// - Parameter kthToLast: Reversed ordinal number of the node to fetch.
    public func find(kthToLast: UInt) -> SinglyLinkedListNode<T>?
    {
        return self.find(kthToLast: kthToLast, startingAt: self.storage.head, count: UInt(self.count))
    }


    /// A singly linked list contains a loop if one node references back to a previous node.
    ///
    /// - Returns: Whether the linked list contains a loop
    public func containsLoop() -> Bool
    {
        /// Advances a node at a time
        var current = self.storage.head
        
        /// Advances twice as fast
        var runner = self.storage.head
        
        while (runner != nil) && (runner?.next != nil) {
        
            current = current?.next
            runner = runner?.next?.next
            
            if runner === current {
                return true
            }
        }
        
        return false
    }
}

extension SinglyLinkedList where T: Comparable
{
    /// Deletes node containing a given value
    ///
    /// - Parameter v: value of the node to be deleted.
    mutating func deleteNode(withValue v: T) {
        
        guard self.storage.head != nil else {
            return
        }
        
        var previous: SinglyLinkedListNode<T>? = nil
        var current = self.storage.head
        
        while (current != nil) && (current?.value != v) {
            previous = current
            current = current?.next
        }
        
        if let foundNode = current {
            
            if (self.storage.head === foundNode) {
                self.storageForWritting.head = foundNode.next
            }
            
            if (self.storage.tail === foundNode) {
                self.storage.tail = previous
            }
            
            previous?.next = foundNode.next
            foundNode.next = nil
        }
    }
    
    
    /// Deletes duplicates without using additional structures like a set to keep track the visited nodes.
    /// - Complexity: O(N^2)
    public mutating func deleteDuplicatesInPlace()
    {
        // Copy on write: this updates self.storage if necessary.
        var current = self.storageForWritting.head
        
        while (current != nil)
        {
            var previous: SinglyLinkedListNode<T>? = current
            var next = current?.next
            
            while (next != nil)
            {
                if (current?.value == next?.value) {
                    
                    if (self.storage.head === next) {
                        self.storage.head = next?.next
                    }
                    
                    if (self.storage.tail === next) {
                        self.storage.tail = previous
                    }
                    
                    // Delete next
                    previous?.next = next?.next
                }
                previous = next
                next = next?.next
            }
            current = current?.next
        }
    }
}


public struct SinglyLinkedListForwardIterator<T> : IteratorProtocol {
    
    public typealias Element = T
    
    private(set) var head: SinglyLinkedListNode<T>?
    
    mutating public func next() -> T?
    {
        let result = self.head?.value
        self.head = self.head?.next
        return result
    }
}




// MARK: - SEQUENCE -

extension SinglyLinkedList : Sequence
{
    public func makeIterator() -> SinglyLinkedListForwardIterator<T>
    {
        return SinglyLinkedListForwardIterator(head: self.storage.head)
    }
}


// MARK: - COLLECTION -

extension SinglyLinkedList : Collection {
    
    public typealias Index = SinglyLinkedListIndex<T>
    
    public var startIndex: Index {
        get {
            return SinglyLinkedListIndex<T>(node: self.storage.head, tag: 0)
        }
    }
    
    public var endIndex: Index {
        get {
            if let h = self.storage.head {
                let (_, numberOfElements) = findTail(in: h)
                return SinglyLinkedListIndex<T>(node: h, tag: numberOfElements)
            } else {
                return SinglyLinkedListIndex<T>(node: nil, tag: self.startIndex.tag)
            }
        }
    }
    
    public subscript(position: Index) -> T {
        get {
            return position.node!.value
        }
    }
    
    public func index(after idx: Index) -> Index {
        return SinglyLinkedListIndex<T>(node: idx.node?.next, tag: idx.tag+1)
    }
}


// MARK: - QUEUE -

extension SinglyLinkedList : Queue
{
    typealias Item = T
    
    /// Returns the oldest element in the queue.
    ///
    /// - Returns: The oldest element in the queue. It does not dequeue it.
    func getFirst() -> T? {
        return self.storage.head?.value
    }

    /// Adds an element to the queue
    ///
    /// - Parameter item: Item to be added
    /// - Throws: There are cases where the operation might fail. For example if there is not enough space.
    mutating func enqueue(item: T) throws {        
        self.append(node: SinglyLinkedListNode<T>(value: item))
    }
    
    /// Dequeues the oldest element in the queue.
    ///
    /// - Returns: The oldest element in the queue, which gets removed from it.
    mutating func dequeue() -> T?
    {
        guard self.count > 0 else {
            return nil
        }
        
        return self.deleteItem(at: 0)
    }
}

// MARK: - EXPRESSIBLE-BY-ARRAY-LITERAL -

extension SinglyLinkedList : ExpressibleByArrayLiteral
{
    public typealias Element = T

    public init(arrayLiteral elements: Element...)
    {
        var headSet = false
        var current : SinglyLinkedListNode<T>?
        var numberOfElements = 0
        self.storage = IndirectStorage()
        
        for element in elements {
            
            numberOfElements += 1
            
            if headSet == false {
                self.storage.head = SinglyLinkedListNode<T>(value: element)
                current = self.storage.head
                headSet = true
            } else {
                let newNode = SinglyLinkedListNode<T>(value: element)
                current?.next = newNode
                current = newNode
            }
        }
        self.storage.tail = current
    }
}



// MARK: - FORWARD-INDEX -

public struct SinglyLinkedListIndex<T> : Comparable
{
    fileprivate let node: SinglyLinkedListNode<T>?
    fileprivate let tag: Int
    
    public static func==<T>(lhs: SinglyLinkedListIndex<T>, rhs: SinglyLinkedListIndex<T>) -> Bool {
        return (lhs.tag == rhs.tag)
    }
    
    public static func< <T>(lhs: SinglyLinkedListIndex<T>, rhs: SinglyLinkedListIndex<T>) -> Bool {
        return (lhs.tag < rhs.tag)
    }
}


func findTail<T>(in node: SinglyLinkedListNode<T>) -> (tail: SinglyLinkedListNode<T>, count: Int)
{
    // Assign the tail
    // Note that the passed node can already be linking to other nodes,
    // so the tail needs to be calculated.
    var current: SinglyLinkedListNode<T>? = node
    var count = 1
    
    while (current?.next != nil) {
        current = current?.next
        count += 1
    }
    
    if current != nil {
        return (tail: current!, count: count)
    } else {
        return (tail: node, count: 1)
    }
}
