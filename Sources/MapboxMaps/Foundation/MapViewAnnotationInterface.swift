import MapboxCoreMaps
import UIKit
@_implementationOnly import MapboxCommon_Private
@_implementationOnly import MapboxCoreMaps_Private

public protocol MapViewAnnotationInterface: AnyObject {
    /**
     * Calculate screen position for visible view annotations.
     *
     * Should not be called explicitly in most cases,
     * will be called automatically in correct moment of time by View Annotation manager / plugin.
     *
     * @return position for all views that need to be updated on the screen.
     */
    func calculateViewAnnotationsPosition() -> ViewAnnotationsPosition


    /**
     * Add view annotation.
     *
     * @return position for all views that need to be updated on the screen or null if views' placement remained the same.
     */
    func addViewAnnotation(forIdentifier identifier: String, options: ViewAnnotationOptions) -> ViewAnnotationsPosition?


    /**
     * Update view annotation if it exists.
     *
     * @return position for all views that need to be updated on the screen or null if views' placement remained the same.
     */
    func updateViewAnnotation(forIdentifier identifier: String, options: ViewAnnotationOptions) -> ViewAnnotationsPosition?


    /**
     * Remove view annotation if it exists.
     *
     * @return position for all views that need to be updated on the screen or null if views' placement remained the same.
     */
    func removeViewAnnotation(forIdentifier identifier: String) -> ViewAnnotationsPosition?
}

