//
//  OHViewControllerWithToolbar.m
//  oneHookLibrary
//
//  Created by Eagle Diao@ToMore on 2016-06-05.
//  Copyright © 2016 oneHook inc. All rights reserved.
//

#import "OHViewController.h"
#import "OneHookFoundation.h"


//#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define FLOATING_ACTION_BUTTON_ANIMATION_THRESHOLD 24
#define FAB_STATE_TOP 0
#define FAB_STATE_BOTTOM 1
#define DEBUGGIN NO

@interface OHViewController() {
    CGFloat _lastWidth;
    CGFloat _lastHeight;
    CGFloat _toolbarHeight;
    CGFloat _scrollViewLastContentOffsetY;
    CGFloat _pullToRefreshProgress;
    
    CGFloat _yOffsetBeforeOrientationChange;
}


@end

@implementation OHViewController

- (id)init
{
    self = [super init];
    if(self) {
        [self commonInit];
        
    }
    return self;
}

- (id)initWithStyle:(OHViewControllerToolbarStyle)style
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
#ifdef DEBUG
        NSLog(@"%@ ALLOC <%p>", [self class], self);
#endif
        [self commonInit];
        _toolbarStyle = style;
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"%@ DEALLOC <%p>", [self class], self);
#endif
}

- (void)commonInit
{
    self.toolbarExtension = 0;
    self.toolbarExternsionFixed = NO;
    self.toolbarCanBounce = NO;
    self.padding = UIEdgeInsetsMake(0, 0, 0, 0);
    self.toolbarShouldStay = NO;
    self.toolbarShouldAutoExpandOrCollapse = YES;
    self.floatingActionButtonStyle = OHViewControllerFloatingActionButtonStyleDefault;
    self.hasPullToRefresh = NO;
    self.pullToRefreshTriggerOffset = 100;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = UIColor.whiteColor;
    if(self.toolbarStyle != OHViewControllerNoToolbar) {
        [self _setupToolbar];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray* originalViews = self.view.subviews;
    self.view.accessibilityElements = originalViews;
    [self.view bringSubviewToFront:self.toolbar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)_setupToolbar
{
    self.toolbar = [[OHToolbar alloc] init];
    
    self.toolbar.showStatusBar = SHOW_STATUS_BAR;
    [self.view addSubview:self.toolbar];
    
    [self toolbarDidLoad:self.toolbar];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    _yOffsetBeforeOrientationChange = self.contentScrollableView.contentOffset.y;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if(size.width > size.height) {
            /* new size is land */
        } else {
            /* new size is port */
            self.contentScrollableView.contentOffset = CGPointMake(self.contentScrollableView.contentOffset.x,
                                                                   self.contentScrollableView.contentOffset.y - kSystemStatusBarHeight);
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)setToolbarExtension:(CGFloat)toolbarExtension {
    if (_toolbarExtension != toolbarExtension) {
        _toolbarExtension = toolbarExtension;
        CGFloat toolbarMaximumHeight = [self defaultToolbarHeight] + _toolbarExtension;
        _toolbarHeight = toolbarMaximumHeight;
        _scrollViewLastContentOffsetY = -toolbarMaximumHeight;
        _contentScrollableView.contentInset = UIEdgeInsetsMake(self.padding.top + toolbarMaximumHeight,
                                                               self.padding.left,
                                                               self.padding.bottom + kMinimumBottomMargin,
                                                               self.padding.right);
        
        if (self.viewLoaded) {
            CGFloat width = CGRectGetWidth(self.view.bounds);
            self.toolbar.frame = CGRectMake(0, 0, width, _toolbarHeight);
        }
    }
}

- (void)viewWillLayoutSubviews
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    if(_lastWidth != width && _lastHeight != height) {
        CGFloat toolbarMaximumHeight = [self defaultToolbarHeight] + self.toolbarExtension;
        
        if(_contentScrollableView) {
            _contentScrollableView.frame = self.view.bounds;
            _contentScrollableView.contentInset = UIEdgeInsetsMake(self.padding.top + toolbarMaximumHeight,
                                                                   self.padding.left,
                                                                   self.padding.bottom + kMinimumBottomMargin,
                                                                   self.padding.right);
        } else {
#ifdef DEBUG
            NSLog(@"Warning: content scrollable view is not set");
#endif
        }
        
        if(_lastWidth == 0) {
            _toolbarHeight = toolbarMaximumHeight;
            _scrollViewLastContentOffsetY = -toolbarMaximumHeight;
            self.contentScrollableView.contentOffset = CGPointMake(0, -toolbarMaximumHeight);
        }
        if(self.toolbarStyle == OHViewControllerHasToolbar) {
            if(_contentScrollableView) {
                [self scrollViewDidScroll:_contentScrollableView];
            } else {
                self.toolbar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.maximumToolbarHeight);
                [self toolbarDidLayout:self.toolbar];
            }
        }
        
        _lastWidth = width;
        _lastHeight = height;
    }
}

- (void)setContentScrollableView:(UIScrollView *)contentScrollableView
{
    _contentScrollableView = contentScrollableView;
    
    /* we are manually calculating top inset for all platforms and all different devices */
    if (@available(iOS 11.0, *)) {
        _contentScrollableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _contentScrollableView.delegate = self;
}

- (void)_doExpandOrCollapse
{
    CGFloat statusBarHeight = self.toolbar.showStatusBar ? kSystemStatusBarHeight : 0;
    CGFloat toolbarDefaultHeight = [self defaultToolbarHeight];
    CGFloat toolbarMinimumHeight = self.toolbarShouldStay ? toolbarDefaultHeight : statusBarHeight;
    if(self.toolbarExternsionFixed && self.toolbarExtension > 0) {
        toolbarMinimumHeight += self.toolbarExtension;
        toolbarDefaultHeight += self.toolbarExtension;
    }
    
    /* take care toolbar expand or collapse */
    if(_toolbarHeight < toolbarDefaultHeight) {
        CGFloat progress = _toolbarHeight / toolbarDefaultHeight;
        CGFloat targetHeight = _toolbarHeight;
        BOOL expand = NO;
        if(progress < 0.5) {
            targetHeight = toolbarMinimumHeight;
        } else {
            expand = YES;
            targetHeight = toolbarDefaultHeight;
        }
        
        CGRect finalFrame = CGRectMake(0,
                                       0,
                                       CGRectGetWidth(self.view.bounds),
                                       targetHeight);
        
        [UIView animateWithDuration:0.15 animations:^{
            [self toolbar:self.toolbar willLayoutTo:finalFrame expand:expand];
            self.toolbar.frame = finalFrame;
        } completion:^(BOOL finished) {
            self->_toolbarHeight = targetHeight;
        }];
    }
}

- (CGFloat)defaultToolbarHeight
{
    if (self.toolbarStyle == OHViewControllerNoToolbar) {
        return 0.0f;
    }
    
    CGFloat statusBarHeight = self.toolbar.showStatusBar ? kSystemStatusBarHeight : 0;
    CGFloat toolbarDefaultHeight = statusBarHeight + kToolbarDefaultHeight;
    return toolbarDefaultHeight;
}

- (CGFloat)maximumToolbarHeight
{
    return self.defaultToolbarHeight + self.toolbarExtension;
}

- (CGFloat)currentToolbarHeight
{
    return _toolbarHeight;
}

- (void)endRefreshing
{
    _isRefreshing = NO;
    _pullToRefreshProgress = 0;
}

#pragma mark - for child class to implement

- (void)toolbar:(OHToolbar *)toolbar willLayoutTo:(CGRect)frame expand:(BOOL)isExpand
{
    
}

- (void)toolbarDidLoad:(OHToolbar *)toolbar
{
    self.toolbar.layer.shadowOffset = CGSizeMake(0, 3);
    self.toolbar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.toolbar.layer.shadowRadius = 1.5;
    self.toolbar.layer.shadowOpacity = .2;
}

- (void)toolbarDidLayout:(OHToolbar *)toolbar
{
    
}

- (void)willStartPullToRefresh:(CGFloat)progress starting:(BOOL)starting
{
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView != self.contentScrollableView) {
        return;
    }
    if(self.toolbarStyle != OHViewControllerHasToolbar) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    //CGFloat height = CGRectGetHeight(self.view.bounds);
    
    CGFloat yOffset = scrollView.contentOffset.y + self.padding.top;
    CGFloat yDiff = yOffset - _scrollViewLastContentOffsetY;
    
    CGFloat statusBarHeight = self.toolbar.showStatusBar ? kSystemStatusBarHeight : 0;
    CGFloat toolbarDefaultHeight = [self defaultToolbarHeight];
    CGFloat toolbarMinimumHeight = self.toolbarShouldStay ? toolbarDefaultHeight : statusBarHeight;
    CGFloat toolbarMaximumHeight = toolbarDefaultHeight + self.toolbarExtension;
    
    
    if(self.toolbarExternsionFixed && self.toolbarExtension > 0) {
        toolbarMinimumHeight += self.toolbarExtension;
        toolbarDefaultHeight += self.toolbarExtension;
    }
    
    _toolbarHeight -= yDiff;
    
    if(!self.toolbarCanBounce && _toolbarHeight > toolbarMaximumHeight) {
        _toolbarHeight = toolbarMaximumHeight;
    }
    
    if(_toolbarHeight < toolbarMinimumHeight) {
        _toolbarHeight = toolbarMinimumHeight;
    }
    
    if(yOffset > -toolbarDefaultHeight && _toolbarHeight > toolbarDefaultHeight) {
        /* make sure reveal all toolbar only when at top */
        _toolbarHeight = toolbarDefaultHeight;
    } else if(yOffset < -toolbarDefaultHeight && _toolbarHeight != toolbarMaximumHeight) {
        /* when almost reach the top, make sure maximum height if in none-boucing mode */
        _toolbarHeight = self.toolbarCanBounce ? -yOffset : MIN(toolbarMaximumHeight, -yOffset);
    }
    
    if(DEBUGGIN) {
        NSLog(@"scroll view offset %f diff %f toolbar height %f maximum height %f", yOffset, yDiff, _toolbarHeight, toolbarMaximumHeight);
    }
    
    self.toolbar.frame = CGRectMake(0, 0, width, _toolbarHeight);
    
    if(self.hasPullToRefresh && _toolbarStyle == OHViewControllerHasToolbar && !_isRefreshing) {
        CGFloat overallOffset = -yOffset;
        if(overallOffset > toolbarMaximumHeight) {
            CGFloat pullToRefreshOffset = overallOffset - toolbarMaximumHeight;
            CGFloat progress = pullToRefreshOffset / self.pullToRefreshTriggerOffset;
            _pullToRefreshProgress = progress;
            [self willStartPullToRefresh:progress starting:NO];
        } else {
            [self willStartPullToRefresh:0 starting:NO];
        }
    }
    
    _scrollViewLastContentOffsetY = -yOffset;
    
    [self toolbarDidLayout:self.toolbar];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView != self.contentScrollableView) {
        return;
    }
    if(self.toolbarStyle != OHViewControllerHasToolbar) {
        return;
    }
    [self _doExpandOrCollapse];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView != self.contentScrollableView) {
        return;
    }
    if(self.toolbarStyle != OHViewControllerHasToolbar) {
        return;
    }
    if(!decelerate) {
        [self _doExpandOrCollapse];
    }
    
    if(_pullToRefreshProgress >= 1) {
        _isRefreshing = YES;
        [self willStartPullToRefresh:_pullToRefreshProgress starting:YES];
    }
}


@end
