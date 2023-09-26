//
//  ViewController.swift
//  LocationExample
//
//  Created by deepak on 18/09/23.
//

import UIKit
import MapKit
import CoreLocation // library for Location related
class ViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate{

    @IBOutlet weak var lblLocation : UILabel!
    @IBOutlet weak var mapView : MKMapView!

    let locationManager = CLLocationManager()
    var currentLocation : CLLocationCoordinate2D!
    
    var scooterMarker : MyMarker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
      //  self.locationManager.requestAlwaysAuthorization()
        // location permission is one of the sensitive -> Getting approval is tricky unless the description is clear
        self.locationManager.requestWhenInUseAuthorization()

        DispatchQueue.global(priority: .background).async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
                //self.locationManager.requestLocation()
                
                // automatic location call when the device moves
                // it keeps updating
            }
        }
     
        
        // Do any additional setup after loading the view.
    }

    
    func setMapView(loc : CLLocationCoordinate2D)
    {
       // focus mapview to particular region
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
       let region = MKCoordinateRegion(center: loc, span: span)
        mapView.region = region
        
      
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      
        let polyRenderer = MKPolylineRenderer   (overlay: overlay)
        polyRenderer.fillColor = UIColor.black
        polyRenderer.strokeColor = UIColor.black
        polyRenderer.lineWidth = 10

        return polyRenderer
    }
    
    // for changing the view of the annoation / markers
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation)
        {
            return nil
        }
        
        let annotaionIdentifier = "11231"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotaionIdentifier)
        
        if (annotationView == nil)
        {
            annotationView  = MKAnnotationView (annotation: annotation, reuseIdentifier: annotaionIdentifier)
            annotationView?.canShowCallout = true
        }else
        {
            annotationView?.annotation = annotation
        }
        
        let annot = annotation as! MyMarker
        
        
        let pinImage = UIImage (named: annot.image_str)
        
        
        annotationView?.image = pinImage
        return annotationView
        
    }
    func setMapAnnotation(loc : CLLocationCoordinate2D)
    {
        
        // Annotations - marker in a mapView
        let marker1 = MyMarker()
        marker1.coordinate = loc
        marker1.title = "RogerHouse "
        marker1.subtitle = "Very dangerous fellow....."
        marker1.image_str = "icon_home"
        mapView.addAnnotation(marker1)
        
        
//        let markerView = MKAnnotationView(annotation: marker1, reuseIdentifier: "roger")
//        markerView.image = UIImage (named: "icon_home")
//
        
    
        
        let hotel = MyMarker()
        hotel.coordinate = CLLocationCoordinate2D(latitude: 13.086990, longitude: 80.218449)
        hotel.title = " Sea Shell Hotel"
        hotel.subtitle = "Very dangerous hotelslll"
        hotel.image_str = "icon_food"
        mapView.addAnnotation(hotel)
        
        
        // scooter marker initiated with hotel coordinates
        
        
        // in real time -> all these coordinates will be received from the server api call // socket data
        
        scooterMarker = MyMarker()
        scooterMarker.coordinate = CLLocationCoordinate2D(latitude: 13.086990, longitude: 80.218449)
        scooterMarker.title = "Mr.Paw"
        scooterMarker.subtitle = "JetDelive"
        scooterMarker.image_str = "icon_scooter"
        mapView.addAnnotation(scooterMarker)
        
        
        self.loadTrack(loc)
    }
    
    
    func loadTrack(_ userLocation : CLLocationCoordinate2D)
    {
        var points = getPoints(userLocation)
        
        var mapPoint = [MKMapPoint]()
        
        for point in points
        {
            mapPoint.append(MKMapPoint(point))
        }
        let poliLine = MKPolyline(points: mapPoint, count: mapPoint.count)
        mapView.addOverlay(poliLine)
        // manual animation to move the delivery partner
       
        
        // to call repeated action over particular time -> e.g every 1 second
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { tmr in
          
            print("schedule timer called")
            if (points.count > 0)
            {
                self.scooterMarker.coordinate = points.first!
                points.remove(at: 0)
                
            }else
            {
                tmr.invalidate()
            }
        }
    }
    // this manual points will be replaced by the live coordinates updated from delivery partner
    func getPoints(_ userLocation : CLLocationCoordinate2D) -> [CLLocationCoordinate2D]
    {
        var list = [CLLocationCoordinate2D]()
        list.append(CLLocationCoordinate2D(latitude: 13.086990, longitude: 80.218449))
        list.append(CLLocationCoordinate2D(latitude: 13.084642, longitude: 80.218122))
        list.append(CLLocationCoordinate2D(latitude: 13.084893, longitude: 80.215344))
        list.append(CLLocationCoordinate2D(latitude: 13.084925, longitude: 80.213490))
        list.append(CLLocationCoordinate2D(latitude: 13.084974, longitude: 80.211884))
        
        list.append(CLLocationCoordinate2D(latitude: 13.085087, longitude: 80.210162))
        list.append(CLLocationCoordinate2D(latitude: 13.088602, longitude: 80.210261))
        list.append(CLLocationCoordinate2D(latitude: 13.088796, longitude: 80.209731))
        list.append(CLLocationCoordinate2D(latitude: 13.089811, longitude:  80.209169))
        list.append(CLLocationCoordinate2D(latitude: 13.084642, longitude: 80.218122))
        list.append(CLLocationCoordinate2D(latitude: 13.084642, longitude: 80.218122))
        
        return list
    }
    
    @IBAction func recenterMap()
    {
        //mapView.
       // self.setMapView(loc: self.currentLocation)
        loadTrack(currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.lblLocation.text = "locations = \(locValue.latitude) \(locValue.longitude)"
        
        self.currentLocation = locValue
        // send the location to set mapview
        
        self.setMapView(loc: locValue)
        self.setMapAnnotation(loc: locValue)
    }

}
// custom class MyMarker extended from MkPointAnnotation
// -> additional value image_string
class MyMarker : MKPointAnnotation
{
    var image_str : String!
    
}
