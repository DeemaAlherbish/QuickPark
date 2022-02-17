//
//  ViewController.swift
//  QuickPark
//
//  Created by MAC on 25/06/1443 AH.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage
import CoreLocation
import Kingfisher


class ViewController: UIViewController{
  //  let parkings = ["King Saud University" , "Imam University" , "Dallah Hospital"]

    

    var parkings = [Area]()
       
    var locationManager:CLLocationManager?
    var currentLocation:CLLocation?
    let storageRef = Storage.storage().reference()
    
    @IBOutlet weak var ParkingView: UIView!
    @IBOutlet weak var ParkingsViews: UITableView!
    var initialRead = true

    override func viewDidLoad() {
        super.viewDidLoad()
        ParkingsViews?.delegate = self
        ParkingsViews?.dataSource = self
        //making table view look good
        ParkingsViews?.separatorStyle = .none
        ParkingsViews?.showsVerticalScrollIndicator = false
        requestLocationPermission()
        
//        getParkings()

    }
    private func requestLocationPermission(){
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
    }
    
    private func getParkings() {
        let ref = Database.database().reference()
        ref.child("Areas").observe(DataEventType.value, with: { [self] snapshots in
            print(snapshots.childrenCount)
        
            parkings.removeAll()
            for (i,snapshot) in (snapshots.children.allObjects as! [DataSnapshot]).enumerated() {
                let dictionary = snapshot.value as? NSDictionary
                var area = Area(areaname: dictionary?["areaname"] as? String ?? "",
                                loactionLat: "\(dictionary?["loactionLat"] as? Double ?? 0)",
                                locationLong: "\(dictionary?["locationLong"] as? Double ?? 0)",
                                spotNo: "", logo: "",distance: 0)
                
                
                let location = CLLocation(latitude: Double(area.loactionLat) ?? 0,
                                              longitude: Double(area.locationLong) ?? 0)
                if let currentLocation = currentLocation{
                    let distance = currentLocation.distance(from: location) / 1000
                    let distanceString = String(format: "%.2f", distance)
                    let newDistance = Double(distanceString) ?? 0
                    area.distance = newDistance
                }
                
                parkings.append(area)
            }
            parkings = parkings.sorted(by: { $0.distance < $1.distance })
            ParkingsViews.reloadData()
        })
    }

}

extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            currentLocation = location
            self.getParkings()
        }
    }
    
}

    extension ViewController: UITableViewDelegate, UITableViewDataSource{
        func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 120
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return parkings.count
        }
        // هذي الميثود حقت الشاشه الصغيره اللي تطلع بعد مانضغط
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                           guard let myCell = tableView.cellForRow(at: indexPath) as? CustomCell else {return}
                           let ref = Database.database().reference()
                           let areaRef = ref.child("Areas")
                           areaRef.observe(.childAdded, with: { snapshot in
                               let areaname = snapshot.childSnapshot(forPath: "areaname").value as? String ?? ""
                               print("areaname", areaname)
                               if myCell.Label.text == areaname {
                                   let isAvailable = snapshot.childSnapshot(forPath: "isAvailable").value as? Bool ?? false
                                   print("isAvailable", isAvailable)
                                   if isAvailable {
                                       let Value = snapshot.childSnapshot(forPath: "Value").value as? Double ?? 0.0
                                       print("Value", Value)
                                   if Value == 1 {
                                       let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                       let viewController = storyboard.instantiateViewController(withIdentifier: "ConfirmAndPay")
                                       if #available(iOS 15.0, *) {
                                           if let presentationController = viewController.presentationController as? UISheetPresentationController {
                                               presentationController.detents = [.medium()]
                                               /// change to [.medium(), .large()] for a half and full screen sheet
                                           }
                                       }
                                       self.present(viewController, animated: true)
                                   } else {
                                       myCell.layer.borderColor = UIColor.red.cgColor
                                       myCell.Alert.text = "No Available Parkings"
                                   }
                               } else {
                                   myCell.layer.borderColor = UIColor.red.cgColor
                                   myCell.Alert.text = "No Available Parkings"
                               }
                               }
                        
                           })

                           areaRef.observeSingleEvent(of: .value, with: { snapshot in
                                   print("Done")
                                   self.initialRead = false
                               })
                       }

        

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = ParkingsViews.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
            let parking = parkings[indexPath.row]
            
            if !parking.imageURL.didLoad{
                let child = storageRef.child("AreasImages/\(parking.areaname).png")
                child.downloadURL { url, error in
                    print("Did fetch \("AreasImages/\(parking.areaname).png") url: ",url, ", with error: ",error?.localizedDescription)
                    self.parkings[indexPath.row].imageURL = ImageURL(url: url, didLoad: true)
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }else{
                cell.Logos.kf.setImage(with: parking.imageURL.url, placeholder: nil)
                //
            }
            
            
//            cell.Logos.kf.setImage(with: parking.imageURL, placeholder: UIImage(named: "King Saud University"))
            cell.Label.text = parking.areaname
            //cell.ParkingView.layer.cornerRadius = 20 //cell.ParkingView.frame.height / 2
            //cell.Logos.layer.cornerRadius = 20 //cell.Logos.frame.height / 2
           // let borderColor: UIColor =  (parkings[indexPath.row] == " ") ? .red : UIColor(red: 0/225, green: 144/255, blue: 205/255, alpha: 1) //
            (parking.areaname == " ") ? (cell.Alert.text = "No Available Parkings") : (cell.Alert.text = " ")
            cell.Km.text = "\(parking.distance) km"
            

            return cell
        }
        func addShadow(backgroundColor: UIColor = .white, cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 5, shadowOpacity: Float = 0.1, shadowPathInset: (dx: CGFloat, dy: CGFloat), shadowPathOffset: (dx: CGFloat, dy: CGFloat)) {
          
            }
      
            }
