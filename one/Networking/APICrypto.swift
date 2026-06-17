import CommonCrypto
import Foundation

enum APICrypto {
    private static let aesKey = "l*bv%Ziq000Biaog"
    private static let aesIV = "8597506002939249"

    static func aesDecrypt(_ base64: String) throws -> String {
        let trimmed = base64.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let cipherData = Data(base64Encoded: trimmed) else {
            throw APICryptoError.invalidBase64
        }

        let decrypted = try aesCrypt(operation: CCOperation(kCCDecrypt), data: cipherData)
        guard let text = String(data: decrypted, encoding: .utf8) else {
            throw APICryptoError.invalidUTF8
        }
        return text
    }

    static func aesEncrypt(_ plaintext: String) throws -> String {
        let encrypted = try aesCrypt(operation: CCOperation(kCCEncrypt), data: Data(plaintext.utf8))
        return encrypted.base64EncodedString()
    }

    private static func aesCrypt(operation: CCOperation, data: Data) throws -> Data {
        let keyData = Data(aesKey.utf8)
        let ivData = Data(aesIV.utf8)
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
    case cryptFailed(CCCryptorStatus)
}

extension APICryptoError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidBase64:
            "无效的 Base64 数据"
        case .invalidUTF8:
            "解密结果不是有效的 UTF-8 文本"
        case .cryptFailed:
            "AES 加解密失败"
        }
    }
}
