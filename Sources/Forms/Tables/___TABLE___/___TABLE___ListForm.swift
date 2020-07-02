//
//  ___TABLE___ListForm.swift
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___
//  ___COPYRIGHT___

import UIKit
import QMobileUI
import AnimatedCollectionViewLayout
import MapKit
import CoreLocation

/// Generated list form for ___TABLE___ table.
@IBDesignable
class ___TABLE___ListForm: ListFormCollection, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let annotation = MKPointAnnotation()
    var locationManager = CLLocationManager()
    var hasLocationActivated = false
    let actionButton = UIButton()

    /// List of record from data sources
    var records: [___TABLE___]? {
        return (self.dataSource?.fetchedRecords.compactMap { $0.store as? ___TABLE___ })
    }

    // Do not edit name or override tableName
    public override var tableName: String {
        return "___TABLE___"
    }

    // MARK: Events
    override func onLoad() {
        // Do any additional setup after loading the view.
        collectionView?.isPagingEnabled = true
        updateLayoutAnimator()

        // Action Button definition
        actionButton.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: 45, width: 50, height: 50)
        let image = UIImage(named: "moreButton")
        actionButton.setImage(image, for: UIControl.State.normal)
        actionButton.actionSheet = self.actionSheet
        actionButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        view.addSubview(actionButton)

        // User position
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        mapView.showsUserLocation = true
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        let blueColor = UIColor(red: 85/255, green: 183/255, blue: 174/255, alpha: 1.0)

        // Floating SearchBar definition
        searchBar = UISearchBar(frame: CGRect(x: 20, y: 50, width: UIScreen.main.bounds.width - 100, height: 48))
        searchBar.layer.cornerRadius = 15
        searchBar.layer.masksToBounds = true
        searchBar.transform = CGAffineTransform(scaleX: 0, y: 0)
        let barButtonAppearanceInSearchBar: UIBarButtonItem?
        barButtonAppearanceInSearchBar = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        barButtonAppearanceInSearchBar?.tintColor = blueColor

        // SearchBar text style
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = blueColor
        textFieldInsideUISearchBar?.font = UIFont(name: "HelveticaNeue-Thin", size: 15)

        // SearchBar placeholder style
        let textFieldInsideUISearchBarLabel = textFieldInsideUISearchBar?.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideUISearchBarLabel?.textColor = blueColor
        textFieldInsideUISearchBarLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
        self.refreshControl?.tintColor = blueColor
        searchBar.placeholder = " Search by address"
        searchBar.delegate = self
        self.view.addSubview(searchBar)
    }

    override func onWillAppear(_ animated: Bool) {
        // Called when the view is about to made visible. Default does nothing
        collectionView.contentInset = UIEdgeInsets(top: collectionView.frame.height/6, left: 0, bottom: 0, right: 0)
    }

    override func onDidAppear(_ animated: Bool) {
        // Called when the view has been fully transitioned onto the screen. Default does nothing

        // SearchBar animation
        UIView.animate(withDuration: 1.0, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 2, options: [.curveEaseOut], animations: {
            self.searchBar.transform = .identity
        }, completion: nil)

        // Action Button animation
        UIView.animate(withDuration: 1.0, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 2, options: [.curveEaseOut], animations: {
            self.actionButton.transform = .identity
        }, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.findPosition()
        }
    }

    override func onWillDisappear(_ animated: Bool) {
        // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
    }

    override func onDidDisappear(_ animated: Bool) {
        // Called after the view was dismissed, covered or otherwise hidden. Default does nothing
    }

    // MARK: scroll and layout animation

    func updateLayoutAnimator() {
        if let layout = self.collectionView?.collectionViewLayout as? AnimatedCollectionViewLayout {
            layout.animator = LinearCardAttributesAnimator()
            layout.scrollDirection = .horizontal
        }
    }

    open override func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        // Fix position when searching
        scrollView.setContentOffset(.zero, animated: false)
    }

    public override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        mapView.removeAnnotations(mapView.annotations)
        findPosition()
    }

    // MARK: collection view
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        logger.verbose(indexPath.row)
        _ = self.collectionView?.visibleCells
    }

    // MARK: Search and locations

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        mapView.removeAnnotations(mapView.annotations)
        findPosition()
    }

    func findPosition() {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: CGFloat(visibleRect.midX), y: CGFloat(visibleRect.midY))
        let visibleIndexPath: IndexPath? = collectionView.indexPathForItem(at: visiblePoint)

        guard let record = self.records?[safe: visibleIndexPath?.row ?? 0] else { return }

        if record.has(key: "___FIELD1___"), let location = record.value(forKeyPath: "___FIELD1___") {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(location) { [weak self] placemarks, _ in
                guard let strongSelf = self,
                    let mapView = strongSelf.mapView,
                    let placemark = placemarks?.first,
                    let location = placemark.location else { return }

                let mark = MKPlacemark(placemark: placemark)
                if strongSelf.hasLocationActivated {

                    let directionRequest = MKDirections.Request()
                    directionRequest.source = MKMapItem.forCurrentLocation()

                    let destinationPlacemark = MKPlacemark(placemark: placemark)
                    directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
                    directionRequest.transportType = MKDirectionsTransportType.automobile
                    let directions = MKDirections(request: directionRequest)

                    directions.calculate { (routeRepsonse, _) -> Void in
                        guard let route = routeRepsonse?.routes[safe: 0] else { return }
                        mapView.setRegion(for: route)
                    }
                } else {  // IF location NOT activated
                    var region = mapView.region
                    region.center = location.coordinate
                    region.span.longitudeDelta = 0.005
                    region.span.latitudeDelta = 0.005
                    mapView.setRegion(region, animated: true)
                    mapView.addAnnotation(mark)
                    let insets = UIEdgeInsets(top: 0, left: 0, bottom: 250, right: 0)
                    let rect = strongSelf.mkMapRect(for: region)
                    mapView.setVisibleMapRect(rect, edgePadding: insets, animated: true)
                }
                mapView.addAnnotation(mark)
            }
        }
    }

    /// Convert CoordinateRegion to MapRect
    func mkMapRect(for region: MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))
        let top = MKMapPoint(topLeft)
        let bottom = MKMapPoint(bottomRight)

        return MKMapRect(origin: MKMapPoint(x: min(top.x, bottom.x), y: min(top.y, bottom.y)), size: MKMapSize(width: abs(top.x-bottom.x), height: abs(top.y-bottom.y)))
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        let blueColor = UIColor(red: 72/255.0, green: 159/255.0, blue: 226/255.0, alpha: 1.0)

        renderer.strokeColor = blueColor
        renderer.lineWidth = 2.0
        return renderer
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                hasLocationActivated = false
                logger.info("Location Not Activated")
            case .authorizedAlways, .authorizedWhenInUse:
                hasLocationActivated = true
                logger.info("Location Activated")
            @unknown default:
                logger.debug("unknown status for location manager")
            }
        } else {
            hasLocationActivated = false
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension ___TABLE___ListForm: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(Int16.max)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = self.view.frame.size
        if let tabBarController = tabBarController {
            size = CGSize(width: size.width,
                          height: size.height - tabBarController.tabBar.frame.size.height)
        }
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: extensions

fileprivate extension Array {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript(safe index: Int ) -> Element? {
        return indices.contains(index) ? self[index] : nil  /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    }
}

fileprivate extension MKMapView {

    func setRegion(for route: MKRoute) {
        self.addOverlay(route.polyline, level: .aboveRoads)

        var regionRect = route.polyline.boundingMapRect

        let wPadding = regionRect.size.width * 0.5
        let hPadding = regionRect.size.height * 0.5

        regionRect.size.width += wPadding
        regionRect.size.height += hPadding

        regionRect.origin.x -= wPadding / 2
        regionRect.origin.y -= hPadding / 2

        self.setRegion(MKCoordinateRegion(regionRect), animated: true)
    }
}
