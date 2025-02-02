//
//  StorageManager.swift
//  alif-test-case
//
//  Created by Оля Налоева on 02.02.2025.
//

import UIKit
import Foundation
import KeychainAccess

protocol StorageManager {
    func cleaningKeychainIfNeedIt()
    func saveToken(token: TokenResponse?)
    func getToken() -> TokenResponse?
    func removeToken()

    func saveAppLaunchDate()
    func getAppLaunchDate() -> String

    func saveUserName(username: String)
    func getUserName() -> String

    func saveUserPhoto(photo: UIImage)
    func getUserPhoto() -> UIImage?
    func removeUserPhoto()

    func cleanUserDefaults()
}

class StorageManagerImp: StorageManager {

    private let keychain = Keychain(service: Constants.serviceId)

    func cleaningKeychainIfNeedIt() {
        guard !notFirstLaunch() else {
            return
        }
        saveFirstLaunch()
        do {
            try keychain.removeAll()
        } catch {
            print(error as Any)
        }
    }

    func saveToken(token: TokenResponse?) {
        guard let token else {
            return
        }
        do {
            try keychain.set(token.token, key: StorageManagerKey.token.rawValue)
            try keychain.set(token.userId, key: StorageManagerKey.userId.rawValue)
        } catch {
            print(error as Any)
        }
    }

    func getToken() -> TokenResponse? {
        do {
            guard let token = try keychain.get(StorageManagerKey.token.rawValue),
                let userId = try keychain.get(StorageManagerKey.userId.rawValue) else {
                return nil
            }
            return TokenResponse(token: token, userId: userId)
        } catch {
            print(error as Any)
        }
        return nil
    }

    func removeToken() {
        do {
            try keychain.remove(StorageManagerKey.token.rawValue)
            try keychain.remove(StorageManagerKey.userId.rawValue)
        } catch {
            print(error as Any)
        }
    }

    func saveAppLaunchDate() {
        UserDefaults.standard.set(getDate(), forKey: StorageManagerKey.date.rawValue)
    }

    func getAppLaunchDate() -> String {
        UserDefaults.standard.string(forKey: StorageManagerKey.date.rawValue) ?? ""
    }

    func saveUserName(username: String) {
        UserDefaults.standard.set(username, forKey: StorageManagerKey.username.rawValue)
    }

    func getUserName() -> String {
        UserDefaults.standard.string(forKey: StorageManagerKey.username.rawValue) ?? ""
    }

    func saveUserPhoto(photo: UIImage) {
        guard let data = photo.jpegData(compressionQuality: 0.5) else {
            return
        }
        let encoded = try? PropertyListEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: StorageManagerKey.photo.rawValue)
    }

    func getUserPhoto() -> UIImage? {
        guard let data = UserDefaults.standard.data(forKey: StorageManagerKey.photo.rawValue),
            let decoded = try? PropertyListDecoder().decode(Data.self, from: data) else {
            return nil
        }
        return UIImage(data: decoded)
    }

    func removeUserPhoto() {
        UserDefaults.standard.removeObject(forKey: StorageManagerKey.photo.rawValue)
    }

    func cleanUserDefaults() {
        UserDefaults.standard.removeObject(forKey: StorageManagerKey.username.rawValue)
        removeUserPhoto()
    }
}

private extension StorageManagerImp {

    enum StorageManagerKey: String {
        case notFirstLaunch
        case token
        case userId
        case date
        case username
        case photo
    }

    struct Constants {
        static let serviceId = "StorageManagerKeychain.Service.id"
    }

    func notFirstLaunch() -> Bool {
        UserDefaults.standard.bool(forKey: StorageManagerKey.notFirstLaunch.rawValue)
    }

    func saveFirstLaunch() {
        UserDefaults.standard.set(true, forKey: StorageManagerKey.notFirstLaunch.rawValue)
    }

    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM YYYY"
        return formatter.string(from: Date())
    }
}
