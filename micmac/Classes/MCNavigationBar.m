//
//  MCNavigationBar.m
//  micmac
//
//  Created by Bryce Pauken on 2/1/15.
//  Copyright (c) 2015 Kingfish. All rights reserved.
//

#import "MCNavigationBar.h"

@interface MCNavigationBar()

@property (nonatomic, strong) UIView *bottomOverlay;
@property (nonatomic, copy) void (^dropDownBlock)();
@property (nonatomic, strong) UIView *dropDownIndicator;
@property (nonatomic, strong) CAShapeLayer *dropDownPathLayer;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, copy) void (^leftButtonTapped)();
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, copy) void (^rightButtonTapped)();
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *titleScrollView;

@end

@implementation MCNavigationBar

static const int dropDownIndicatorHeight = 4;
static const int dropDownIndicatorWidth = 8;
static const int titleScrollViewHeight = 40;
static const int titleScrollViewSpacing = 120;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [_leftButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_leftButton setHidden:YES];
        
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [_rightButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton setHidden:YES];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        [_pageControl setCurrentPage:0];
        [_pageControl setHidden:YES];
        [_pageControl setTransform:CGAffineTransformMakeScale(0.75, 0.75)];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
        [_titleLabel setClipsToBounds:NO];
        [_titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:20]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor MCOffWhiteColor]];
        UILongPressGestureRecognizer *titleTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(titleTapped:)];
        [titleTapRecognizer setMinimumPressDuration:0.001];
        [_titleLabel addGestureRecognizer:titleTapRecognizer];
        
        _dropDownIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dropDownIndicatorWidth, dropDownIndicatorHeight)];
        UIBezierPath *dropDownPath = [[UIBezierPath alloc] init];
        [dropDownPath moveToPoint:CGPointMake(_dropDownIndicator.bounds.size.width/2, _dropDownIndicator.bounds.size.height)];
        [dropDownPath addLineToPoint:CGPointMake(_dropDownIndicator.bounds.size.width, 0)];
        [dropDownPath addLineToPoint:CGPointZero];
        [dropDownPath closePath];
        _dropDownPathLayer = [[CAShapeLayer alloc] init];
        [_dropDownPathLayer setFillColor:[UIColor MCOffWhiteColor].CGColor];
        [_dropDownPathLayer setFrame:_dropDownIndicator.bounds];
        [_dropDownPathLayer setPath:dropDownPath.CGPath];
        [_dropDownIndicator setHidden:YES];
        [_dropDownIndicator.layer addSublayer:_dropDownPathLayer];
        [_titleLabel addSubview:_dropDownIndicator];
        
        _bottomOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 4)];
        [_bottomOverlay setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
        [_bottomOverlay setBackgroundColor:[UIColor MCMainColor]];
        
        [self setBackgroundColor:[UIColor MCMainColor]];
        
        [self addSubview:_leftButton];
        [self addSubview:_rightButton];
        [self addSubview:_pageControl];
        [self addSubview:_titleLabel];
        [self addSubview:_bottomOverlay];
        
        [self setFrame:self.frame];
    }
    return  self;
}

