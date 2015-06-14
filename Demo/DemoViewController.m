//
//  DemoViewController.m
//  Follower
//
//  Created by Mike on 6/10/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "DemoViewController.h"
#import <UIView+Facade.h>

@interface DemoViewController () {
    BOOL _tracking;
}

@end

@implementation DemoViewController


#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:13/255.0 green:14/255.0 blue:20/255.0 alpha:1.0];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.follower = [Follower new];
    self.follower.delegate = self;

    self.mapView = [MKMapView new];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.layer.cornerRadius = 7.0;
    self.mapView.clipsToBounds = YES;
    [self.view addSubview:self.mapView];

    self.maskView = [UIView new];
    self.maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    [self.mapView addSubview:self.maskView];

    self.avatarImageView = [UIImageView new];
    self.avatarImageView.image = [UIImage imageNamed:@"avatar"];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 30.0;
    self.avatarImageView.layer.borderWidth = 1.0;
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.maskView addSubview:self.avatarImageView];

    self.dateLabel = [UILabel new];
    self.dateLabel.text = @"July 17th, 2015";
    self.dateLabel.font = [UIFont fontWithName:@"Raleway-Bold" size:19];
    self.dateLabel.textColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1.0];
    [self.maskView addSubview:self.dateLabel];

    self.cycleImageView = [UIImageView new];
    self.cycleImageView.image = [UIImage imageNamed:@"cycle"];
    [self.maskView addSubview:self.cycleImageView];

    self.trackingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.trackingButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.trackingButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [self.trackingButton setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [self.trackingButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.maskView addSubview:self.trackingButton];

    self.containerView = [UIView new];
    [self.view addSubview:self.containerView];

    self.timeView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"time"] title:@"Elapsed Time" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.timeView];

    self.topSpeedView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"topSpeed"] title:@"Top Speed" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.topSpeedView];

    self.averageSpeedView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"avgSpeed"] title:@"Avg. Speed" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.averageSpeedView];

    self.distanceView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"distance"] title:@"Distance" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.distanceView];

    self.averageAltitudeView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"avgAlt"] title:@"Avg. Altitude" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.averageAltitudeView];

    self.maxAltitudeView = [[MetricView alloc] initWithImage:[UIImage imageNamed:@"maxAlt"] title:@"Max Altitude" color:[UIColor whiteColor]];
    [self.containerView addSubview:self.maxAltitudeView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self.mapView anchorTopCenterFillingWidthWithLeftAndRightPadding:10 topPadding:20 height:250];
    [self.maskView anchorTopCenterFillingWidthWithLeftAndRightPadding:0 topPadding:0 height:75];
    [self.avatarImageView anchorCenterLeftWithLeftPadding:10 width:60 height:60];
    [self.dateLabel alignToTheRightOf:self.avatarImageView matchingTopAndFillingWidthWithLeftAndRightPadding:10 height:20];
    [self.cycleImageView alignUnder:self.dateLabel matchingLeftWithTopPadding:3 width:40 height:40];
    [self.trackingButton anchorCenterRightWithRightPadding:10 width:60 height:60];

    [self.containerView alignUnder:self.mapView centeredFillingWidthAndHeightWithLeftAndRightPadding:10 topAndBottomPadding:10];
    [self.containerView groupGrid:@[self.topSpeedView, self.averageSpeedView, self.distanceView, self.timeView, self.averageAltitudeView, self.maxAltitudeView] fillingWidthWithColumnCount:3 spacing:10];
}


#pragma mark - Follower

- (void)start {
    _tracking = YES;

    [self.trackingButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    [self.trackingButton removeTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.trackingButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];

    [self.follower beginRouteTracking];
}

- (void)stop {
    _tracking = NO;

    [self.trackingButton setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [self.trackingButton removeTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [self.trackingButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];

    [self.follower endRouteTracking];

    [_mapView addOverlay:self.follower.routePolyline];
    [_mapView setRegion:self.follower.routeRegion animated:YES];
}

- (void)followerDidUpdate:(Follower *)follower {
    self.topSpeedView.valueLabel.text = [NSString stringWithFormat:@"%.1f mph", [follower topSpeedWithUnit:SpeedUnitMilesPerHour]];
    self.averageSpeedView.valueLabel.text = [NSString stringWithFormat:@"%.1f mph", [follower averageSpeedWithUnit:SpeedUnitMilesPerHour]];
    self.timeView.valueLabel.text = [follower routeDurationString];
    self.distanceView.valueLabel.text = [NSString stringWithFormat:@"%.2f mi", [follower totalDistanceWithUnit:DistanceUnitMiles]];
    self.averageAltitudeView.valueLabel.text = [NSString stringWithFormat:@"%.0f ft", [follower averageAltitudeWithUnit:DistanceUnitFeet]];
    self.maxAltitudeView.valueLabel.text = [NSString stringWithFormat:@"%.0f ft", [follower maximumAltitudeWithUnit:DistanceUnitFeet]];
}


#pragma mark - Map view delegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.fillColor = [UIColor colorWithRed:250/255.0 green:90/255.0 blue:45/255.0 alpha:1.0];
    renderer.strokeColor = [UIColor colorWithRed:250/255.0 green:90/255.0 blue:45/255.0 alpha:1.0];
    renderer.lineWidth = 5;
    return renderer;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (_tracking) {
        [mapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(.0005, .0005)) animated:YES];
    }
}


#pragma mark - Utils

- (UILabel *)newLabelWithColor:(UIColor *)color {
    UILabel *label = [UILabel new];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor redColor];
    return label;
}

@end
