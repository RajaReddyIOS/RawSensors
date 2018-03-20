//
//  ViewController.swift
//  SesorsCollection
//
//  Created by Raja on 19/03/18.
//  Copyright © 2018 Cogcons. All rights reserved.
//

import UIKit
import CoreMotion
import SceneKit

class ViewController: UIViewController {

    @IBOutlet weak var pressureView: UIView!
    @IBOutlet weak var geomagneticView: UIView!
    @IBOutlet weak var gyroscopeView: UIView!
    @IBOutlet weak var orientationView: UIView!
    @IBOutlet weak var linearAccelerationView: UIView!
    @IBOutlet weak var rotationView: UIView!
    @IBOutlet weak var gravityView: UIView!
    @IBOutlet weak var accelerometerView: UIView!
    
    @IBOutlet weak var accelerometerX: UILabel!
    @IBOutlet weak var accelerometerY: UILabel!
    @IBOutlet weak var accelerometerZ: UILabel!
    @IBOutlet weak var gravityY: UILabel!
    @IBOutlet weak var gravityZ: UILabel!
    @IBOutlet weak var rotationX: UILabel!
    @IBOutlet weak var rotationY: UILabel!
    @IBOutlet weak var rotationZ: UILabel!
    @IBOutlet weak var linearAccelerationX: UILabel!
    @IBOutlet weak var linearAccelerationY: UILabel!
    @IBOutlet weak var linearAccelerationZ: UILabel!
    @IBOutlet weak var orientationX: UILabel!
    @IBOutlet weak var orientationY: UILabel!
    @IBOutlet weak var orientationZ: UILabel!
    @IBOutlet weak var gyroX: UILabel!
    @IBOutlet weak var gyroY: UILabel!
    @IBOutlet weak var gyroZ: UILabel!
    @IBOutlet weak var geoMagneticX: UILabel!
    @IBOutlet weak var geoMagneticY: UILabel!
    @IBOutlet weak var geoMagneticZ: UILabel!
    @IBOutlet weak var pressure: UILabel!
    
    @IBOutlet weak var attitudeView: UIView!
    @IBOutlet weak var roll: UILabel!
    @IBOutlet weak var pitch: UILabel!
    @IBOutlet weak var yaw: UILabel!
    @IBOutlet weak var ambientView: UIView!
    @IBOutlet weak var ambientValues: UILabel!
    
    
    @IBOutlet weak var gravityX: UILabel!
    fileprivate var motionManager: CMMotionManager!
    final var  alpha = 0.8
    
    fileprivate let altimeter = CMAltimeter()
    
    var gravity = [Double](repeating: 0.0, count: 3)
    
