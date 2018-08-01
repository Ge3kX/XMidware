
//
//  Tree.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/2/6.
//

import Foundation



/// tree
final public class Tree {

    public init () {
    }

    var root: TreeNode = TreeNode.init(key: "Root of the tree", value: nil, depth: 0)

    public func buildTree(nodePath: NodePath) {
        guard nodePath.path.count > 0 else {
            return;
        }

        let count = nodePath.path.count

        var currentNode = root

        nodePath.path.enumerated().forEach { (idx, pathName) in

            let node: TreeNode
            if idx == count - 1 {
                node = TreeNode(key: pathName, value: nodePath.value, depth: idx)
            } else {
                node = TreeNode(key: pathName, value: nil, depth: idx)
            }

            currentNode = currentNode.add(child: node)
        }
    }

    public func removeNode(by path: [String]) {
        guard let (_, node) = findNode(by: path) else {
            return
        }
        remove(node: node)
    }

    func remove(node: TreeNode) {

        // make it nil
        node.set(value: nil)

        guard node.childs.count == 0 else {
            // has child, stop remove
            return
        }

        // remove self from parent
        guard let parent = node.parent else {
            return;
        }

        parent.childs.removeValue(forKey: node.key)

        // if parent is not ending node, remove it
        guard !parent.isEndingNode else {
            return;
        }

        remove(node: parent)

    }

    public func findNode(by path: [String]) -> ([String:String], TreeNode)? {

        var currentNode = root

        var params = [String : String]()
        var final: TreeNode? = nil

        let count = path.count

        for (idx, ele) in path.enumerated() {

            if let existsNode = currentNode.childs[ele] {
                currentNode = existsNode
            }
            else if currentNode.childs.count > 0 && currentNode.childs.first!.value.isPlaceholder {
                currentNode = currentNode.childs.first!.value
                params[currentNode.realKey] = ele
            }
            else {
                return nil;
            }

            if idx == count - 1 {

                if let _: Any = currentNode.getValue() {
                    final = currentNode
                } else {
                    return nil
                }
            }
        }

        if let final = final {
            return (params, final)
        } else {
            return nil;
        }

    }

}

extension Tree : CustomStringConvertible {

    public var description: String {
        return "\n\(root)"
    }
}


/// tree node
final public class TreeNode {

    // MARK: - Constructor
    init(key: String, value: Any? = nil, depth: Int = 0) {
        self.key = key
        self.nodeValue = value
        self.depth = depth
    }

    fileprivate weak var parent: TreeNode?

    /// holding value
    private var nodeValue: Any?

    public let depth: Int

    // MARK: - Property
    /// child map
    public fileprivate(set) var childs = [String : TreeNode]()

    /// node key
    fileprivate var key: String

    /// if this node is ending and hold a value
    public var isEndingNode: Bool {
        return nodeValue != nil
    }

    /// if this node is placeholder
    public var isPlaceholder: Bool {
        return key.hasPrefix(":")
    }

    /// get real key
    var realKey: String {
        if isPlaceholder {
            return String(key[key.index(after: key.startIndex)...])
        } else {
            return key
        }
    }

    var isRoot: Bool {
        return parent == nil
    }

    // MARK: - Methods

    func set(value: Any?) {
        self.nodeValue = value
    }

    public func getValue<Value>() -> Value? {
        return self.nodeValue as? Value
    }

    /// add a child to current node
    ///
    /// - Parameter child: child node
    /// - Returns: return the child node instance that has build in the child list
    public func add(child: TreeNode) -> TreeNode {

        // place holder node checking
        if let existsNode = childs.first?.value {
            if existsNode.isPlaceholder {
                assert(child.key == childs.first!.value.key, "place holder can node must be only one")
            }
        }

        // place holder node checking
        if child.isPlaceholder {
            if let existsNode = childs.first?.value {
                assert(child.key == existsNode.key, "place holder can node must be only one")
            }
        }

        // add node
        let treeNode: TreeNode
        if let existsNode = childs[child.key] {
            if child.isEndingNode {
                if let _: Any = existsNode.getValue() {
                    print("error: multiple ending: \(existsNode.getPathToRoot())!!!!")
                    fatalError()
                }
                existsNode.set(value: child.getValue())
            }
            treeNode = existsNode
        } else {
            childs[child.key] = child
            treeNode = child
        }

        treeNode.parent = self

        return treeNode
    }

    func getPathToRoot() -> [String] {
        var paths = [String]()
        var current = self
        while current.parent != nil {
            paths.insert(current.key, at: 0)
            current = current.parent!
        }
        return paths
    }
}

extension TreeNode : CustomStringConvertible {

    public var description: String {

        var prefix = ""
        if depth > 0 {
            prefix = "|"
            for _ in 0..<depth {
                prefix.append("---")
            }
        }

        var string = "\(prefix)[\(key)]"
        if isEndingNode && !isRoot {
            string.append(" (\(getValue()! as Any))")
        }
        childs.enumerated().forEach { (idx, entry) in
            string.append("\n\(entry.value)")
        }
        return string
    }
}


public struct NodePath {

    public let path: [String]

    public let value: Any

    public init(path: [String], value: Any) {
        self.path = path
        self.value = value
    }


}







