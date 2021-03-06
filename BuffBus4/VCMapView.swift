//
//  VCMapView.swift
//  BuffBus4
//
//  Created by Joshua Ferge on 7/13/15.
//  Copyright (c) 2015 Joshua Ferge. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreLocation

extension ViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if stops.contains(view.annotation!.title!!) {
        currentPickerLocation = TitleToIndex[view.annotation!.title!!]
        UIPicker.selectRow(currentPickerLocation!, inComponent: 0, animated: true)
        updateTimes(currentPickerLocation!)
            
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view : MKAnnotationView?

        if annotation is MKUserLocation {
            return nil;
        }
        
        var isBus = false
        for bus in buses {
            if bus.title == annotation.title! {
                view = mapView.dequeueReusableAnnotationViewWithIdentifier("bus")
                isBus = true
            }
        
        }
        
        if isBus == false {
            if annotation.title! != closestStopTitle {
                view = mapView.dequeueReusableAnnotationViewWithIdentifier("stop")
            }
            else {
                if annotation.subtitle! != "" {
                view = mapView.dequeueReusableAnnotationViewWithIdentifier("closestStop")
                }
            }
        }
        
        if view == nil {
            
            var isBus = false
            for bus in buses {
                
                if bus.title == annotation.title! && bus.title != closestStopTitle {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: "bus")
                    view!.image = UIImage(named: "busicon.png")
                    isBus = true

                }
            }
            if isBus == false {
                if annotation.title! != closestStopTitle {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: "stop")
                view!.image = UIImage(named: "gold_BlackBorder.png")
                view!.centerOffset = CGPointMake(5, -5);
                view!.calloutOffset = CGPoint(x: -1, y: 0)
                view!.canShowCallout = true
                view!.alpha = 0.75
                }
                else {
                    if annotation.title! == closestStopTitle {
                    
                        view = MKAnnotationView(annotation: annotation, reuseIdentifier: "closestStop")
                        view!.image = UIImage(named: "red+gold.png")
                        view!.centerOffset = CGPointMake(5, -5);
                        view!.calloutOffset = CGPoint(x: -1, y: 0)
                        view!.canShowCallout = true
                        view!.alpha = 0.75
                    }
                }
            }
            
            
            
        }
        
        else {
            view!.annotation = annotation
        }
        
        return view
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        initialLocation = locations[0] as! CLLocation
        if first == 0 {
            centerMapOnLocation(initialLocation)
            first = first+1
        }
        
        else if first == 4 {
            
            if self.center == false {
                
            }
            
            let oldClosestStopTitle = closestStopTitle
         
            
            closestStop = ("",10000000.00)
            var i = 0
            for stop in stopinfo!  {
                if testRoute.stops.contains(stop.id) {
                    
                    let loc2 = CLLocation(latitude: stop.coordinate.latitude, longitude: stop.coordinate.longitude)
                    
                    let distance = initialLocation.distanceFromLocation(loc2)
                    
                    if closestStop?.Distance > Float(distance){
                        closestStopTitle = stop.title
                        pickerStartingLocation = i
                        closestStop = (stop.title!,Float(distance))
                    }
                    
                    i = i + 1
                    
                }
                
            }
       
            
            for stop in stopinfo! {
                if stop.title == oldClosestStopTitle {
                    stop.setNewSubtitle("")
                    let annotationsRemove = mapView.annotations.filter { $0.title! == oldClosestStopTitle }
                    mapView.removeAnnotations( annotationsRemove)
                    mapView.addAnnotation(stop)
                }
                
                if stop.title == closestStopTitle! {
                    stop.setNewSubtitle("Nearest Stop")
                    let annotationsRemove = mapView.annotations.filter { $0.title! == self.closestStopTitle  }
                    mapView.removeAnnotations( annotationsRemove)
                    mapView.addAnnotation(stop)
                }
                
            }
            
            for annotation1 in mapView.annotations {
                if annotation1.title! == closestStopTitle {
                    let annotation1 = annotation1 as? MKAnnotation
                    mapView.selectAnnotation(annotation1!, animated:true)
                }
                
            }
            
            
                if initialLocation.distanceFromLocation(CLLocation(latitude: 40.001894, longitude: -105.260184)) < 32186 {
                    centerMapOnLocation(initialLocation)
                }
                
                else {
                    centerMapOnLocation(CLLocation(latitude: 40.001894, longitude: -105.260184))
                }
            
            
            UIPicker.selectRow(pickerStartingLocation!, inComponent: 0, animated: false)
            
            currentPickerLocation = pickerStartingLocation!
            updateTimes(currentPickerLocation!)
            first = first+1
        }
        else if first < 100 {
            first = first+1
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        return nil
    }
    
    
    
}