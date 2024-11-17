import Adhan

struct Coordinates: Hashable {
    let latitude: Double
    let longitude: Double
    
    func toAdhanCoordinates() -> Adhan.Coordinates {
        return Adhan.Coordinates(latitude: latitude, longitude: longitude)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    static func == (lhs: Coordinates, rhs: Coordinates) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
} 
