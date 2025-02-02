//
//  AuthManager.swift
//  alif-test-case
//
//  Created by Оля Налоева on 02.02.2025.
//

import RealmSwift
import Foundation
import CryptoKit

protocol AuthManager: AnyObject {
    func registerUser(
        username: String,
        password: String,
        completion: @escaping (Result<TokenResponse, AuthManagerError>) -> Void
    )
    func authenticate(
        username: String,
        password: String,
        completion: @escaping (Result<TokenResponse, AuthManagerError>) -> Void
    )
    func getProfile(
        userId: String,
        completion: @escaping (Result<AuthManagerImp.User, AuthManagerError>) -> Void
    )
}

enum AuthManagerError: String, Error {
    case notRegistered = "Пользователь не зарегестрирован, пройдите регистрацию по кнопке ниже"
    case registaionFailed = "Ошибка регистрации"
    case profileNotFound = "Пользователь не найден"
}

class AuthManagerImp: AuthManager {

    @objc(User)
    class User: Object {
        @Persisted var userId: String = UUID().uuidString
        @Persisted var username: String
        @Persisted var passwordHash: String
    }

    private let storage: StorageManager?
    private let realm: Realm?

    init(storage: StorageManager?, realm: Realm?) {
        self.storage = storage
        self.realm = realm
    }

    // MARK: - AuthManager

    func authenticate(
        username: String,
        password: String,
        completion: @escaping (Result<TokenResponse, AuthManagerError>) -> Void
    ) {
        guard let user = realm?.objects(User.self).filter("username == %@", username).first else {
            completion(.failure(.notRegistered))
            return
        }
        completion(.success(TokenResponse(token: hashString(user.userId), userId: user.userId)))
    }

    func registerUser(
        username: String,
        password: String,
        completion: @escaping (Result<TokenResponse, AuthManagerError>) -> Void
    ) {
        let newUser = User()
        newUser.passwordHash = hashString(password)
        newUser.username = username
        do {
            try realm?.write {
                realm?.add(newUser)
                let response = TokenResponse(
                    token: hashString(newUser.userId),
                    userId: newUser.userId
                )
                storage?.saveToken(token: response)
                completion(.success(response))
            }
        } catch {
            completion(.failure(.registaionFailed))
        }
    }

    func getProfile(
        userId: String,
        completion: @escaping (Result<AuthManagerImp.User, AuthManagerError>) -> Void
    ) {
        guard let user = realm?.objects(User.self).filter("userId == %@", userId).first else {
            completion(.failure(.profileNotFound))
            return
        }
        completion(.success(user))

    }

    // MARK: - Private

    private func hashString(_ str: String) -> String {
        SHA256.hash(data: Data(str.utf8)).compactMap { String(format: "%02x", $0) }.joined()
    }
}