    fileprivate var getClassName:String {
        return String(describing: ViewController.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       setupSensors()
    }

    func setupSensors() {
        self.motionManager = CMMotionManager()
        setupViews()
        self.completedSensors()
        self.startDeviceMotionUpdates()
        self.startAccelerometerUpdates()
        self.getPressureUpdates()
        startGyroUpdates()
        self.ambientValuesDidChange()
        
        UIDevice.current.isProximityMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.proximityDidChange), name: NSNotification.Name.UIDeviceProximityStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.ambientValuesDidChange), name: NSNotification.Name.UIScreenBrightnessDidChange, object: nil)
    }
    
    @objc fileprivate func ambientValuesDidChange() {
        print("screen brightness: ",UIScreen.main.brightness)
        var percentage = round(UIScreen.main.brightness*1000)
        percentage = percentage*0.1
        self.ambientValues.text = percentage.toString+"%"
    }
    
    @objc fileprivate func proximityDidChange() {
        print("proximity state: ",UIDevice.current.proximityState)
    }
    
    fileprivate func completedSensors() {
        self.accelerometerView.completedSensors()
        self.gravityView.completedSensors()
        self.geomagneticView.completedSensors()
        self.linearAccelerationView.completedSensors()
        self.pressureView.completedSensors()
        self.gyroscopeView.completedSensors()
        self.attitudeView.completedSensors()
        self.ambientView.completedSensors()
        self.rotationView.completedSensors()
    }
    
    fileprivate func setupViews() {
        accelerometerView.customSetupView(5)
        pressureView.customSetupView(5)
        geomagneticView.customSetupView(5)
        gyroscopeView.customSetupView(5)
        orientationView.customSetupView(5)
        linearAccelerationView.customSetupView(5)
        rotationView.customSetupView(5)
        gravityView.customSetupView(5)
        attitudeView.customSetupView(5)
        ambientView.customSetupView(5)
    }

    fileprivate func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }
                motionManager.accelerometerUpdateInterval = 1.0
        let motionQueue = OperationQueue.current!
        motionManager.startAccelerometerUpdates(to: motionQueue) { (accelerometerData, err) -> Void in
            if let data = accelerometerData {
                self.accelerometerX.text = "\(data.acceleration.x)"
                self.accelerometerY.text = "\(data.acceleration.y)"
                self.accelerometerZ.text = "\(data.acceleration.z)"
                
                print("accelerometer sensor data: ",data.acceleration, "timeInterval: ",Date().timeIntervalSince1970)
            }
        }
    }
    
    fileprivate func startDeviceMotionUpdates() {
        if self.motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.5
            motionManager.showsDeviceMovementDisplay = true
            motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical, to: OperationQueue(), withHandler: { (motion, error) in
                if let deviceMotion = motion {
                    DispatchQueue.main.async {
                        var x = round(deviceMotion.rotationRate.x*1000000)
                        var y = round(deviceMotion.rotationRate.y*1000000)
                        var z = round(deviceMotion.rotationRate.z*1000000)
                        x = x/1000000
                        y = y/1000000
                        z = z/1000000
                        let xVal = x.sign != .minus ? "+"+x.toString : x.toString
                        let yVal = y.sign != .minus ? "+"+y.toString : y.toString
                        let zVal = z.sign != .minus ? "+"+z.toString : z.toString
                        
                        self.rotationX.text = xVal
                        self.rotationY.text = yVal
                        self.rotationZ.text = zVal
                        
                        self.gravityX.text = "\(deviceMotion.gravity.x)"
                        self.gravityY.text = "\(deviceMotion.gravity.y)"
                        self.gravityZ.text = "\(deviceMotion.gravity.z)"
                        
                        self.geoMagneticX.text = "\(deviceMotion.magneticField.field.x) µT"
                        self.geoMagneticY.text = "\(deviceMotion.magneticField.field.y) µT"
                        self.geoMagneticZ.text = "\(deviceMotion.magneticField.field.z) µT"
                        
                        self.roll.text =  " roll: "+deviceMotion.attitude.roll.toString
                        self.pitch.text = "pitch: "+deviceMotion.attitude.pitch.toString
                        self.yaw.text =   "  yaw: "+deviceMotion.attitude.yaw.toString
                        
                        let degree = 180/Double.pi
                        
                        self.orientationX.text = (degree * deviceMotion.attitude.roll).toString
                        self.orientationY.text = (degree * deviceMotion.attitude.pitch).toString
                        self.orientationZ.text = (degree * deviceMotion.attitude.yaw).toString
                        
                        self.linearAccelerationX.text = deviceMotion.userAcceleration.x.toString
                        self.linearAccelerationY.text = deviceMotion.userAcceleration.y.toString
                        self.linearAccelerationZ.text = deviceMotion.userAcceleration.z.toString
                    }
                }
            })
        }
    }

    fileprivate func startGyroUpdates()  {
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 1.0
            motionManager.startGyroUpdates(to: OperationQueue(), withHandler: { (data, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.gyroX.text = data.rotationRate.x.toString
                        self.gyroY.text = data.rotationRate.y.toString
                        self.gyroZ.text = data.rotationRate.z.toString
                    }
                }
            })
        }
    }
    
    fileprivate func getPressureUpdates() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: { (data, error) in
                print("pressure error code: ",error)
                if let data = data {
                    self.pressure.text = "\(data.pressure) kpa"
                }
            })
            
        }
    }

}


extension UIView {
    public func borderWidth(_ width:CGFloat = 0.5, color:CGColor = UIColor.black.cgColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color
    }
    
    public func cornerRadius(_ radius:CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    public func customSetupView(_ cornerRadius:CGFloat, width:CGFloat = 0.5, color:CGColor = UIColor.black.cgColor) {
        self.borderWidth(width, color: color)
        self.cornerRadius(cornerRadius)
    }
    
    public func completedSensors() {
        let color = UIColor.green.withAlphaComponent(0.7)
        self.backgroundColor = color
        self.layer.borderColor = color.cgColor
    }
    
}

extension Double {
    var toString:String {
        return "\(self)"
    }
}

extension CGFloat {
    var toString:String {
        return "\(self)"
    }
}



