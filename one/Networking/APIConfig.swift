import Foundation

enum APIConfig: Sendable {
    nonisolated static let baseURL = URL(string: "https://api.apubis.com")!
    nonisolated static let mediaURL = URL(string: "https://dlmk0129.bx7qxb.com")!
    nonisolated static let imageURL = URL(string: "https://jmt58.hynybzh.com")!
    nonisolated static let appVersion = "2.6.3.1"
    nonisolated static let uuid = "24c02fff-01a1-49be-b7e3-5ff182ecac93"
    nonisolated static let userKey = "950a04a4ce3f2fc24d35759589e86907"
    nonisolated static let brand = "iPhone 16"
    nonisolated static let platform = "2"
    nonisolated static let ip = "0.0.0.0"
    nonisolated static let model = "iPhone"
    nonisolated static let token =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjc1ODk4MDUsImlzX3Zpc2l0b3IiOjAsInV1aWQiOiIyNGMwMmZmZi0wMWExLTQ5YmUtYjdlMy01ZmYxODJlY2FjOTMiLCJuaWNrbmFtZSI6IjE0NyoqKioqOTM0IiwiaXAiOiIxMTQuMjQzLjk5Ljc1IiwiaWF0IjoxNzgxMTkyMDU3LCJleHAiOjE3ODE4MDA0NTcsIm5iZiI6MTc4MTE5MjA1Nywic3ViIjoiYXBpLmVpbmhuNC5jb20iLCJqdGkiOiJjNzRlYWRkNjE3MDdkMjg2YWEzMjRlMjU0YjI0NTFkNyJ9.BM3JwrPiwVxoKIl2G5OHqL57N5WbO4Vzk1apxkdsRpI"

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
