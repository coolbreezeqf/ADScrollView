//
//  ADScrollView.m
//  PagedScrollView
//
//  Created by qf on 15/4/20.
//  Copyright (c) 2015年 Apple Inc. All rights reserved.
//

#import "ADScrollView.h"
#import "NSTimer+Addition.h"
@interface ADScrollView() <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) NSInteger totalPageCount;
@property (nonatomic, strong) NSMutableDictionary *totalViews;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, assign) NSTimeInterval animationDuration;

@end

@implementation ADScrollView

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)duration {
	self = [self initWithFrame:frame];
	if (duration > 0.0) {
		self.animationDuration = duration;
		self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:duration
															   target:self
															 selector:@selector(animationTimerDidFired:)
															 userInfo:nil
															  repeats:YES];
		[self.animationTimer pauseTimer];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
	if (self = [super initWithFrame:frame]) {
		self.autoresizesSubviews = YES;	//自动布局

		self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		self.scrollView.autoresizingMask = 0xFF;//what?随父视图自动调整布局
		self.scrollView.contentMode = UIViewContentModeCenter;
		self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
		self.scrollView.delegate = self;
		self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
		self.scrollView.pagingEnabled = YES;
		[self addSubview:self.scrollView];
		
		self.currentPageIndex = 0;
	}
	return self;
}
//将views储存到字典中，防止多次调用
- (UIView *)contentViewForSection:(NSInteger)index{
	if (!_totalViews) {
		_totalViews = [NSMutableDictionary dictionaryWithCapacity:_totalPageCount];
	}
	NSNumber *indexNum = [NSNumber numberWithInteger:index];
	if (![_totalViews objectForKey:indexNum]) {
		UIView *content = [self.dataSource adScrollView:self contentViewForSection:index];
		content.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
		[content addGestureRecognizer:tapGesture];
		[_totalViews setObject:content forKey:indexNum];
	}
	if (_totalPageCount < 3) {
		//小于三张图片时，复制UIView
		UIView *view = _totalViews[indexNum];
		NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:view];
		UIView *copyView = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
		[copyView addGestureRecognizer:tapGesture];
		return copyView;
	}
	return _totalViews[indexNum];
}

//获取下一页的位置
- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
	return (_totalPageCount + currentPageIndex) % _totalPageCount;
}
//移动到尽头时进行重置scorllview的subview
- (void)moveToEndRightward:(BOOL)rightward{
	if (!_totalPageCount){
		return;
	}
	if (rightward) {
		_currentPageIndex = [self getValidNextPageIndexWithPageIndex:_currentPageIndex-2];
	}
	[self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	for (NSInteger i = 0; i < 3; i++) {
		UIView *content = [self contentViewForSection:[self getValidNextPageIndexWithPageIndex:_currentPageIndex+i]];
		CGRect rect = content.frame;
		rect.origin = CGPointMake(_scrollView.frame.size.width * i, 0);
		content.frame = rect;
		[self.scrollView addSubview:content];
		
	}
	_currentPageIndex = [self getValidNextPageIndexWithPageIndex:_currentPageIndex + 1];
	self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
}

#pragma - mark UIScrollViewDelegate
//防止滑动后立刻移动到下一个页面
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	[self.animationTimer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	int contentOffSetX = scrollView.contentOffset.x;
	if (contentOffSetX >= (2 * CGRectGetWidth(scrollView.frame))) {
		[self moveToEndRightward:NO];
	}else if(contentOffSetX <= 0){
		[self moveToEndRightward:YES];
	}
}
//why?
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	[scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

#pragma mark - action
- (void)animationTimerDidFired:(NSTimer *)timer{
	CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
	[self.scrollView setContentOffset:newOffset animated:YES];
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tap{
	if (self.delegate) {
		[self.delegate adScrollView:self didSelectSectionAtIndex:self.currentPageIndex];
	}
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	[super drawRect:rect];
	if (!_totalPageCount) {
		if (self.dataSource) {
			_totalPageCount = [self.dataSource numberOfSectionsInADScrollView:self];
			[self moveToEndRightward:NO];
			[self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
		}else{
			_totalPageCount = 0;
		}
	}
	[self moveToEndRightward:NO];
	[self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];

}


@end
