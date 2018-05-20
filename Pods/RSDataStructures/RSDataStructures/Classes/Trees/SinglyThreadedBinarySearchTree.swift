//
//  SinglyThreadedBinaryTree.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 18/05/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation



/// This tree is a BinaryTree & Collection but not a TraversableBinaryTree, 
/// becuase its internal implementation does not allow
/// all arbitraty traversal algorithms. Some would not work. 
/// Therefore it is this class that defines the different supported traversal algorithms.
public final class SinglyThreadedBinarySearchTree<T : KeyValuePair> : BinarySearchTree {
    
    public typealias Item = T
    
    public weak var parent : SinglyThreadedBinarySearchTree<T>?
    
    public var leftChild : SinglyThreadedBinarySearchTree<T>?
    
    public var rightChild : SinglyThreadedBinarySearchTree<T>?
    
    public var item : T?
    
    /// Traversable binary trees accept an interator to enumerate its elements.
    /// By default this class provides an in-order iterator.
    public var iterator: AnyIterator<T>?
    
    public private(set) var count: Int
    
    /// Keeps a reference to the node, in this node's subtree, containing the minimum value. 
    /// Becuase we only need to potentialy update the minimum during insertion, deletion and edition, we can
    /// efficiently keep a reference that would prevent a search
    /// - Complexity: O(1)
    fileprivate var minNode: SinglyThreadedBinarySearchTree<T>?
    
    /// Reference to the next node according to the explicit order defined by the internals of this class
    fileprivate var successor : SinglyThreadedBinarySearchTree<T>?

    
    // MARK: -  Initializers
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - parent: reference to the parent node
    ///   - leftChild: reference to the  left subtree
    ///   - rightChild: reference to the right subtree
    ///   - value: item contained in the tree node.
    public init(parent: SinglyThreadedBinarySearchTree?,
         leftChild: SinglyThreadedBinarySearchTree?,
         rightChild: SinglyThreadedBinarySearchTree?,
         value:T) {
        
        self.parent = parent
        self.leftChild = leftChild
        self.rightChild = rightChild
        self.item = value
        self.count = 1
        self.minNode = self
        self.successor = nil
        self.iterator = self.defaultIterator(tree:self)
    }
    
    
    
    /// - Parameter elements: non-empty array literal
    /// - Discussion: This method has the precondition of the array literal not being empty.
    public init(arrayLiteral elements: T...)
    {        
        precondition(elements.count > 0)
        
        var isFirstElement = true
        self.count = 0
        
        
        for element in elements {
            if isFirstElement {
                self.count = 1
                self.item = element
                self.minNode = self
                isFirstElement = false
            } else {
                self.count += 1
                self.insert(item: element)
            }
        }
        
        self.iterator = self.defaultIterator(tree:self)
    }
    
    
    /// Adds an item to the tree structure
    ///
    /// - Parameter item: Item to be added
    /// - Complexity: O(log(N))
    public func insert(item: T) {
        
        // If the tree is empty, just assign the root's value
        guard (!self.isEmpty) else {
            self.item = item.copy()
            return
        }

        // If the values are the same, ignore
        guard  (self.item != item) else {
            return
        }
        
        if item < self.item! {
            if let lc = self.leftChild {
                lc.insert(item: item)
            } else {
                let newNode = SinglyThreadedBinarySearchTree<T>(parent: self, leftChild: nil, rightChild: nil, value: item)
                self.leftChild = newNode
                newNode.successor = self
                self.updateMinimum(newCandidate: newNode)
                self.count += 1
                self.propagateCount(startingFrom: self.parent)
            }
        } else {
            if let rc = self.rightChild, self.successor==nil {
                rc.insert(item: item)
            } else {
                let newNode = SinglyThreadedBinarySearchTree<T>(parent: self, leftChild: nil, rightChild: nil, value: item)
                
                if self.successor != nil {
                    newNode.successor = self.successor
                    self.successor = nil
                } else {
                    newNode.successor = nil
                }
                self.rightChild = newNode
                self.updateMinimum(newCandidate: newNode)
                self.count += 1
                self.propagateCount(startingFrom: self.parent)
                
            }
        }
    }

