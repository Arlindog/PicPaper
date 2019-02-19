//
//  UIResponder+Rx.swift
//  PicPaper
//
//  Created by Arlindo on 2/24/19.
//  Copyright © 2019 DevByArlindo. All rights reserved.
//

import RxSwift
import RxCocoa

enum KeyboardStatus {
    case idle, willShow, didShow, willHide, didHide

    var isShowing: Bool {
        return self == .didShow
    }
}

struct Keyboard {
    static let shared = Keyboard()

    private let trashBag = DisposeBag()

    private let status = BehaviorRelay<KeyboardStatus>(value: .idle)

    var currentStatus: Driver<KeyboardStatus> {
        return status.asDriver()
    }

    var isShowing: Bool {
        return status.value.isShowing
    }

    private init() {
        setup()
    }

    private func setup() {
        UIResponder.rx.keyboardWillShow
            .map { _ in KeyboardStatus.willShow }
            .bind(to: status)
            .disposed(by: trashBag)

        UIResponder.rx.keyboardDidShow
            .map { _ in KeyboardStatus.didShow }
            .bind(to: status)
            .disposed(by: trashBag)

        UIResponder.rx.keyboardWillHide
            .map { _ in KeyboardStatus.willHide }
            .bind(to: status)
            .disposed(by: trashBag)

        UIResponder.rx.keyboardDidHide
            .map { _ in KeyboardStatus.didHide }
            .bind(to: status)
            .disposed(by: trashBag)
    }
}

extension Reactive where Base: UIResponder {

    public static var keyboardWillShow: Observable<Notification> {
        return NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
    }

    public static var keyboardDidShow: Observable<Notification> {
        return NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification)
    }

    public static var keyboardWillHide: Observable<Notification> {
        return NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
    }

    public static var keyboardDidHide: Observable<Notification> {
        return NotificationCenter.default.rx.notification(UIResponder.keyboardDidHideNotification)
    }
}
