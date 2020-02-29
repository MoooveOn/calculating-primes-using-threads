
import Foundation
import RIBs

extension ViewableRouter {
    func dismissRIB(_ rib: inout ViewableRouting?,
                    animated: Bool = true,
                    completion: (() -> Void)? = nil) {
        guard let unwrapped = rib else { return }

        rib = nil
        detachChild(unwrapped)
        viewControllable.uiviewController.dismiss(animated: animated,
                                                  completion: completion)
    }

    func presentRIB(_ child: ViewableRouting,
                    animated: Bool = true,
                    completionBlock: (() -> Void)? = nil) -> ViewableRouting? {
        if let presentedViewController = viewControllable.uiviewController.presentedViewController {
            print("⚠️ Error: Unnable to present \(child) because \(viewControllable.uiviewController) alredy presented \(presentedViewController)")
            return nil
        }

        attachChild(child)
        let childViewController = child.viewControllable.uiviewController
        childViewController.modalTransitionStyle = .crossDissolve
        childViewController.modalPresentationStyle = .fullScreen

        viewControllable.uiviewController.present(childViewController,
                                                  animated: animated,
                                                  completion: completionBlock)

        return child
    }
}