    public func delete(elementWithKey key: T.K) -> Bool {
        
        // If the tree is empty, there's nothing to delete
        guard !self.isEmpty else {
            return false
        }
        
        if let nodeToBeDeleted = self.search(key: key) {
         
            if ((nodeToBeDeleted.successor == nil) &&
                (nodeToBeDeleted.leftChild != nil) &&
                (nodeToBeDeleted.rightChild != nil)) {
                // TWO CHILDREN
                let minimumFromRightBranch: SinglyThreadedBinarySearchTree<T>! = nodeToBeDeleted.rightChild?.minimum()
                
                // In this case we are not deleting the physical node but replacingthe values in
                // the node to be deleted by the values in the minimum from the right branch.be
                nodeToBeDeleted.item!.key = minimumFromRightBranch.item!.key
                nodeToBeDeleted.item!.value = minimumFromRightBranch.item!.value
                
                // Delete the minimum from the right branch
                _ = minimumFromRightBranch.delete(elementWithKey:minimumFromRightBranch.item!.key)
                
            } else if (nodeToBeDeleted.leftChild != nil) {
                // ONE LEFT CHILD
                replace(element: nodeToBeDeleted, with: nodeToBeDeleted.leftChild)
                
            } else if ((nodeToBeDeleted.successor == nil) && (nodeToBeDeleted.rightChild != nil)) {
                // ONE RIGHT CHILD
                replace(element: nodeToBeDeleted, with: nodeToBeDeleted.rightChild)
                
            } else {
                // NO CHILDREN, CHECK WHAT THE RIGHT REF. IS BEING USED FOR.
                replace(element: nodeToBeDeleted, with: nil)
            }
            return true
            
        } else {
            return false
        }
    }
    
    private func replace(element existingElement: SinglyThreadedBinarySearchTree<T>, with newElement: SinglyThreadedBinarySearchTree<T>?) {
        
        if let parent = existingElement.parent {
            
            if existingElement === parent.leftChild {
                parent.leftChild = newElement

            } else if existingElement === parent.rightChild {
                if existingElement.successor == nil {
                    parent.rightChild = newElement
                }                
            }
            
            if let ne = newElement {
                ne.parent = parent
            }
            
            if existingElement.successor != nil  {
                
                if let ne = newElement {
                    let maximumNodeOfSubtree = ne.maximum()
                    ne.successor = existingElement.successor
                    ne.rightChild = nil
                    maximumNodeOfSubtree?.rightChild = existingElement.rightChild // Assuming here that the tree is weel-constructed and that the maximum of any subtree has

                } else if existingElement.parent?.rightChild === existingElement {
                    existingElement.parent?.successor = existingElement.successor
                    existingElement.parent?.rightChild = nil
                }
            }

            // If we are deleting the minimum, find a new one and propagate it upwards
            if existingElement.minNode === existingElement {
                if let ne = newElement {
                    // the new element replacing the min is the new minimum
                    ne.minNode = ne
                    propagateMinimum(startingFrom: ne)
                } else {
                    parent.minNode = parent
                    propagateMinimum(startingFrom: parent)
                }
            }
            
            existingElement.decrementCountByOne(startingFrom: existingElement.parent)
            existingElement.leftChild = nil
            existingElement.rightChild = nil
            existingElement.parent = nil
            existingElement.minNode = nil
            
        } else {
            // REPLACING THE ROOT
            if let ne = newElement {
                existingElement.item!.key = ne.item!.key
                existingElement.item!.value = ne.item!.value
                existingElement.leftChild = ne.leftChild
                existingElement.rightChild = ne.rightChild
                
                ne.leftChild?.parent = existingElement
                ne.rightChild?.parent = existingElement
                ne.count = (existingElement.count - 1)
                
            } else {
                // We are destroying the root
                existingElement.item = nil
                existingElement.leftChild = nil
                existingElement.rightChild = nil
                existingElement.minNode = nil
                existingElement.count = 0
            }
        }
    }
    
    /// Maximum element
    ///
    /// - Returns: The right most leave of the tree, which has the maximum value as its node's key
    /// - Complexity: O(log N), with N being the number of nodes in the tree.
    public func maximum() -> SinglyThreadedBinarySearchTree<T>? {
        
        var max = self
        while (max.rightChild != nil && max.successor == nil) {
            max = max.rightChild!
        }
        
        return max
    }
    
