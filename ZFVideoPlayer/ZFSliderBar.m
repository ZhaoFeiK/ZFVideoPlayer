//
//  ZFSliderBar.m
//  ZFVideoPlayer
//
//  Created by zhaofei on 2017/3/4.
//  Copyright © 2017年 zbull. All rights reserved.
//

#import "ZFSliderBar.h"
#import "Masonry.h"

#define sliderHeight 4
#define dotSize 8

@implementation ZFSliderBar

- (instancetype)init {
    if (self = [super init]) {

        [self addSubview: self.bgView];
        [self addSubview: self.cacheIndicatorView];
        [self addSubview: self.playIndicatorView];
        [self addSubview: self.dotView];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.trailing.equalTo(self);
            make.centerY.equalTo(self);
            make.height.equalTo(@(sliderHeight));
        }];
        
        [self.cacheIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.bgView);
            make.centerY.equalTo(self.bgView);
            make.height.equalTo(self.bgView);
            make.trailing.equalTo(self.bgView.mas_leading);
        }];
        
        [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.bgView);
            make.centerY.equalTo(self.bgView);
            make.width.equalTo(@(dotSize));
            make.height.equalTo(@(dotSize));
        }];
        
        [self.playIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.bgView);
            make.centerY.equalTo(self.bgView);
            make.height.equalTo(@(sliderHeight));
            make.trailing.equalTo(self.dotView);
        }];
        
        [self addObserver:self forKeyPath: @"value" options: NSKeyValueObservingOptionNew context:nil];
        
        // 滑动手势
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(panGesture:)];
        [self addGestureRecognizer:panGesture];
        
        // 点击手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(tapGesture:)];
        [self addGestureRecognizer: tapGesture];
        
        [tapGesture requireGestureRecognizerToFail:panGesture];
    }
    return self;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor yellowColor];
        _bgView.layer.cornerRadius = sliderHeight * 0.5;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}

- (UIView *)cacheIndicatorView {
    if (!_cacheIndicatorView) {
        _cacheIndicatorView = [[UIView alloc] init];
        _cacheIndicatorView.backgroundColor = [UIColor purpleColor];
        _cacheIndicatorView.layer.cornerRadius = sliderHeight * 0.5;
        _cacheIndicatorView.clipsToBounds = YES;
    }
    return _cacheIndicatorView;
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
        _dotView.backgroundColor = [UIColor whiteColor];
        _dotView.layer.cornerRadius = dotSize * 0.5;
        _dotView.clipsToBounds = YES;
    }
    return _dotView;
}

- (UIView *)playIndicatorView {
    if (!_playIndicatorView) {
        _playIndicatorView = [[UIView alloc] init];
        _playIndicatorView.backgroundColor = [UIColor redColor];
        _playIndicatorView.layer.cornerRadius = dotSize * 0.5;
        _playIndicatorView.clipsToBounds = YES;
    }
    return _playIndicatorView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.cacheIndicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bgView.mas_leading).offset(_cachevalue * self.frame.size.width);
    }];
}

- (void)setValue:(float)value {
    _value = value;
}

- (void)setCachevalue:(float)cachevalue {
    _cachevalue = cachevalue;
    NSLog(@"cahcevalue: %f", _cachevalue);
    
    [self.cacheIndicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bgView.mas_leading).offset(_cachevalue * self.frame.size.width);
    }];

    [self.cacheIndicatorView setNeedsDisplay];
}

#pragma mark - Gesture recognizer
- (void)panGesture: (UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint location = [panGestureRecognizer locationInView: self];
    CGFloat x = location.x;
    if (x < 0 || x > self.frame.size.width) {
        return;
    }
    self.value = x / self.frame.size.width;
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.valueChangeDidFinishedBlock) {
            self.valueChangeDidFinishedBlock();
        }

    } else if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (self.dragDotBlock) {
            self.dragDotBlock();
        }
    }
}

- (void)tapGesture: (UITapGestureRecognizer *)tapGestureRecognizer {
    
    CGPoint location = [tapGestureRecognizer locationInView: self];
    CGFloat x = location.x;
    self.value = x / self.frame.size.width;

    if (self.valueChangeDidFinishedBlock) {
        self.valueChangeDidFinishedBlock();
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self updateDotFrame];
    if (self.valueDidChangedBlock) {
        self.valueDidChangedBlock();
    }
}

- (void)updateDotFrame {
    [self.dotView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(self.value * (self.bgView.frame.size.width - dotSize));
    }];
    [self updateConstraintsIfNeeded];
}

- (void)dealloc {
    [self removeObserver: self forKeyPath:@"value"];
}


@end
