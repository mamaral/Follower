//
//  DemoViewController.h
//  Follower
//
//  Created by Mike on 6/10/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Follower.h"
#import "MetricView.h"

@interface DemoViewController : UIViewController <MKMapViewDelegate, FollowerDelegate>

@property (nonatomic, strong) Follower *follower;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *cycleImageView;
@property (nonatomic, strong) UIButton *trackingButton;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) MetricView *timeView;
@property (nonatomic, strong) MetricView *topSpeedView;
@property (nonatomic, strong) MetricView *averageSpeedView;
@property (nonatomic, strong) MetricView *distanceView;
@property (nonatomic, strong) MetricView *averageAltitudeView;
@property (nonatomic, strong) MetricView *maxAltitudeView;

@end
