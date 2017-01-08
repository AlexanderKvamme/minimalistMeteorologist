//
//  NSNotificationCenterKeys.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 15/10/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

enum Notifications {
    
    static let userLocationGPSDidUpdate = "userLocationUpdated"
    static let reverseGeocodingDidFinish = "reverseGeocodingFinish"
    static let fetchCurrentWeatherDidFinish = "currentWeatherFinishedFetching"
    static let settingsDidUpdate = "settingsDidUpdate"
    static let fetchCurrentWeatherDidFail = "fetchCurrentWeatherDidFail"
}
