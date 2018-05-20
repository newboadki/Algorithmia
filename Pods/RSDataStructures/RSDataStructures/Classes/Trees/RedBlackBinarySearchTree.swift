//
//  RedBlackBinarySearchTree.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 03/06/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation

public enum RedBlackTreeColor {
    case black
    case red
}

public final class RedBlackBinarySearchTree<T: KeyValuePair> : BinarySearchTree, TraversableBinaryTree {
    
    // MARK: From BinaryTree protocol
    public typealias Item = T
    
    public var leftChild : RedBlackBinarySearchTree<T>?
    
    public var rightChild : RedBlackBinarySearchTree<T>?
    
    public var item : T?
    
    /// TODO: Implement
    public var parent :RedBlackBinarySearchTree<T>?
    
    // MARK: From TrversableTree protocol
    /// Traversable binary trees accept an interator to enumerate its elements.
    /// By default this class provides an in-order iterator.
    public var iterator: AnyIterator<T>?
    
    
    // MARK: Specific to Red Black trees.
    
    /// Number of nodes in the tree
    public fileprivate(set) var count: Int = 0
    
    /// The root is always black
    /// A given node won't have another red parent of child.
    /// All paths from root to leaves have the same number of black nodes
    fileprivate(set) public var color: RedBlackTreeColor
    
    
    // MARK: -  Initializers
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - parent: reference to the parent node
    ///   - leftChild: reference to the  left subtree
    ///   - rightChild: reference to the right subtree
    ///   - value: item contained in the tree node.
    public init(leftChild: RedBlackBinarySearchTree?,
                rightChild: RedBlackBinarySearchTree?,
                value: T,
                color: RedBlackTreeColor) {
        
        self.leftChild = leftChild
        self.rightChild = rightChild
        self.item = value
        self.count = 1
        self.color = color
    }
    
    
    /// Convenience initialiser to create a tree from an array
    ///
    /// - Parameter elements: array literal of keyValue pairs
    public init(arrayLiteral elements: T...)
    {
        var isFirstElement = true
        self.count = 0
        self.color = .black
        
        for element in elements {
            if isFirstElement {
                self.count = 1
                self.item = element
                isFirstElement = false
            } else {
                self.count += 1
                self.insert(item: element)
            }
        }        
    }

    
    /// Add new node to the tree
    ///
    /// - Parameter item: key-value pair that will be inserted into the tree
    /// - Complexity: O(log(N))
    public func insert(item: T) {
        let _ = RedBlackBinarySearchTree.insert(item: item, in: self)
        self.color = .black
    }
    
    private static func insert(item: T, in tree: RedBlackBinarySearchTree<T>?) -> RedBlackBinarySearchTree<T>? {
        
        if tree == nil {
            return RedBlackBinarySearchTree<T>(leftChild: nil, rightChild: nil, value:item, color:.red)
        }
        
        if item < (tree?.item)! {
            tree?.leftChild =  RedBlackBinarySearchTree.insert(item: item, in: tree?.leftChild)
        } else if item > (tree?.item)! {
            tree?.rightChild = RedBlackBinarySearchTree.insert(item: item, in: tree?.rightChild)
        } else {
            tree?.item = item
        }
        
        if (tree?.rightChild?.isRed() ?? false)==true && (tree?.leftChild?.isRed() ?? false)==false {
            RedBlackBinarySearchTree.rotateLeft(tree: tree!)
        }
        
        if (tree?.leftChild?.isRed() ?? false)==true && (tree?.leftChild?.leftChild?.isRed() ?? false)==true {
            RedBlackBinarySearchTree.rotateRight(tree: tree!)
        }

        if (tree?.leftChild?.isRed() ?? false)==true && (tree?.rightChild?.isRed() ?? false)==true {
            RedBlackBinarySearchTree.flipColors(tree: tree!)
        }

        // TODO: UPDATE SIZES
        
        return tree
        
    }
    
    
    public func delete(elementWithKey key: T.K) -> Bool {
        return false
    }

    
    /// Helper method to determine if a node is red
    ///
    /// - Returns: True if the node is red. False otherwise.
    public func isRed() -> Bool {
        return (self.color == .red)
    }

    
    
    // MARK: - TRANSFORMATIONS TO KEEP RED-BLACK PROPERTIES -
    
    private static func rotateLeft(tree: RedBlackBinarySearchTree<T>) {
        let right = tree.rightChild
        
        // Swap items
        let tempItem = tree.item
        tree.item = right?.item
        right?.item = tempItem
        
        tree.rightChild = right?.rightChild
        right?.rightChild = tree.leftChild
        tree.leftChild = right
    }
    
    private static func rotateRight(tree: RedBlackBinarySearchTree<T>){
        let left = tree.leftChild
        let leftLeft = left?.leftChild
        
        // Swap the items
        let tempItem = tree.item
        tree.item = left?.item
        left?.item = tempItem
        
        tree.leftChild = leftLeft
        left?.leftChild = left?.rightChild
        left?.rightChild = tree.rightChild
        
        tree.rightChild = left
    }

    private static func flipColors(tree: RedBlackBinarySearchTree<T>) {
        tree.leftChild?.color = .black
        tree.rightChild?.color = .black
        tree.color = .red
    }

}

// MARK: - EXPRESSIBLE-BY-ARRAY-LITERAL -

extension RedBlackBinarySearchTree : ExpressibleByArrayLiteral
{
    public typealias Element = T
}

