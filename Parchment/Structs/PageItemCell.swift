import UIKit
import Foundation

@available(iOS 13.0, *)
final class PageItemCell: PagingCell {
    private var item: PageItem!
    private var options: PagingOptions?
    private var itemSelected: Bool = false
    private var hostingController: UIViewController?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if hostingController?.parent == nil {
            addHostingController()
        }
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        guard let hostingController else { return .zero }

        return hostingController.view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .defaultLow
        )
    }

    override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
        item = pagingItem as? PageItem
        self.options = options
        self.itemSelected = selected

        if let hostingController = hostingController {
            let state = PageState(progress: selected ? 1 : 0, isSelected: selected)
            item.page.header(options, state, hostingController)
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? PagingCellLayoutAttributes {
            if let hostingController, let options {
                let state = PageState(progress: attributes.progress, isSelected: itemSelected)
                item.page.header(options, state, hostingController)
            }
        }
    }

    private func addHostingController() {
        if let item = item,
           let options = options,
           let parentViewController = parentViewController() {
            let viewController = item.page.headerHostingController(options)
            viewController.view.backgroundColor = options.backgroundColor
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewController.view.frame = contentView.bounds
            contentView.addSubview(viewController.view)
            parentViewController.addChild(viewController)
            viewController.didMove(toParent: parentViewController)
            hostingController = viewController

            let state = PageState(progress: itemSelected ? 1 : 0, isSelected: itemSelected)
            item.page.header(options, state, viewController)
        }
    }

    private func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
