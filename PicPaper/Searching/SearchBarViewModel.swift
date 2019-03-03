//
//  SearchBarViewModel.swift
//  PicPaper
//
//  Created by Arlindo on 2/24/19.
//  Copyright © 2019 DevByArlindo. All rights reserved.
//

import RxSwift
import RxCocoa

enum SearchBarStatus {
    case active, inactive
}

class SearchBarViewModel {
    private struct Constants {
        static let textFieldPlaceholder: String = "Look something up!"
    }
    private let trashBag = DisposeBag()

    private let status = BehaviorRelay<SearchBarStatus>(value: .inactive)

    private let searchInput = BehaviorRelay<String?>(value: nil)

    var currentStatus: SearchBarStatus {
        return status.value
    }

    var currentStatusDriver: Driver<SearchBarStatus> {
        return status.asDriver()
    }

    var currentInputPlaceHolder: Driver<String?> {
        return currentStatusDriver.map { status in
            switch status {
            case .active:
                return Constants.textFieldPlaceholder
            case .inactive:
                return nil
            }
        }
    }

    var currentInputText: Driver<String?> {
        return Driver.combineLatest(currentStatusDriver, searchInput.asDriver())
            .map { status, input in
                switch status {
                case .active:
                    return input
                case .inactive:
                    return nil
                }
            }
    }

    var currentSearchTerm: Observable<String?> {
        return searchInput.asObservable()
    }

    func setupKeyboardObserver(takeUntilObserver: Observable<[Any]>) {
        _ = Keyboard.shared.currentStatus.asObservable()
            .takeUntil(takeUntilObserver)
            .filter { $0 == .willHide }
            .subscribe(onNext: { [unowned self] _ in
                if self.currentStatus != .inactive {
                    self.status.accept(.inactive)
                }
            })
    }

    func search(input: String?) {
        let savedStatus = currentStatus
        toggleStatus()
        if savedStatus == .active {
            performSearch(input: input)
        }
    }

    func clear() {
        searchInput.accept(nil)
    }

    private func performSearch(input: String?) {
        guard
            let searchTerm = input,
            !searchTerm.isEmpty,
            searchInput.value != searchTerm
            else { return }

        // Kicks off search request
        searchInput.accept(input)
    }

    @objc func toggleStatus() {
        switch status.value {
        case .active:
            return status.accept(.inactive)
        case .inactive:
            return status.accept(.active)
        }
    }
}
