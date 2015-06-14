//
//  Follower.h
//  Follower
//
//  Created by Mike on 6/10/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class Follower;

@protocol FollowerDelegate <NSObject>

@optional
- (void)followerDidUpdate:(Follower *)follower;

@end

typedef NS_ENUM(NSUInteger, TrackingState) {
    TrackingStateOff = 0,
    TrackingStatePaused,
    TrackingStateTracking
};

typedef NS_ENUM(NSUInteger, TimeUnit) {
    TimeUnitSeconds = 0,
    TimeUnitMinutes,
    TimeUnitHours
};

typedef NS_ENUM(NSUInteger, DistanceUnit) {
    DistanceUnitMeters = 0,
    DistanceUnitKilometers,
    DistanceUnitFeet,
    DistanceUnitMiles
};

typedef NS_ENUM(NSUInteger, SpeedUnit) {
    SpeedUnitMetersPerSecond = 0,
    SpeedUnitKilometersPerHour,
    SpeedUnitMilesPerHour
};

@interface Follower : NSObject

@property (nonatomic) id<FollowerDelegate> delegate;

@property (nonatomic, strong, readonly) NSMutableArray *routeLocations;

@property (nonatomic, strong, readonly) MKPolyline *routePolyline;

@property (nonatomic, readonly) MKCoordinateRegion routeRegion;

@property (nonatomic, readonly) TrackingState trackingState;

- (void)beginRouteTracking;

- (void)pauseRouteTracking;

- (void)resumeRouteTracking;

- (void)endRouteTracking;

- (NSTimeInterval)routeDurationWithUnit:(TimeUnit)timeUnit;

- (NSString *)routeDurationString;

- (CLLocationDistance)totalDistanceWithUnit:(DistanceUnit)distanceUnit;

- (CLLocationDistance)averageAltitudeWithUnit:(DistanceUnit)distanceUnit;

- (CLLocationDistance)minimumAltitudeWithUnit:(DistanceUnit)distanceUnit;

- (CLLocationDistance)maximumAltitudeWithUnit:(DistanceUnit)distanceUnit;

- (CLLocationSpeed)averageSpeedWithUnit:(SpeedUnit)speedUnit;

- (CLLocationSpeed)topSpeedWithUnit:(SpeedUnit)speedUnit;

@end
