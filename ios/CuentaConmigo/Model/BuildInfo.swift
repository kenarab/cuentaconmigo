import Foundation

/// App version shown to the user: marketing version, build number and the git commit
/// recorded by ios/scripts/sync-contracts.sh in Resources/build-info.json (git-ignored).
enum BuildInfo {
    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }

    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
    }

    static var commit: String? {
        guard let url = Bundle.main.url(forResource: "build-info", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let info = try? JSONDecoder().decode([String: String].self, from: data) else { return nil }
        return info["commit"]
    }

    static var summary: String {
        "Versión \(version) (\(build))" + (commit.map { " · \($0)" } ?? "")
    }
}
