import Adhan

struct Coordinates {
    let latitude: Double
    let longitude: Double
    
    func toAdhanCoordinates() -> Adhan.Coordinates {
        return Adhan.Coordinates(latitude: latitude, longitude: longitude)
    }
} 
