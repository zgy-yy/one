import CryptoKit
import Foundation
import UIKit

enum APISign {
    static let signSalt = "m4n2hjPeYWkD6tFpqKF^3HO^h24P@idT"

    /// MD5( MD5(brand.ip.model.platform.timestamp.userKey.uuid) + SALT )
    static func generateSign(
        brand: String,
        ip: String = "0.0.0.0",
        model: String = "iPhone",
        platform: String = "2",
        timestamp: String,
        userKey: String = "",
        uuid: String
    ) -> String {
        let raw = [
            brand,
            ip,
            model,
            platform,
            timestamp,
            userKey,
            uuid.lowercased(),
        ].joined(separator: ".")

        return md5(md5(raw) + signSalt)
    }

    static func buildHeaders(
        brand: String,
        model: String = "iPhone",
        ip: String = "0.0.0.0",
        platform: String = "2",
        appVersion: String = APIConfig.appVersion,
        uuid: String,
        userKey: String = "",
        token: String = "",
        timestamp: String = String(Int(Date().timeIntervalSince1970))
    ) -> [String: String] {
        let sign = generateSign(
            brand: brand,
            ip: ip,
            model: model,
            platform: platform,
            timestamp: timestamp,
            userKey: userKey,
            uuid: uuid
        )

        return [
            "uuid": uuid.lowercased(),
            "user-key": userKey,
            "app-version": appVersion,
            "app_version": appVersion,
            "timestamp": timestamp,
            "platform": platform,
            "ip": ip,
            "token": token,
            "brand": brand,
            "model": model,
            "sign": sign,
            "Content-Type": "application/x-www-form-urlencoded;charset=utf-8",
            "Accept": "application/json, text/plain, */*",
        ]
    }

    private static func md5(_ string: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// 与 JS `encodeURIComponent` 行为一致
     static func encodeURIComponent(_ string: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-_.!~*'()")
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
    }
}

enum APIDeviceInfo {
     static var uuid: String {
        UIDevice.current.identifierForVendor?.uuidString.lowercased()
            ?? UUID().uuidString.lowercased()
    }

     static var brand: String {
        APISign.encodeURIComponent(UIDevice.current.model)
    }

     static var model: String {
        UIDevice.current.model
    }
}

struct APIAuthContext: Sendable {
    var userKey: String
    var token: String
    var ip: String
    var platform: String
    var appVersion: String
    var brand: String?
    var model: String?
    var uuid: String?

    init(
        userKey: String = "",
        token: String = "",
        ip: String = "0.0.0.0",
        platform: String = "2",
        appVersion: String = APIConfig.appVersion,
        brand: String? = nil,
        model: String? = nil,
        uuid: String? = nil
    ) {
        self.userKey = userKey
        self.token = token
        self.ip = ip
        self.platform = platform
        self.appVersion = appVersion
        self.brand = brand
        self.model = model
        self.uuid = uuid
    }

    func signedHeaders(timestamp: String? = nil) -> [String: String] {
        APISign.buildHeaders(
            brand: brand ?? APIDeviceInfo.brand,
            model: model ?? APIDeviceInfo.model,
            ip: ip,
            platform: platform,
            appVersion: appVersion,
            uuid: uuid ?? APIDeviceInfo.uuid,
            userKey: userKey,
            token: token,
            timestamp: timestamp ?? String(Int(Date().timeIntervalSince1970))
        )
    }
}
