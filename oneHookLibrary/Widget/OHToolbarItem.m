//
//  OHToolbarItem.m
//  oneHookLibrary
//
//  Created by Eagle Diao@ToMore on 2016-06-05.
//  Copyright © 2016 oneHook inc. All rights reserved.
//

#import "OHToolbarItem.h"

@implementation OHToolbarItem

+(instancetype) createToolbarActionButton {
        OHToolbarItem* button = [[OHToolbarItem alloc] init];
        //    button.titleLabel.font = FONT_AWESOME_ICON(20);
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        [button setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2] forState:UIControlStateHighlighted];
        
        [button setTitleColor:[UIColor whiteColor]                    forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor]                    forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor]                    forState:UIControlStateDisabled];
        
        return button;
        
}
@end