- (void)buttonTapped:(UIButton *)sender {
    if(sender == self.leftButton && self.leftButtonTapped) {
        self.leftButtonTapped();
    }
    else if(sender == self.rightButton && self.rightButtonTapped) {
        self.rightButtonTapped();
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(!self.leftButton.hidden && CGRectContainsPoint(CGRectInset(self.leftButton.frame, -20, -20), point)) {
        return self.leftButton;
    }
    if(!self.rightButton.hidden && CGRectContainsPoint(CGRectInset(self.rightButton.frame, -20, -20), point)) {
        return self.rightButton;
    }
    if(!self.titleLabel.hidden && CGRectContainsPoint(CGRectInset(self.titleLabel.frame, -20, -20), point)) {
        return self.titleLabel;
    }
    return [super hitTest:point withEvent:event];
}

+ (UIImage *)maskImageFromImage:(UIImage *)image {
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, image.scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [image drawInRect:imageRect];
    CGContextSetFillColorWithColor(ctx, [UIColor MCOffWhiteColor].CGColor);
    
    CGContextSetBlendMode(ctx, kCGBlendModeSourceAtop);
    CGContextFillRect(ctx, imageRect);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (void)setDropDownBlock:(void (^)())dropDownBlock {
    _dropDownBlock = dropDownBlock;
    [self.dropDownIndicator setHidden:!dropDownBlock];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGFloat buttonMargin = ((self.bounds.size.height-20)-self.leftButton.bounds.size.height)/2;
    [self.leftButton setFrame:CGRectMake(buttonMargin, buttonMargin+20, self.rightButton.bounds.size.width, self.leftButton.bounds.size.height)];
    [self.rightButton setFrame:CGRectMake(self.bounds.size.width-self.rightButton.bounds.size.width-buttonMargin, buttonMargin+20, self.rightButton.bounds.size.width, self.rightButton.bounds.size.height)];
    
    [self.pageControl setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height-10)];
    
    [self updateBottomOverlayMask];
}

- (void)setLeftButtonImage:(UIImage *)image {
    if(image) {
        [self.leftButton setImage:[[self class] maskImageFromImage:image] forState:UIControlStateNormal];
    }
    [self.leftButton setHidden:!image];
}

- (void)setPage:(NSInteger)page {
    [self.pageControl setCurrentPage:page];
}

- (void)setRightButtonImage:(UIImage *)image {
    if(image) {
        [self.rightButton setImage:[[self class] maskImageFromImage:image] forState:UIControlStateNormal];
    }
    [self.rightButton setHidden:!image];
}

- (void)setScrollFactor:(CGFloat)factor {
    if(self.titleScrollView) {
        [self.titleScrollView setContentOffset:CGPointMake(factor*self.titleScrollView.bounds.size.width, 0)];
        
        for(UIView *view in self.titleScrollView.subviews) {
            [view setAlpha:MIN(1, MAX(0, factor<=view.tag?factor-(view.tag-1):(view.tag+1)-factor))];
        }
    }
}

- (void)setTitle:(NSString *)title {
    [self.titleLabel setHidden:NO];
    if(self.titleScrollView && self.titleScrollView.superview) {
        [self.titleScrollView removeFromSuperview];
    }
    [self setTitleScrollView:nil];
    
    CGFloat verticalCenter = 20+(self.bounds.size.height-20)/2;
    [self.titleLabel setText:title];
    [self.titleLabel sizeToFit];
    [self.titleLabel setCenter:CGPointMake(self.bounds.size.width/2, verticalCenter)];
    [self.dropDownIndicator setCenter:CGPointMake(self.titleLabel.bounds.size.width+10, self.titleLabel.bounds.size.height/2)];
    
    [self.pageControl setHidden:YES];
}

- (void)setTitles:(NSArray *)titles {
    [self.titleLabel setHidden:YES];
    for(UIGestureRecognizer *recognizer in self.titleLabel.gestureRecognizers) {
        [self.titleLabel removeGestureRecognizer:recognizer];
    }
    if(self.titleScrollView && self.titleScrollView.superview) {
        [self.titleScrollView removeFromSuperview];
    }
    CGFloat verticalCenter = 20+(self.bounds.size.height-20)/2;
    [self setTitleScrollView:[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, titleScrollViewSpacing, titleScrollViewHeight)]];
    [self.titleScrollView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    [self.titleScrollView setClipsToBounds:NO];
    [self.titleScrollView setContentSize:CGSizeMake(titleScrollViewSpacing*titles.count, titleScrollViewHeight)];
    [self.titleScrollView setScrollEnabled:NO];
    [self.titleScrollView setShowsHorizontalScrollIndicator:NO];
    [self.titleScrollView setShowsVerticalScrollIndicator:NO];
    for(int i=0;i<titles.count;i++) {
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setAlpha:i==0?1:0];
        [titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:18]];
        [titleLabel setTag:i];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setTextColor:[UIColor MCOffWhiteColor]];
        [titleLabel setText:[titles objectAtIndex:i]];
        [titleLabel sizeToFit];
        [titleLabel setCenter:CGPointMake(titleScrollViewSpacing/2+titleScrollViewSpacing*i, titleScrollViewHeight/2)];
        [self.titleScrollView addSubview:titleLabel];
    }
    [self addSubview:self.titleScrollView];
    [self.titleScrollView setCenter:CGPointMake(self.bounds.size.width/2, verticalCenter-6)];
    
    [self.pageControl setHidden:NO];
    [self.pageControl setNumberOfPages:titles.count];
    
    [self setFrame:self.frame];
}

- (void)titleTapped:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(self.dropDownBlock) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self.titleLabel setTextColor:[UIColor MCMoreOffWhiteColor]];
            [self.dropDownPathLayer setFillColor:[UIColor MCMoreOffWhiteColor].CGColor];
        }
        else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self.titleLabel setTextColor:[UIColor MCOffWhiteColor]];
            [self.dropDownPathLayer setFillColor:[UIColor MCOffWhiteColor].CGColor];
        }
        [CATransaction commit];
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            self.dropDownBlock();
        }
    }
}

- (void)updateBottomOverlayMask {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, self.bottomOverlay.bounds.size.height)];
    [path addCurveToPoint:CGPointMake(self.bottomOverlay.bounds.size.width*0.25, 0) controlPoint1:CGPointMake(0, 0) controlPoint2:CGPointMake(self.bottomOverlay.bounds.size.width*0.125, 0)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width*0.75, 0)];
    [path addCurveToPoint:CGPointMake(self.bottomOverlay.bounds.size.width, self.bottomOverlay.bounds.size.height) controlPoint1:CGPointMake(self.bottomOverlay.bounds.size.width*0.875, 0) controlPoint2:CGPointMake(self.bottomOverlay.bounds.size.width, 0)];
    [path addLineToPoint:CGPointMake(self.bottomOverlay.bounds.size.width, 0)];
    [path closePath];
    
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    [mask setPath:path.CGPath];
    [self.bottomOverlay.layer setMask:mask];
}

@end
