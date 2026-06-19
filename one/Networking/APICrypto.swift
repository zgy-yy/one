import CommonCrypto
import Foundation
import UIKit

enum APICrypto {
    private static let aesKey = "l*bv%Ziq000Biaog"
    private static let aesIV = "8597506002939249"
    private static let imageAESKey = "saIZXc4yMvq0Iz56"
    private static let imageAESIV = "kbJYtBJUECT0oyjo"

    static func aesDecrypt(_ base64: String) throws -> String {
        let trimmed = base64.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let cipherData = Data(base64Encoded: trimmed) else {
            throw APICryptoError.invalidBase64
        }

        let decrypted = try aesCrypt(
            operation: CCOperation(kCCDecrypt),
            data: cipherData,
            key: aesKey,
            iv: aesIV
        )
        guard let text = String(data: decrypted, encoding: .utf8) else {
            throw APICryptoError.invalidUTF8
        }
        return text
    }

    static func aesEncrypt(_ plaintext: String) throws -> String {
        let encrypted = try aesCrypt(
            operation: CCOperation(kCCEncrypt),
            data: Data(plaintext.utf8),
            key: aesKey,
            iv: aesIV
        )
        return encrypted.base64EncodedString()
    }

    /// AES-128-CBC 解密图片（Base64 密文 -> Base64 明文）
    static func decryptImage(_ base64: String) throws -> String {
        let trimmed = base64.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw APICryptoError.emptyCipherText
        }
        guard let cipherData = Data(base64Encoded: trimmed) else {
            throw APICryptoError.invalidBase64
        }

        let decrypted = try aesCrypt(
            operation: CCOperation(kCCDecrypt),
            data: cipherData,
            key: imageAESKey,
            iv: imageAESIV
        )
        return decrypted.base64EncodedString()
    }

    static func decryptImageData(_ base64: String) throws -> Data {
        let plaintextBase64 = try decryptImage(base64)
        guard let data = Data(base64Encoded: plaintextBase64) else {
            throw APICryptoError.invalidBase64
        }
        return data
    }

    static func loadDecryptedImage(from url: URL, maxPixelSize: Int? = nil) async throws -> UIImage {
        try await ImageCache.load(from: url, maxPixelSize: maxPixelSize) {
            let (data, response) = try await URLSession.shared.data(from: url)
            try Task.checkCancellation()

            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                throw APICryptoError.invalidResponse
            }

            let cipherBase64: String
            if let text = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !text.isEmpty
            {
                cipherBase64 = text
            } else {
                cipherBase64 = data.base64EncodedString()
            }

            let imageData = try decryptImageData(cipherBase64)
            try Task.checkCancellation()

            guard let image = GIFImage.makeImage(from: imageData, maxPixelSize: maxPixelSize) else {
                throw APICryptoError.invalidImageData
            }
            return image
        }
    }

    private static func aesCrypt(
        operation: CCOperation,
        data: Data,
        key: String,
        iv: String
    ) throws -> Data {
        let keyData = Data(key.utf8)
        let ivData = Data(iv.utf8)
        let bufferSize = data.count + kCCBlockSizeAES128
        var output = [UInt8](repeating: 0, count: bufferSize)
        var outputLength = 0

        let status = data.withUnsafeBytes { dataBytes in
            keyData.withUnsafeBytes { keyBytes in
                ivData.withUnsafeBytes { ivBytes in
                    CCCrypt(
                        operation,
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionPKCS7Padding),
                        keyBytes.baseAddress,
                        keyData.count,
                        ivBytes.baseAddress,
                        dataBytes.baseAddress,
                        data.count,
                        &output,
                        bufferSize,
                        &outputLength
                    )
                }
            }
        }

        guard status == kCCSuccess else {
            throw APICryptoError.cryptFailed(status)
        }

        return Data(output.prefix(outputLength))
    }
}

enum APICryptoError: Error, Sendable {
    case invalidBase64
    case invalidUTF8
    case invalidImageData
    case invalidResponse
    case emptyCipherText
    case cryptFailed(CCCryptorStatus)
}

extension APICryptoError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidBase64:
            "无效的 Base64 数据"
        case .invalidUTF8:
            "解密结果不是有效的 UTF-8 文本"
        case .invalidImageData:
            "解密结果不是有效的图片数据"
        case .invalidResponse:
            "图片下载失败"
        case .emptyCipherText:
            "密文为空"
        case .cryptFailed:
            "AES 加解密失败"
        }
    }
}
