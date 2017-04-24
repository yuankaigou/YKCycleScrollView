//
//  ViewController.m
//  YKScroll
//
//  Created by gougou on 2017/4/21.
//  Copyright © 2017年 YKDog. All rights reserved.
//

#import "ViewController.h"
#import "YKCycleScrollView.h"

@interface ViewController ()<YKCycleScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    YKCycleScrollView * cycleScrollView = [[YKCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    
    [cycleScrollView setImageUrlNames:@[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1492958399976&di=2a395dc3a4256837868687c000ca2bbf&imgtype=0&src=http%3A%2F%2Ftupian.enterdesk.com%2F2012%2F0428%2F78%2F18.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1492958445576&di=15f9cfe2dd302eda44f9d38455c902f6&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fforum%2Fpic%2Fitem%2Fa2cc7cd98d1001e9594a3ab7b80e7bec54e79717.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1492958483218&di=9a95721c5cddc0947020fb532d754e07&imgtype=0&src=http%3A%2F%2Fff.topit.me%2Ff%2F68%2Ff3%2F11179295808c0f368fo.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1492958483218&di=677965d930c66de4ce726180167dfe2d&imgtype=0&src=http%3A%2F%2Fh.hiphotos.baidu.com%2Fzhidao%2Fpic%2Fitem%2F1b4c510fd9f9d72a3762d754d22a2834349bbb71.jpg"] animationDuration:3];
    
    cycleScrollView.pageControl.normalColor = [UIColor greenColor];
    cycleScrollView.pageControl.selectedColor = [UIColor redColor];
    
    cycleScrollView.pageControl.pointStyle = YTPageControlPointStyleRectangle;
    
    
    [self.view addSubview:cycleScrollView];
    
    
}


- (void)cycleScrollView:(YKCycleScrollView *)cycleScrollView DidTapImageView:(NSInteger)index
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
