//
//  OverlayWindow.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/6/10.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import SnapKit
import UIKit

protocol OverlayWindowDelegate: AnyObject {
    func overlayWindow(_ window: OverlayWindow, didReceiveEvent event: OverlayWindow.Event)
}

class OverlayWindow: UIWindow {
    enum Event {
        case done
    }

    private lazy var overlayView: UIView = {
        if #available(iOS 13, *) {
            let view =  UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))

            view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
            view.alpha = 0.6

            return view
        } else {
            let view = UIView()

            view.backgroundColor = .black
            view.alpha = 0.8

            return view
        }
    }()

    private lazy var hintView: HintView = {
        let view = HintView()

        return view
    }()

    var hint: Hint? {
        didSet {
            hintView.title = hint?.title
            hintView.subtitle = hint?.subtitle
        }
    }

    weak var delegate: OverlayWindowDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    @available(iOS 13.0, *)
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)

        backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        windowLevel = .alert + 1

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapDismiss(_:)))
        addGestureRecognizer(tapGestureRecognizer)

        addSubview(overlayView)
        addSubview(hintView)

        hintView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(self.safeAreaLayoutGuide)
            $0.bottom.lessThanOrEqualTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.top.equalTo(0).priority(.medium)
        }

        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // WORKAROUND: iOS 12 will not layout at the first time `showHint(_:_:)` is invoked.
        self.layoutIfNeeded()
    }

    @objc private func didTapDismiss(_ sender: UITapGestureRecognizer) {
        logger.info("didTapDismiss OverlayWindow")
        delegate?.overlayWindow(self, didReceiveEvent: .done)
    }

    func showHint(_ hint: Hint, from sourceRect: CGRect) {
        self.hint = hint

        let path = UIBezierPath(roundedRect: overlayView.frame,
                                cornerRadius: 0)
        let spot = UIBezierPath(roundedRect: CGRect(x: sourceRect.origin.x - 8,
                                                    y: sourceRect.origin.y - 8,
                                                    width: sourceRect.size.width + 16,
                                                    height: sourceRect.size.height + 16),
                                cornerRadius: 8)

        path.append(spot)
        path.usesEvenOddFillRule = true

        overlayView.layer.mask = {
            let maskLayer = CAShapeLayer()

            maskLayer.path = path.cgPath
            maskLayer.fillRule = .evenOdd

            return maskLayer
        }()

        hintView.snp.updateConstraints {
            $0.top.equalTo(sourceRect.maxY + 18).priority(.medium)
        }

        let sourceRectCenter = CGPoint(x: (sourceRect.maxX + sourceRect.minX) / 2.0,
                                       y: (sourceRect.maxY + sourceRect.minY) / 2.0)
        hintView.arrowPosition = hintView.convert(sourceRectCenter, from: self).x + hintView.frame.origin.x
    }
}
