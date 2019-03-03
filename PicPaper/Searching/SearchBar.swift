//
//  SearchBar.swift
//  PicPaper
//
//  Created by Arlindo on 2/24/19.
//  Copyright © 2019 DevByArlindo. All rights reserved.
//

import RxSwift
import RxCocoa

class SearchBar: UIView, UITextFieldDelegate {
    private struct Constants {
        static let defaultBarHeight: CGFloat = 40
        static let barAnimationDuration: TimeInterval = 0.3
        static let textFieldFontSize: CGFloat = 17
        static let textFieldInputPadding: CGFloat = 2
        static let toolBarHeight: CGFloat = 30
    }

    let viewModel = SearchBarViewModel()
    private let trashBag = DisposeBag()

    private lazy var inputTextField: SearchTextField = {
        let textField = SearchTextField(padding: UIEdgeInsets(top: 0, left: barHeight + Constants.textFieldInputPadding, bottom: 0, right: barHeight + Constants.textFieldInputPadding))
        textField.delegate = self
        textField.returnKeyType = .done
        textField.clipsToBounds = true
        textField.backgroundColor = Colors.DarkTheme.primary
        textField.font = UIFont.systemFont(ofSize: Constants.textFieldFontSize, weight: .heavy)
        textField.textColor = .white
        textField.textAlignment = .center
        textField.tintColor = .white
        return textField
    }()

    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Colors.DarkTheme.primary
        button.setImage(#imageLiteral(resourceName: "search"), for: .normal)
        button.tintColor = .white
        return button
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Colors.DarkTheme.primary
        button.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        button.tintColor = .white
        return button
    }()

    private var inputTextFieldFrame: CGRect {
        switch viewModel.currentStatus {
        case .active:
            return CGRect(x: 0, y: 0, width: bounds.width, height: barHeight)
        case .inactive:
            return CGRect(x: 0, y: 0, width: barHeight, height: barHeight)
        }
    }

    private var searchButtonFrame: CGRect {
        switch viewModel.currentStatus {
        case .active:
            return CGRect(x: bounds.width - barHeight, y: 0, width: barHeight, height: barHeight)
        case .inactive:
            return CGRect(x: 0, y: 0, width: barHeight, height: barHeight)
        }
    }

    private var closeButtonFrame: CGRect {
        let height = bounds.height * 2/3
        let centerPoint = bounds.height / 6
        return CGRect(x: centerPoint, y: centerPoint, width: height, height: height)
    }

    private let barHeight: CGFloat

    init(barHeight: CGFloat = Constants.defaultBarHeight) {
        self.barHeight = barHeight
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Must use init(barHeight:)")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        searchButton.layer.cornerRadius = bounds.height / 2
        inputTextField.layer.cornerRadius = bounds.height / 2
        closeButton.layer.cornerRadius = bounds.height / 2
        inputTextField.frame = inputTextFieldFrame
        searchButton.frame = searchButtonFrame
        closeButton.frame = closeButtonFrame
    }

    private func setup() {
        clipsToBounds = true

        addSubview(inputTextField)
        addSubview(closeButton)
        addSubview(searchButton)

        setupTextField()
        setupToolBar()

        viewModel.currentStatusDriver
            // skips the inital value to not animate the initial position
            .skip(1)
            .map { $0 == .active }
            .drive(onNext: statusChanged)
            .disposed(by: trashBag)

        searchButton.rx.tap
            .map { [unowned self] in self.inputTextField.text }
            .bind(onNext: viewModel.search)
            .disposed(by: trashBag)

        closeButton.rx.tap
            .bind(onNext: viewModel.toggleStatus)
            .disposed(by: trashBag)
    }

    private func setupTextField() {
        viewModel.currentInputPlaceHolder
            .map { placeholder -> NSAttributedString? in
                guard let placeholder = placeholder else { return nil }
                return NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.lightGray])
            }
            .drive(inputTextField.rx.attributedPlaceholder)
            .disposed(by: trashBag)

        viewModel.currentInputText
            .drive(inputTextField.rx.text)
            .disposed(by: trashBag)
    }

    private func setupToolBar() {
        let toolBar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Constants.toolBarHeight))
        toolBar.barTintColor = Colors.DarkTheme.primary
        toolBar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let clearButton = UIBarButtonItem(title: "Clear", style: .done, target: self, action: #selector(self.clearInput))
        clearButton.tintColor = .white

        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: viewModel, action: #selector(viewModel.toggleStatus))
        closeButton.tintColor = .white

        toolBar.items = [clearButton, flexSpace, closeButton]
        toolBar.sizeToFit()
        inputTextField.inputAccessoryView = toolBar
    }

    func clear() {
        viewModel.clear()
    }

    private func statusChanged(isActive: Bool) {
        animateConstraints()

        if isActive {
            inputTextField.becomeFirstResponder()
        } else if Keyboard.shared.isShowing {
            inputTextField.resignFirstResponder()
        }
    }

    private func animateConstraints() {
        UIView.animate(withDuration: Constants.barAnimationDuration,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        self.inputTextField.frame = self.inputTextFieldFrame
                        self.searchButton.frame = self.searchButtonFrame
        }, completion: nil)
    }

    @objc private func clearInput() {
        inputTextField.text = nil
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.search(input: textField.text)
        return true
    }
}
