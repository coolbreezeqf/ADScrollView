//
//  ADScrollView.h
//  PagedScrollView
//
//  Created by qf on 15/4/20.
//  Copyright (c) 2015年 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ADScrollView;

@protocol ADScrollViewDataSource<NSObject>

@required
//获取page个数
- (NSInteger)numberOfSectionsInADScrollView:(ADScrollView *)adScrollView;

//获取第index个page的contentView
- (UIView *)adScrollView:(ADScrollView *)adScrollView contentViewForSection:(NSInteger)index;
@end

@protocol ADScrollViewDelegate <NSObject>

//点击第index个page时的动作
- (void)adScrollView:(ADScrollView *)adScrollView didSelectSectionAtIndex:(NSInteger)index;

@end

@interface ADScrollView : UIView

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, strong) id <ADScrollViewDataSource> dataSource;
@property (nonatomic, strong) id <ADScrollViewDelegate> delegate;

/**
 *
 *
 *	@param duration 自动滚动间隔时间
 */
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)duration;
@end
