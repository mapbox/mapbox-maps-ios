import Foundation
import simd

extension simd_double4 {
    public init(mbmVec4: Vec4) {
        self.init(x: mbmVec4.x, y: mbmVec4.y, z: mbmVec4.z, w: mbmVec4.w)
    }
}

extension simd_double4 {
    public init(mbmVec3: Vec3) {
        self.init(x: mbmVec3.x, y: mbmVec3.y, z: mbmVec3.z, w: 1.0)
    }
    
}



extension simd_quatd {
    public init(mbmVec4: Vec4) {
        self.init(vector: simd_double4(mbmVec4: mbmVec4))
    }
}

extension Vec3 {
    public convenience init(simdPos: simd_double4) {
        self.init(x: simdPos.x, y: simdPos.y, z: simdPos.z)
    }
}

extension Vec4 {
    public convenience init(simdVec: simd_double4) {
        self.init(x: simdVec.x, y: simdVec.y, z: simdVec.z, w: simdVec.w)
    }
}
