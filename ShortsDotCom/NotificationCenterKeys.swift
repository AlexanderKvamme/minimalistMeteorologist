//
//  NSNotificationCenterKeys.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 15/10/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

enum Notifications {
    
    static let userLocationGPSDidUpdate = "userLocationUpdated"
    static let locationManagerFailed = "locationManagerFailed"
    static let reverseGeocodingDidFinish = "reverseGeocodingFinish"
    static let fetchCurrentWeatherDidFinish = "currentWeatherFetchFinished"
    static let settingsDidUpdate = "settingsDidUpdate"
    static let fetchCurrentWeatherDidFail = "fetchCurrentWeatherFailed"
}
