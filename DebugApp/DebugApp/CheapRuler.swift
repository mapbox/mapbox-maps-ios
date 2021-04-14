// Minimal port required for animating along route

import Darwin
import CoreLocation

let RE = 6378.137; // equatorial radius
let FE = 1.0 / 298.257223563; // flattening

let E2 = FE * (2 - FE);
let RAD = Double.pi / 180.0;

class CheapRuler {
    var kx = 0.0;
    var ky = 0.0;
    
    init(latitude: Double) { // kilometers only of interest
        // Curvature formulas from https://en.wikipedia.org/wiki/Earth_radius#Meridional
        let mul = RAD * RE;
        let coslat = cos(latitude * RAD);
        let w2 = 1 / (1 - E2 * (1 - coslat * coslat));
        let w = sqrt(w2);

        // multipliers for converting longitude and latitude degrees into distance
        kx = mul * w * coslat;        // based on normal radius of curvature
        ky = mul * w * w2 * (1 - E2); // based on meridonal radius of curvature
    }
    
    public func lineDistance(points: [CLLocationCoordinate2D])-> Double {
        var total = 0.0;

        for i in 1..<(points.count) {
            total += distance(a: points[i - 1], b: points[i]);
        }
        return total;
    }
    
    func distance(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D) -> Double {
        let dx = wrap(d: a.longitude - b.longitude) * self.kx;
        let dy = (a.latitude - b.latitude) * self.ky;
        return sqrt(dx * dx + dy * dy);
    }
    
    func wrap(d: Double)->Double {
        var deg = d;
        while (deg < -180) { deg += 360 }
        while (deg > 180) { deg -= 360 }
        return deg;
    }
    
    public func along(line: [CLLocationCoordinate2D], dist: Double)-> CLLocationCoordinate2D {
        var sum = 0.0;

        if (dist <= 0) { return line[0] };

        for i in 0..<(line.count - 1) {
            let p0 = line[i];
            let p1 = line[i + 1];
            let d = self.distance(a:p0, b:p1);
            sum += d;
            if (sum > dist) {
                return interpolate(a: p0, b: p1, t: (dist - (sum - d)) / d);
            }
        }
        return line[line.count - 1];
    }
    
    func interpolate(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D, t: Double)-> CLLocationCoordinate2D {
        let dx = wrap(d: b.longitude - a.longitude);
        let dy = b.latitude - a.latitude;

        return CLLocationCoordinate2D(latitude:a.latitude + dy * t, longitude: a.longitude + dx * t);
    }
    
    public func bearing(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D)-> Double {
        let dx = wrap(d: b.longitude - a.longitude) * self.kx;
        let dy = (b.latitude - a.latitude) * self.ky;
        return atan2(dx, dy) / RAD;
    }
}

    
    

