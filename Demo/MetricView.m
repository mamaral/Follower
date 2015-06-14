//
//  MetricView.m
//  Follower
//
//  Created by Mike on 6/13/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "MetricView.h"
#import <UIView+Facade.h>

@implementation MetricView

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title color:(UIColor *)color {
    self = [super init];

    self.layer.cornerRadius = 7.0;
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 1.0;

    self.iconImageView = [UIImageView new];
    self.iconImageView.image = image;
    [self addSubview:self.iconImageView];

    self.titleLabel = [UILabel new];
    self.titleLabel.text = [title uppercaseString];
    self.titleLabel.textColor = [UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"Raleway-Bold" size:11];
    [self addSubview:self.titleLabel];

    self.valueLabel = [UILabel new];
    self.valueLabel.textColor = color;
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.font = [UIFont fontWithName:@"Raleway" size:22];
    [self addSubview:self.valueLabel];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.titleLabel anchorTopCenterFillingWidthWithLeftAndRightPadding:0 topPadding:10 height:18];
    [self.valueLabel alignUnder:self.titleLabel centeredFillingWidthWithLeftAndRightPadding:0 topPadding:4 height:24];
    [self.iconImageView alignUnder:self.valueLabel matchingCenterWithTopPadding:9 width:25 height:25];
}

@end
