//
//  Follower.m
//  Follower
//
//  Created by Mike on 6/10/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "Follower.h"

static CGFloat const kRegionPaddingMultiplier = 1.33;

static NSTimeInterval const kSecondsPerMinute = 60.0;
static NSTimeInterval const kSecondsPerHour = 3600.0;

static CLLocationDistance const kMetersPerKilometer = 1000.0;
static CLLocationDistance const kMetersPerFoot = 0.3048;
static CLLocationDistance const kMetersPerMile = 1609.344;

static CLLocationSpeed const kMpsToKph = 3.6;
static CLLocationSpeed const kMpsToMph = 2.2369;

@interface Follower () <CLLocationManagerDelegate>

// Location manager
//
@property (nonatomic, strong) CLLocationManager *locationManager;

// Time
//
@property (nonatomic, strong) NSDate *segmentStartDate;
@property (nonatomic) NSTimeInterval completedSegmentsDuration;

// Speed
//
@property (nonatomic) CLLocationSpeed totalSpeed;
@property (nonatomic) CLLocationSpeed topSpeed;

// Distance
//
@property (nonatomic, strong) CLLocation *previousLocation;
@property (nonatomic) CLLocationDistance totalDistance;

// Altitude
//
@property (nonatomic) CLLocationDistance totalAltitude;
@property (nonatomic) CLLocationDistance minimumAltitude;
@property (nonatomic) CLLocationDistance maximumAltitude;

// Coordinates
//
@property (nonatomic) CLLocationDegrees minimumLatitude;
@property (nonatomic) CLLocationDegrees maximumLatitude;
@property (nonatomic) CLLocationDegrees minimumLongitude;
@property (nonatomic) CLLocationDegrees maximumLongitude;

@end

@implementation Follower


#pragma mark - Initialization

- (instancetype)init {
    self = [super init];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.activityType = CLActivityTypeFitness;

    [self resetMetrics];

    return self;
}

- (void)resetMetrics {
    _routeLocations = [NSMutableArray array];
    _routePolyline = nil;
    _trackingState = TrackingStateOff;

    self.completedSegmentsDuration = 0.0;
    
    self.totalSpeed = 0.0;
    self.topSpeed = 0.0;

    self.totalDistance = 0.0;

    self.totalAltitude = 0.0;
    self.minimumAltitude = DBL_MAX;
    self.maximumAltitude = 0.0;

    self.minimumLatitude = 91;
    self.maximumLatitude = -91;
    self.minimumLongitude = 181;
    self.maximumLongitude = -191;
}


#pragma mark - Route tracking state

- (void)beginRouteTracking {
    NSAssert(_trackingState == TrackingStateOff, @"You can only begin route tracking once. If you want to begin");

    [self resetMetrics];

    _trackingState = TrackingStateTracking;

    self.segmentStartDate = [NSDate date];

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }

    [self.locationManager startUpdatingLocation];
}

- (void)pauseRouteTracking {
    NSAssert(_trackingState == TrackingStateTracking, @"You can only pause Follower tracking when it is actively tracking.");

    _trackingState = TrackingStatePaused;

    self.completedSegmentsDuration += [[NSDate date] timeIntervalSinceDate:self.segmentStartDate];
    self.segmentStartDate = nil;

    [self.locationManager stopUpdatingLocation];
}

- (void)resumeRouteTracking {
    NSAssert(_trackingState == TrackingStatePaused, @"You can only resume Follower tracking when it is paused.");

    _trackingState = TrackingStateTracking;

    self.segmentStartDate = [NSDate date];

    [self.locationManager startUpdatingLocation];
}

- (void)endRouteTracking {
    NSAssert(_trackingState != TrackingStateOff, @"You can only stop Follower tracking when it is actively tracking or paused.");

    _trackingState = TrackingStateOff;

    // If we have a start date to the segment, add the interval to our total duration. This check is
    // because we might have ended route tracking from the "paused" state, in which case we don't need
    // to add any time.
    //
    if (self.segmentStartDate) {
        self.completedSegmentsDuration += [[NSDate date] timeIntervalSinceDate:self.segmentStartDate];
        self.segmentStartDate = nil;
    }

    [self.locationManager stopUpdatingLocation];

    [self createPolylineForRoute];
    [self createRegionForRoute];
}


#pragma mark - Calculations

- (void)handleLocationUpdate:(CLLocation *)location {
    // Speed
    //
    CLLocationSpeed speed = location.speed;
    self.totalSpeed += speed;

    if (speed > self.topSpeed) {
        self.topSpeed = speed;
    }

    // Distance
    //
    self.totalDistance += [location distanceFromLocation:self.previousLocation];
    self.previousLocation = location;

    // Altitude
    //
    CLLocationDistance altitude = location.altitude;
    self.totalAltitude += altitude;

    if (altitude < self.minimumAltitude) {
        self.minimumAltitude = altitude;
    }

    if (altitude > self.maximumAltitude) {
        self.maximumAltitude = altitude;
    }

    // Coordinates
    //
    CLLocationCoordinate2D coord = location.coordinate;
    CLLocationDegrees latitude = coord.latitude;
    CLLocationDegrees longitude = coord.longitude;

    if (latitude > self.maximumLatitude) {
        self.maximumLatitude = latitude;
    }

    if (latitude < self.minimumLatitude) {
        self.minimumLatitude = latitude;
    }

    if (longitude < self.minimumLongitude) {
        self.minimumLongitude = longitude;
    }

    if (longitude > self.maximumLongitude) {
        self.maximumLongitude = longitude;
    }

    // Delegate
    //
    if ([self.delegate respondsToSelector:@selector(followerDidUpdate:)]) {
        [self.delegate followerDidUpdate:self];
    }
}

