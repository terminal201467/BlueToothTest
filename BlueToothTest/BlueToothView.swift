//
//  BlueToothView.swift
//  CoreBlueTest
//
//  Created by Jhen Mu on 2022/1/25.
//

import UIKit

class BlueToothView: UIView {
    
    let switchButton:UISwitch = {
       let switchButton = UISwitch()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    
    let label:UILabel = {
        var label = UILabel()
        label.text = "訂閱"
        label.textAlignment = .justified
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textView:UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .lightGray
        textView.font = UIFont(name: "Helvetica-Light", size: 20)
        textView.textColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let textField:UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .gray
        textField.returnKeyType = .default
        textField.keyboardType = .emailAddress
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let sendButton:UIButton = {
        let button = UIButton()
        button.setTitle("送出", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private lazy var horiStackView:UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [switchButton,label])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var typeStackView:UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [textField,sendButton])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var vertiStackView:UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [horiStackView,textView,typeStackView])
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .leading
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(vertiStackView)
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func autoLayout(){
        NSLayoutConstraint.activate([
            horiStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor,constant: 20),
            horiStackView.rightAnchor.constraint(equalTo: rightAnchor,constant: -240),
            horiStackView.leftAnchor.constraint(equalTo: leftAnchor,constant: 25),
            horiStackView.heightAnchor.constraint(equalToConstant: 50),
            
            textView.topAnchor.constraint(equalTo: horiStackView.bottomAnchor),
            textView.rightAnchor.constraint(equalTo: rightAnchor,constant: -20),
            textView.leftAnchor.constraint(equalTo: leftAnchor,constant: 20),
            textView.heightAnchor.constraint(equalTo: heightAnchor,multiplier: 0.3),
            
            typeStackView.topAnchor.constraint(equalTo: textView.bottomAnchor,constant: 30),
            typeStackView.rightAnchor.constraint(equalTo: textView.rightAnchor),
            typeStackView.leftAnchor.constraint(equalTo: textView.leftAnchor),
            typeStackView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}