    private func updateMinimum(newCandidate: SinglyThreadedBinarySearchTree<T>) {
        if newCandidate.item! < (self.minNode?.item)! {
            self.minNode = newCandidate
            propagateMinimum(startingFrom: self.minNode!)
        }
    }
    
    
    /// In order to return the minimum in Order O(1), this class keeps track of it after every insertion
    /// or deletion. But, once the minimum changes we might need to update its uncestors.
    /// - Parameter node: <#node description#>
    private func propagateMinimum(startingFrom node: SinglyThreadedBinarySearchTree<T>) {
        var current: SinglyThreadedBinarySearchTree<T>? = node
        
        // Current is left child
        while current?.parent?.leftChild === current {
            current?.parent?.minNode = current?.minNode
            current = current?.parent
        }
    }
    
    private func propagateCount(startingFrom node: SinglyThreadedBinarySearchTree<T>?) {
        
        var current: SinglyThreadedBinarySearchTree<T>? = node
        
        // Current is left child
        while current != nil {
            current?.count += 1
            current = current?.parent
        }
    }

    private func decrementCountByOne(startingFrom node: SinglyThreadedBinarySearchTree<T>?) {
        
        var current: SinglyThreadedBinarySearchTree<T>? = node
        
        // Current is left child
        while current != nil {
            current?.count -= 1
            current = current?.parent
        }
    }

    
    fileprivate func next(after node: SinglyThreadedBinarySearchTree<T>) -> SinglyThreadedBinarySearchTree<T>? {
        
        var current: SinglyThreadedBinarySearchTree<T>? = node
        
        if current!.successor != nil {
            current = current!.successor
        } else {
            current = current!.rightChild?.minimum()
        }

        return current
    }
    
    
    
    /// Default in-order iterator
    ///
    /// - Parameter tree: Tree to be iterated through
    /// - Returns: An iterator for the given tree
    /// - Complexity: O(n)
    fileprivate func defaultIterator(tree: SinglyThreadedBinarySearchTree<T>) -> AnyIterator<T> {
        
        var current: SinglyThreadedBinarySearchTree<T>?
        var minimumBeenFound = false
        
        return AnyIterator {
            if minimumBeenFound == false {
                current = tree.minNode
                minimumBeenFound = true
            }
            
            let result = current
            
            if current?.successor != nil {
                current = current!.successor
                
            } else if current?.rightChild != nil {
                current = current!.rightChild?.minimum()
                
            } else {
                current = nil
            }
            
            
            return result?.item
        }
    }
}



public struct SinglyThreadedBinaryTreeIndex<T:KeyValuePair> : Comparable
{
    fileprivate let node: SinglyThreadedBinarySearchTree<T>?
    fileprivate let tag: Int
    
    public static func ==(lhs: SinglyThreadedBinaryTreeIndex<T>, rhs: SinglyThreadedBinaryTreeIndex<T>) -> Bool {
        return (lhs.tag == rhs.tag)
    }
    
    public static func <(lhs: SinglyThreadedBinaryTreeIndex<T>, rhs: SinglyThreadedBinaryTreeIndex<T>) -> Bool {
        return (lhs.tag < rhs.tag)
    }
}


extension SinglyThreadedBinarySearchTree : Collection {
    
    public typealias Index = SinglyThreadedBinaryTreeIndex<T>
    
    /// - Complexity: O(1)
    public var startIndex: Index {
        get {
            return SinglyThreadedBinaryTreeIndex<T>(node: self.minNode, tag: 0)
        }
    }
    
    
    /// - Complexity: O(1)
    public var endIndex: Index {
        get {
            return SinglyThreadedBinaryTreeIndex<T>(node: nil, tag: self.count)
        }
    }
    
    public subscript(position: Index) -> T {
        get {
            return position.node!.item!
        }
    }
    
    public func index(after idx: Index) -> Index {
        return SinglyThreadedBinaryTreeIndex<T>(node: self.next(after: idx.node!), tag: idx.tag+1)
    }
    
}



// MARK: - TRAVERSABLE TREE -

extension SinglyThreadedBinarySearchTree : TraversableBinaryTree {

    /// - Discussion: Having to re-define becuase there's ambiguity between the TraversableBinaryTree extension 
    ///   and the Collection extension to define the default indexingIterator
    public func makeIterator() -> AnyIterator<T> {
        return self.iterator!
    }

}




// MARK: - EXPRESSIBLE-BY-ARRAY-LITERAL -

extension SinglyThreadedBinarySearchTree : ExpressibleByArrayLiteral
{
    public typealias Element = T
}

