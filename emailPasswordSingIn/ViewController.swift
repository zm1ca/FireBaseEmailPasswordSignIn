//
//  ViewController.swift
//  emailPasswordSingIn
//
//  Created by Źmicier Fiedčanka on 15.01.21.
//

/*
1. Validate fields data
2. Get Auth instance
3. Attempt sign in
4. If failure -> alert to create account;if user continues -> create account
 
e1. check sign in on app launch
e2. allow user to sign out with button
 */

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text          = "Firebase Login"
        label.textAlignment = .center
        label.font          = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let emailTextField: UITextField = {
        let emailTextField = UITextField()
        emailTextField.placeholder            = "Email Adress"
        
        emailTextField.backgroundColor        = .white
        emailTextField.layer.cornerRadius     = 8
        emailTextField.layer.borderWidth      = 1
        emailTextField.layer.borderColor      = UIColor.black.cgColor
        
        emailTextField.autocorrectionType     = .no
        emailTextField.autocapitalizationType = .none
        
        emailTextField.leftViewMode           = .always
        emailTextField.leftView               = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        return emailTextField
    }()
    
    
    let passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.placeholder        = "Password"
        
        passwordTextField.backgroundColor    = .white
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.layer.borderWidth  = 1
        passwordTextField.layer.borderColor  = UIColor.black.cgColor
        
        passwordTextField.isSecureTextEntry  = true
        
        passwordTextField.leftViewMode       = .always
        passwordTextField.leftView           = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        return passwordTextField
    }()
    
    
    let signInButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Sign In", for: .normal)
        button.addTarget(self, action: #selector(handleSignInButtonTap), for: .touchUpInside)
        
        button.backgroundColor    = .systemGreen
        button.layer.cornerRadius = 10
        button.layer.borderWidth  = 2
        button.layer.borderColor  = UIColor.black.cgColor
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    let emailLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.font          = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let signOutButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Sign Out", for: .normal)
        button.addTarget(self, action: #selector(handleSignOutButtonTap), for: .touchUpInside)
        
        button.backgroundColor    = .systemGreen
        button.layer.cornerRadius = 10
        button.layer.borderWidth  = 2
        button.layer.borderColor  = UIColor.black.cgColor
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    func checkoutLoginStateAndUpdateUI() {
        let userLoggedIn = (FirebaseAuth.Auth.auth().currentUser != nil)
        
        titleLabel.isHidden        = userLoggedIn
        emailTextField.isHidden    = userLoggedIn
        passwordTextField.isHidden = userLoggedIn
        signInButton.isHidden      = userLoggedIn
        
        emailLabel.isHidden          = !userLoggedIn
        signOutButton.isHidden     = !userLoggedIn
        
        if userLoggedIn {
            emailTextField.text    = ""
            passwordTextField.text = ""
            
            emailTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
            
            emailLabel.text = FirebaseAuth.Auth.auth().currentUser?.email ?? "Username"
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        checkoutLoginStateAndUpdateUI()
    }


    @objc private func handleSignInButtonTap() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Missing field data")
            return
        }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            
            guard error == nil else {
                print("Sign in failed", error ?? "")
                strongSelf.showAccountCreationAlert(email: email, password: password)
                return
            }
            
            print("Signed in successfully")
            strongSelf.checkoutLoginStateAndUpdateUI()
        }
    }
    
    
    @objc private func handleSignOutButtonTap() {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            checkoutLoginStateAndUpdateUI()
        } catch let signOutError {
            print("Sign Out Error: \(signOutError)")
        }
    }
    
    
    private func showAccountCreationAlert(email: String, password: String) {
        let alert = UIAlertController(title: "Create Account", message: "Would you like to crate account?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (_) in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                guard let strongSelf = self, error == nil else {
                    print("Account creation failed", error ?? "")
                    return
                }
                
                print("Created account successfully")
                strongSelf.checkoutLoginStateAndUpdateUI()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    
    private func layoutUI() {
        let padding: CGFloat = 16
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(emailTextField)
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(passwordTextField)
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: padding),
            passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(signInButton)
        NSLayoutConstraint.activate([
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.widthAnchor.constraint(equalToConstant: 150),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(emailLabel)
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            emailLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            emailLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            emailLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        view.addSubview(signOutButton)
        NSLayoutConstraint.activate([
            signOutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: padding),
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.widthAnchor.constraint(equalToConstant: 150),
            signOutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
