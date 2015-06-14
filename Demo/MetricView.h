//
//  MetricView.h
//  Follower
//
//  Created by Mike on 6/13/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MetricView : UIView

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title color:(UIColor *)color;

@end
