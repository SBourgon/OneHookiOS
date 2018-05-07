//
//  OHGradientView.h
//  oneHookLibrary
//
//  Created by Eagle Diao on 2015-08-22.
//  Copyright (c) 2015 oneHook inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OHGradientView : UIView

- (instancetype _Nonnull) initWithHorizontalGradient;
- (instancetype _Nonnull) initWithVerticalGradient;
- (void)setGradientColorFrom:(UIColor* _Nonnull)fromColor to:(UIColor*_Nonnull)toColor;
- (void)setGradientColors:(NSArray*_Nonnull) colors forPoints:(NSArray<NSNumber *>* _Nonnull) points;

@end
