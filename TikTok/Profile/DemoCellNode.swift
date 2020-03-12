//
//  DemoCellNode.swift
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

import UIKit
import AsyncDisplayKit

class DemoCellNode: ASCellNode {
    let childA = ASDisplayNode()
    let childB = ASDisplayNode()
    var state = State.Right

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let specA = ASRatioLayoutSpec(ratio: 1, child: childA)
        specA.style.flexBasis = ASDimensionMakeWithPoints(1)
        specA.style.flexGrow = 1.0
        let specB = ASRatioLayoutSpec(ratio: 1, child: childB)
        specB.style.flexBasis = ASDimensionMakeWithPoints(1)
        specB.style.flexGrow = 1.0
        let children = state.isReverse ? [ specB, specA ] : [ specA, specB ]
        let direction: ASStackLayoutDirection = state.isVertical ? .vertical : .horizontal
        return ASStackLayoutSpec(direction: direction,
            spacing: 20,
            justifyContent: .spaceAround,
            alignItems: .center,
            children: children)
    }

    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        childA.frame = context.initialFrame(for: childA)
        childB.frame = context.initialFrame(for: childB)
        let tinyDelay = drand48() / 10
        UIView.animate(withDuration: 0.5, delay: tinyDelay, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5, options: .beginFromCurrentState, animations: { () -> Void in
            self.childA.frame = context.finalFrame(for: self.childA)
            self.childB.frame = context.finalFrame(for: self.childB)
            }, completion: {
                context.completeTransition($0)
        })
    }

    enum State {
        case Right
        case Up
        case Left
        case Down

        var isVertical: Bool {
            switch self {
            case .Up, .Down:
                return true
            default:
                return false
            }
        }

        var isReverse: Bool {
            switch self {
            case .Left, .Up:
                return true
            default:
                return false
            }
        }

        mutating func advance() {
            switch self {
            case .Right:
                self = .Up
            case .Up:
                self = .Left
            case .Left:
                self = .Down
            case .Down:
                self = .Right
            }
        }
    }
}
