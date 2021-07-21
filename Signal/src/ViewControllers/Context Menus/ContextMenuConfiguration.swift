//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

typealias ContextMenuActionHandler = (ContextMenuAction) -> Void

// UIAction analog
class ContextMenuAction {

    public struct Attributes: OptionSet {
        public let rawValue: UInt

        public static let disabled = ContextMenuAction.Attributes(rawValue: 1 << 0)
        public static let destructive = ContextMenuAction.Attributes(rawValue: 1 << 1)
        public static let hidden = ContextMenuAction.Attributes(rawValue: 1 << 2)
    }

    public let title: String
    public let image: UIImage?
    public let attributes: Attributes

    private let handler: ContextMenuActionHandler

    public init (
        title: String = "",
        image: UIImage? = nil,
        attributes: ContextMenuAction.Attributes = [],
        handler: @escaping ContextMenuActionHandler
    ) {
        self.title = title
        self.image = image
        self.attributes = attributes
        self.handler = handler
    }

}

/// UIMenu analog, supports single depth menus only
class ContextMenu {
    public let children: [ContextMenuAction] = []
}

protocol ContextMenuTargetedPreviewAccessoryInteractionDelegate: AnyObject {
    func contextMenuTargetedPreviewAccessoryRequestsDismissal(_ accessory: ContextMenuTargetedPreviewAccessory)
    func contextMenuTargetedPreviewAccessoryRequestsEmojiPicker(_ accessory: ContextMenuTargetedPreviewAccessory, completion: @escaping (String) -> Void)
}

/// Encapsulates an accessory view with relevant layout information
public class ContextMenuTargetedPreviewAccessory {

    public struct AccessoryAlignment {
        public enum Edge {
            case top
            case trailing
            case leading
            case bottom
        }

        public enum Origin {
            case interior
            case exterior
        }

        /// Accessory frame edge alignment relative to preview frame.
        /// Processed in-order
        let alignments: [(Edge, Origin)]
        let alignmentOffset: CGPoint
    }

    /// Accessory view
    var accessoryView: UIView

    // Defines accessory layout relative to preview view
    var accessoryAlignment: AccessoryAlignment

    weak var delegate: ContextMenuTargetedPreviewAccessoryInteractionDelegate?

    init(
        accessoryView: UIView,
        accessoryAlignment: AccessoryAlignment
    ) {
        self.accessoryView = accessoryView
        self.accessoryAlignment = accessoryAlignment
    }

    func animateIn(
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        completion()
    }

    func animateOut(
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        completion()
    }
}

// UITargetedPreview analog
// Supports snapshotting from target view only, and animating to/from the same target position
// View must be in a window when ContextMenuTargetedPreview is initialized
public class ContextMenuTargetedPreview {

    public let view: UIView?
    public let snapshot: UIView?
    public let accessoryViews: [ContextMenuTargetedPreviewAccessory]

    private var previewFrame: CGRect = CGRect.zero

    /// Default targeted preview initializer
    /// View must be in a window
    /// - Parameters:
    ///   - view: View to render preview of
    ///   - accessoryViews: accessory view
    public init (
        view: UIView,
        accessoryViews: [ContextMenuTargetedPreviewAccessory]?
    ) {
        AssertIsOnMainThread()
        owsAssertDebug(view.window != nil, "View must be in a window")
        self.view = view

        if let snapshot = view.snapshotView(afterScreenUpdates: false) {
            self.snapshot = snapshot
        } else {
            self.snapshot = nil
            owsFailDebug("Unable to snapshot context menu preview view")
        }

        self.accessoryViews = accessoryViews ?? []
    }

    /// Chat History View optimized initializer, takes a pre-snapshotted replicant view vs an original view
    /// View does not need to be in a window
    /// - Parameters:
    ///   - snapshot: snapshot view
    ///   - accessoryViews: accessory views
    public init (
        snapshot: UIView,
        accessoryViews: [ContextMenuTargetedPreviewAccessory]?
    ) {
        AssertIsOnMainThread()
        self.snapshot = snapshot
        self.view = nil
        self.accessoryViews = accessoryViews ?? []
    }
}

typealias ContextMenuActionProvider = ([ContextMenuAction]) -> ContextMenu?

// UIContextMenuConfiguration analog
class ContextMenuConfiguration {
    public let identifier: NSCopying
    private let actionProvider: ContextMenuActionProvider?

    public init (
        identifier: NSCopying?,
        actionProvider: ContextMenuActionProvider?
    ) {
        if let ident = identifier {
            self.identifier = ident
        } else {
            self.identifier = UUID() as NSCopying
        }

        self.actionProvider = actionProvider
    }
}
