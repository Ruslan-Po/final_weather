import Foundation

protocol LocationStorageProtocol {
    func save(_ value: LastLocation)
    func get() -> LastLocation?
    func clear()
}

final class LocationStorageUD: LocationStorageProtocol {
    private let data = UserDefaults.standard
    private let key = "last_location"

    func save(_ value: LastLocation) {
        if let data = try? JSONEncoder().encode(value) {
            self.data.set(data, forKey: key)
        }
    }
    func get() -> LastLocation? {
        guard let data = data.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(LastLocation.self, from: data)
    }
    func clear() { data.removeObject(forKey: key) }
}
