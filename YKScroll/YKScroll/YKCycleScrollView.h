//
//  YKCycleScrollView.h
//  YKCycleScrollView
//
//  Created by gaocaixin on 15-4-2.
//  Copyright (c) 2015年 GCX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YTPageControl;
@class YKPageControlView;

@class YKCycleScrollView;

@protocol YKCycleScrollViewDelegate <NSObject>

// 代理方法 通知代理方点击的下标
- (void)cycleScrollView:(YKCycleScrollView *)cycleScrollView DidTapImageView:(NSInteger)index;

@end




#pragma mark - 循环滚动部分

@interface YKCycleScrollView : UIView

/**
 只需要调用 初始化(initWithFrame) 和 设置一个scrollView的image的URL的字符串数组(setImageUrlNames) 便可使用
 
 用于大部分项目scrollView的自动滚动功能
 采用预加载
 只用三张imageView 占用能存小
 代码易懂
 */

// 需要包含SDimage的第三方库


// 初始化
- (id)initWithFrame:(CGRect)frame;

// 数据源方法

// 设置数据源 没有自动滚动功能 不创建定时器
- (void)setImageUrlNames:(NSArray *)ImageUrlNames;


// 设置数据源 和 自动滚动时间 能够自动滚动
- (void)setImageUrlNames:(NSArray *)ImageUrlNames animationDuration:(NSTimeInterval)animationDuration;


// 内部使用的是系统默认的pageControll属性 如有需要 自行设置
//@property (nonatomic ,weak) YKPageControlView *scrollPage;
@property (nonatomic ,weak) YTPageControl *pageControl;

// 代理
@property (nonatomic ,weak) id <YKCycleScrollViewDelegate> delegate;


/**
 点的样式
 */
typedef NS_ENUM(NSInteger, YKPageControlPointStyle) {
    YKPageControlPointStyleDefault,     //默认是圆形样式
    YKPageControlPointStyleSquare,      //正方形样式
};

@end




#pragma mark - YTPageControl
/**
 点的样式
 */
typedef NS_ENUM(NSInteger, YTPageControlPointStyle) {
    YTPageControlPointStyleDefault,     //默认是圆形样式
    YTPageControlPointStyleSquare,      //正方形样式
    YTPageControlPointStyleRectangle    //长方形样式
};

@interface YTPageControl : UIView



/**
 正常状态的颜色
 */
@property (nonatomic, strong) UIColor * normalColor;

/**
 选中颜色
 */
@property (nonatomic, strong) UIColor  * selectedColor;

/**
 分页总数
 */
@property (nonatomic, assign) NSInteger numberOfPages;


/**
 当前选中的分页
 */
@property (nonatomic, assign) NSInteger  currentPage;


/**
 page样式
 */
@property (nonatomic, assign) YTPageControlPointStyle pointStyle;

@end

