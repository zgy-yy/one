import Foundation

enum APIConfig: Sendable {
    nonisolated static let baseURL = URL(string: "https://api.apubis.com")!
    nonisolated static let mediaURL = URL(string: "https://dlmk0129.bx7qxb.com")!
    nonisolated static let imageURL = URL(string: "https://jmt58.hynybzh.com")!
    nonisolated static let appVersion = "2.6.3.1"
    nonisolated static let uuid = "8b48f139-78c2-46b8-8a04-ce4d997ae01a"
    nonisolated static let userKey = "950a04a4ce3f2fc24d35759589e86907"
    nonisolated static let brand = "iPhone 16"
    nonisolated static let platform = "2"
    nonisolated static let ip = "0.0.0.0"
    nonisolated static let model = "iPhone"
    nonisolated static let token =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjc1ODk4MDUsImlzX3Zpc2l0b3IiOjAsInV1aWQiOiI4YjQ4ZjEzOS03OGMyLTQ2YjgtOGEwNC1jZTRkOTk3YWUwMWEiLCJuaWNrbmFtZSI6IjE0NyoqKioqOTM0IiwiaXAiOiIyMjMuMTA0LjQxLjkyIiwiaWF0IjoxNzgxNjcyNDM2LCJleHAiOjE3ODIyODA4MzYsIm5iZiI6MTc4MTY3MjQzNiwic3ViIjoiYXBpLmFwdWJpcy5jb20iLCJqdGkiOiJjMmU0Mjk0Y2I5ZmUzZDU1Y2UwMzc3NjRjZjhiYzY5MiJ9.R2UAQZiWZjRooxnRn0SeRcEQ9gOl9g5JyMQNfNw1r_U"

    nonisolated static var auth: APIAuthContext {
        APIAuthContext(
            userKey: userKey,
            token: token,
            ip: ip,
            platform: platform,
            appVersion: appVersion,
            brand: brand,
            model: model,
            uuid: uuid
        )
    }
}