- (void)createRegionForRoute {
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((self.minimumLatitude + self.maximumLatitude) / 2.0, (self.minimumLongitude + self.maximumLongitude) / 2.0);
    MKCoordinateSpan span = MKCoordinateSpanMake((self.maximumLatitude - self.minimumLatitude) * kRegionPaddingMultiplier, (self.maximumLongitude - self.minimumLongitude) * kRegionPaddingMultiplier);

    _routeRegion = MKCoordinateRegionMake(centerCoordinate, span);
}

- (void)createPolylineForRoute {
    NSUInteger locationsCount = self.routeLocations.count;
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * locationsCount);

    for (NSUInteger i = 0; i < locationsCount; i++) {
        CLLocation *location = self.routeLocations[i];
        coords[i] = location.coordinate;
    }

    _routePolyline = [MKPolyline polylineWithCoordinates:coords count:locationsCount];
}


#pragma mark - Time calculations

- (NSTimeInterval)routeDuration {
    switch (self.trackingState) {

        // If we're between intervals, we can simply return the route duration
        // calculated up until this point.
        case TrackingStateOff:
        case TrackingStatePaused:
            return self.completedSegmentsDuration;

        // If we're currently in the middle of a segment, combine the previous
        // total route duration with the current segment's elapsed time.
        case TrackingStateTracking:
            return self.completedSegmentsDuration + [[NSDate date] timeIntervalSinceDate:self.segmentStartDate];
    }
}

- (NSTimeInterval)routeDurationWithUnit:(TimeUnit)timeUnit {
    switch (timeUnit) {
        case TimeUnitSeconds:
            return self.routeDuration;

        case TimeUnitMinutes:
            return self.routeDuration / kSecondsPerMinute;

        case TimeUnitHours:
            return self.routeDuration / kSecondsPerHour;
    }
}

- (NSString *)routeDurationString {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.routeDuration];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:self.routeDuration < kSecondsPerHour ? @"mm:ss" : @"HH:mm:ss"];
    
    return [dateFormatter stringFromDate:date];
}


#pragma mark - Speed calculations

- (CLLocationSpeed)averageSpeedWithUnit:(SpeedUnit)speedUnit {
    CLLocationSpeed averageSpeed = self.totalSpeed / (float)self.routeLocations.count;

    return [self convertedSpeed:averageSpeed withUnit:speedUnit];
}

- (CLLocationSpeed)topSpeedWithUnit:(SpeedUnit)speedUnit {
    return [self convertedSpeed:self.topSpeed withUnit:speedUnit];
}

- (CLLocationSpeed)convertedSpeed:(CLLocationSpeed)speed withUnit:(SpeedUnit)speedUnit {
    switch (speedUnit) {
        case SpeedUnitMetersPerSecond:
            return speed;

        case SpeedUnitKilometersPerHour:
            return speed * kMpsToKph;

        case SpeedUnitMilesPerHour:
            return speed * kMpsToMph;
    }
}


#pragma mark - Distance calculations

- (CLLocationDistance)totalDistanceWithUnit:(DistanceUnit)distanceUnit {
    return [self convertedDistance:self.totalDistance withUnit:distanceUnit];
}


#pragma mark - Altitude calculations

- (CLLocationDistance)averageAltitudeWithUnit:(DistanceUnit)distanceUnit {
    CLLocationDistance averageAltitude = self.totalAltitude / (float)self.routeLocations.count;

    return [self convertedDistance:averageAltitude withUnit:distanceUnit];
}

- (CLLocationDistance)minimumAltitudeWithUnit:(DistanceUnit)distanceUnit {
    return [self convertedDistance:self.minimumAltitude withUnit:distanceUnit];
}

- (CLLocationDistance)maximumAltitudeWithUnit:(DistanceUnit)distanceUnit {
    return [self convertedDistance:self.maximumAltitude withUnit:distanceUnit];
}


#pragma mark - Utils

- (CLLocationDistance)convertedDistance:(CLLocationDistance)distance withUnit:(DistanceUnit)distanceUnit {
    switch (distanceUnit) {
        case DistanceUnitMeters:
            return distance;

        case DistanceUnitKilometers:
            return distance / kMetersPerKilometer;

        case DistanceUnitFeet:
            return distance / kMetersPerFoot;

        case DistanceUnitMiles:
            return distance / kMetersPerMile;
    }
}


#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.routeLocations addObjectsFromArray:locations];

    for (CLLocation *location in locations) {
        [self handleLocationUpdate:location];
    }
}


#pragma mark - Debugging

- (NSString *)debugDescription {
    NSString *trackingState;

    switch (_trackingState) {
        case TrackingStateOff:
            trackingState = @"Off";
            break;
        case TrackingStatePaused:
            trackingState = @"Paused";
            break;
        case TrackingStateTracking:
            trackingState = @"Tracking";
    }

    NSUInteger locationCount = self.routeLocations.count;

    return @{
             @"tracking state": trackingState,
             @"route duration (seconds)": @([self routeDuration]),
             @"total distance (meters)": @(self.totalDistance),
             @"minimum altitude (meters)": @(self.minimumAltitude),
             @"maximum altitude (meters)": @(self.maximumAltitude),
             @"average altitude (meters)": @(self.totalAltitude / (float)locationCount),
             @"top speed (m/s)": @(self.topSpeed),
             @"average speed (m/s)": @(self.totalSpeed / (float)locationCount),
             @"location count": @(locationCount)
             }.description;
}

@end
