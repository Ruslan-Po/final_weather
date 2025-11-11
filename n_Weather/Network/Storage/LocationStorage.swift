import Foundation

protocol LocationStorageProtocol {
    func save(_ value: LastLocation)
    func get() -> LastLocation?
    func clear()
}

final class LocationStorageUD: LocationStorageProtocol {
    private let d = UserDefaults.standard
    private let key = "last_location"

    func save(_ value: LastLocation) {
        if let data = try? JSONEncoder().encode(value) {
            d.set(data, forKey: key)
        }
    }
    func get() -> LastLocation? {
        guard let data = d.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(LastLocation.self, from: data)
    }
    func clear() { d.removeObject(forKey: key) }
}
