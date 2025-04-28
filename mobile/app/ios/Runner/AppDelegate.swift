import Flutter
import UIKit
import GoogleMaps



@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //google map
    GMSServices.provideAPIKey("AIzaSyCw5oCey7i_yWvKuJVQ-apK_xenWUqgsUY") 

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
}
