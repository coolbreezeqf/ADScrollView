//
//  HomeViewController.m
//  PagedScrollView
//
//  Created by 陈政 on 14-1-23.
//  Copyright (c) 2014年 Apple Inc. All rights reserved.
//

#import "HomeViewController.h"
#import "CycleScrollView.h"
#import "ADScrollView.h"
@interface HomeViewController ()<ADScrollViewDataSource,ADScrollViewDelegate>

//@property (nonatomic , retain) CycleScrollView *mainScorllView;
@property (nonatomic, strong) ADScrollView *mainScorllView;
@property (nonatomic, strong) NSMutableArray *viewsArray;
@end

@implementation HomeViewController
- (UIView *)adScrollView:(ADScrollView *)adScrollView contentViewForSection:(NSInteger)index{
	return _viewsArray[index];
}

- (void)adScrollView:(ADScrollView *)adScrollView didSelectSectionAtIndex:(NSInteger)index{
	NSLog(@"点击了第%ld个page",index);
}

- (NSInteger)numberOfSectionsInADScrollView:(ADScrollView *)adScrollView{
	return _viewsArray.count;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	_viewsArray = [@[] mutableCopy];
    NSArray *colorArray = @[[UIColor cyanColor],[UIColor blueColor],[UIColor greenColor],[UIColor yellowColor],[UIColor purpleColor]];
    for (int i = 0; i < 2; ++i) {
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
		tempLabel.text = [NSString stringWithFormat:@"%*d",i*2,i];
        tempLabel.backgroundColor = [(UIColor *)[colorArray objectAtIndex:i] colorWithAlphaComponent:0.5];
        [_viewsArray addObject:tempLabel];
    }
    
    self.mainScorllView = [[ADScrollView alloc] initWithFrame:CGRectMake(0, 100, 320, 300) animationDuration:2];
	_mainScorllView.delegate = self;
	_mainScorllView.dataSource = self;
    self.mainScorllView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
    
//    self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
//        return _viewsArray[pageIndex];
//    };
//    self.mainScorllView.totalPagesCount = ^NSInteger(void){
//        return 5;
//    };
//    self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
//        NSLog(@"点击了第%d个",pageIndex);
//    };
    [self.view addSubview:self.mainScorllView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
