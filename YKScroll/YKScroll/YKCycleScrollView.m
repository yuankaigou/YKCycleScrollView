//
//  YKCycleScrollView.m
//  YKCycleScrollView
//
//  Created by gaocaixin on 15-4-2.
//  Copyright (c) 2015年 GCX. All rights reserved.
//

#import "YKCycleScrollView.h"
#import "UIImageView+WebCache.h"


#pragma mark - pageControl方法
//点的宽度和间隙
CGFloat const pointWidth = 7;
CGFloat const pointMargin = 7;

@interface YKPageControlView()

//被选中需要显示的图形
@property (nonatomic, weak) UIView *selectedRoundView;

//选点的初始位置 计算保存
@property (nonatomic, assign) CGFloat roundStartX;


@end


@implementation YKPageControlView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        
        //圆点的高度是
        //颜色初始值 可以后边修改
        self.currentPageIndicatorTintColor = [UIColor whiteColor];
        self.pageIndicatorTintColor = [UIColor grayColor];
        self.userInteractionEnabled = NO;
        
        
        //初始选中为第一个
        self.currentPage = 0;
        
    }
    return self;
}


- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    _numberOfPages = numberOfPages;
    
#warning 以后处理
    //创建子视图 只创建一次 但是如果多次设置就有问题--以后处理
    [self createPointViews];
    
    
}

- (void)createPointViews{
    //最后一个是选中view
    for (int i = 0; i <= self.numberOfPages; i++) {
        UIView *roundView = [[UIView alloc] init];
        roundView.backgroundColor = self.pageIndicatorTintColor;
        [self addSubview:roundView];
    }
    
    self.selectedRoundView = self.subviews.lastObject;
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    
    
    //圆点宽度
    CGFloat roundWidth = self.numberOfPages * (pointWidth + pointMargin) - pointMargin;
    CGFloat roundY = (CGRectGetHeight(self.bounds) - pointWidth)/2;
    
    CGFloat roundStartX = (CGRectGetWidth(self.bounds) - roundWidth)/2;
    self.roundStartX = roundStartX;
    //0的时候测试
    
    for (int i = 0; i <= self.numberOfPages; i++) {
        
        UIView *roundView = self.subviews[i];
        
        roundView.frame = CGRectMake(roundStartX+i * (pointWidth + pointMargin), roundY, pointWidth, pointWidth);
        
        roundView.backgroundColor = self.pageIndicatorTintColor;
        
        //最后一个添加到 最开始的第一个
        self.selectedRoundView.frame = CGRectMake(roundStartX,  roundY, pointWidth, pointWidth);
        self.selectedRoundView.backgroundColor = self.currentPageIndicatorTintColor;
    }
    
    
    //有frame之后才有style
    [self updatePointStyle];
    
}

//设置当前选中点
- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    
    //移动的x是多少呢？？
    CGRect frame = self.selectedRoundView.frame;
    
    //currentPage 是在循环移动的 0 - 1 -2 -3 -4 -- 0
    if (_currentPage < 0) {
        _currentPage = self.numberOfPages + (_currentPage%self.numberOfPages);
    } else if (_currentPage > 0) {
        _currentPage = (_currentPage%self.numberOfPages);
    } else if (_currentPage == 0) {
        _currentPage = 0;
    }
    
    CGFloat moveToX = _currentPage * (pointWidth + pointMargin);//宽度 加间隙
    NSLog(@"最新的位置%zd", self.currentPage);
    self.selectedRoundView.frame = CGRectMake(self.roundStartX + moveToX, frame.origin.y, frame.size.width, frame.size.height);
}


- (void)updatePointStyle{
    
    //圆角优化
    if (self.pointStyle == YKPageControlPointStyleDefault) {
       
        for (UIView *pointView in self.subviews) {
            pointView.layer.masksToBounds = YES;
            pointView.layer.cornerRadius = CGRectGetWidth(pointView.bounds)/2;
            
        }
        
    } else if(self.pointStyle == YKPageControlPointStyleSquare){
        
        return;
    }
    
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //点击结束判断点了左边还是右边
    UITouch *touch = touches.anyObject;
    CGPoint point =  [touch locationInView:self];
    
    CGFloat W = CGRectGetWidth(self.bounds);
    
    //点击左右， 控制current选中的移动 - 刷新移动
    if (point.x > W/2) {
        self.currentPage += 1;
        NSLog(@"点击了右边%zd", _currentPage);
        
    } else {
        self.currentPage -= 1;
        NSLog(@"点击了左边");
    }
}




@end


#pragma mark - 滚动视图方法
@interface YKCycleScrollView () <UIScrollViewDelegate>

// 主scrollView
@property (nonatomic ,weak) UIScrollView *cycleScrollView;

// 当前页码数
@property (nonatomic, assign) NSInteger currentPageIndex;



// 数据源imageURL
@property (nonatomic ,strong) NSMutableArray *imageUrls;

// 内容数据源imageURL
@property (nonatomic ,strong) NSMutableArray *contentImageUrls;

// 定时器
@property (nonatomic ,strong) NSTimer *time;

@end

@implementation YKCycleScrollView

- (NSMutableArray *)imageUrls
{
    if (_imageUrls == nil) {
        _imageUrls = [[NSMutableArray alloc] init];
    }
    return _imageUrls;
}
- (NSMutableArray *)contentImageUrls
{
    if (_contentImageUrls == nil) {
        _contentImageUrls = [[NSMutableArray alloc] init];
    }
    return _contentImageUrls;
}

// 初始化函数
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        // Initialization code
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.cycleScrollView = scrollView;
        //全都调整为父控件边缘大小拉伸
        self.cycleScrollView.autoresizingMask = 0xFF;
        self.cycleScrollView.contentMode = UIViewContentModeCenter;
        self.cycleScrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.cycleScrollView.frame), CGRectGetHeight(self.cycleScrollView.frame));
        
        
        //偏移了
        //一句废话

        
        //滚动情况告诉自己
        self.cycleScrollView.delegate = self;
        self.cycleScrollView.bounces = NO;
        self.cycleScrollView.showsHorizontalScrollIndicator = NO;
      
        
        self.cycleScrollView.pagingEnabled = YES;
        self.cycleScrollView.userInteractionEnabled = NO;
        [self addSubview:self.cycleScrollView];
        self.currentPageIndex = 0;
        
    
        
        // 初始化位置
        [self refreshLocation];
        
        // 添加三张imageview 用于复用
        [self addThreeImageView];
        
        // 创建page保存 在这里可以用枚举让用户选择自己的pageControl
        //开始的时候就创建了pageControl
        YKPageControlView *pageControl = [[YKPageControlView alloc] init];

        [self addSubview:pageControl];
        
        
        self.pageControl = pageControl;
        
    }
    return self;
}

// 创建三张imageView 用于滚动复用 占用内存小 当前和旁边的两张图片采用预加载
- (void)addThreeImageView
{
    for (UIView *view in self.cycleScrollView.subviews) {
        [view removeFromSuperview];
    }
    // 创建三张imageView 设置位置
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        CGFloat W = CGRectGetWidth(self.cycleScrollView.frame);
        CGFloat H = CGRectGetHeight(self.cycleScrollView.frame);
        imageView.frame = CGRectMake(i * W , 0, W, H);
        // 添加手势
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapAction:)];
        [imageView addGestureRecognizer:tapGesture];
        [self.cycleScrollView addSubview:imageView];
    }
}

// 设置数据源(默认是网上解析后的imageurl字符串数组)
- (void)setImageUrlNames:(NSArray *)ImageUrlNames
{
    //把网络图片地址加入到这里 转化为imageUrls(NSURL *)
    for (NSString *name in ImageUrlNames) {
        [self.imageUrls addObject:[NSURL URLWithString:name]];
    }
    
    //[D, A, B]
    [self refreshContentImageUrls];
    
    //下载展示新的image内容 [D, A, B]
    [self refreshImageView];
    
    // 数据源设置page 大小数量 位置
    [self setupPage];
    
    // 加载数据完成 开始定时器 提供一个第一次下载需要的时间
    [self startTimeWithDelay:2];
    
    //开启点击
    self.cycleScrollView.userInteractionEnabled = YES;
}
// 初始化page
- (void)setupPage
{
        self.pageControl.numberOfPages = self.imageUrls.count;
        
        CGFloat controlY = CGRectGetHeight(self.bounds) * 0.88;
        CGFloat controlW = CGRectGetWidth(self.bounds);
        self.pageControl.frame = CGRectMake(0, controlY, controlW, 20);
}

// 设置数据源 和 自动滚动时间
- (void)setImageUrlNames:(NSArray *)ImageUrlNames animationDuration:(NSTimeInterval)animationDuration
{
    // 创建定时器
    [self createTime:animationDuration];
    // 设置数据源
    [self setImageUrlNames:ImageUrlNames];
}
// 创建定时器
- (void)createTime:(NSTimeInterval)animationDuration
{
    self.time = [NSTimer scheduledTimerWithTimeInterval:animationDuration target:self selector:@selector(timing) userInfo:nil repeats:YES];
    self.time.fireDate = [NSDate distantFuture];
    [[NSRunLoop mainRunLoop] addTimer:self.time forMode:NSRunLoopCommonModes];
}
// 定时方法
- (void)timing
{
    CGPoint newOffset = CGPointMake(self.cycleScrollView.contentOffset.x + CGRectGetWidth(self.cycleScrollView.frame), self.cycleScrollView.contentOffset.y);
    
    //动画去移动 在当前x的偏移基础上， 再去移动一个宽度 调用协议方法
    [self.cycleScrollView setContentOffset:newOffset animated:YES];
}


// 暂停定时器
- (void)pauseTime
{
    if (self.time) {
        if ([self.time isValid]) {
            self.time.fireDate = [NSDate distantFuture];
        }
    }
}
// 开始定时器
- (void)startTime
{
    if (self.time) {
        if ([self.time isValid]) {
            self.time.fireDate = [NSDate distantPast];
        }
    }
}
// 一段时间后开始定时器
- (void)startTimeWithDelay:(NSTimeInterval)delay
{
    if (self.time) {
        if ([self.time isValid]) {
            self.time.fireDate = [NSDate dateWithTimeIntervalSinceNow:delay];
        }
    }
}

// 刷新所有
- (void)refresh
{
    if (self.contentImageUrls.count > 0) {
        [self refreshContentImageUrls];
        [self refreshImageView];
        [self refreshLocation];
        [self refreshPage];
    }
}
// 刷新page的当前页
- (void)refreshPage
{
    //设置当前选中的位置
    self.pageControl.currentPage = self.currentPageIndex;
}
// 刷新内容数据源-- 调整内容数据显示不同的数据
- (void)refreshContentImageUrls
{
    
    //开始的时候为0 数字游戏
    //[A, B, C, D]
    //如果当前是 0 pre = 3, 如果1 pre = 0
    //如果当前是 0 next = 1,  3 nex = 0
    
    NSInteger prePage = self.currentPageIndex - 1 >= 0 ? self.currentPageIndex - 1 : self.imageUrls.count - 1;
    NSInteger nextPage = self.currentPageIndex + 1 < self.imageUrls.count ? self.currentPageIndex + 1 : 0;
    
    //删除所有数据
    [self.contentImageUrls removeAllObjects];
    
    //[D, A, B]
    [self.contentImageUrls addObject:self.imageUrls[prePage]];
    [self.contentImageUrls addObject:self.imageUrls[self.currentPageIndex]];
    [self.contentImageUrls addObject:self.imageUrls[nextPage]];
    
}
// 刷新imageView的图片 使用sdwebimage第三方加载图片
- (void)refreshImageView
{
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = self.cycleScrollView.subviews[i];
        //在这里去请求数据
        //遍历url数组 [D, A, B]
        [imageView sd_setImageWithURL:self.contentImageUrls[i]];
    }
    
}
// 刷新位置
- (void)refreshLocation
{
    //(W, 0) 显示中间那张imageView
    self.cycleScrollView.contentOffset = CGPointMake(CGRectGetWidth(self.cycleScrollView.frame), 0);
}


#pragma mark - 监听scroll
// 滚动动画结束时
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self startTimeWithDelay:2];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self pauseTime];
}
// 正在滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0) {
        
        self.currentPageIndex = self.currentPageIndex - 1 >= 0 ? self.currentPageIndex - 1 : self.imageUrls.count - 1;
        //cur = 0
        //self.cur = 3
        
        [self refresh];
        
    } else if (scrollView.contentOffset.x == 2 * CGRectGetWidth(self.cycleScrollView.frame)) {
        //到了最后一张imageView cur = 0
        
        //cur = 1
        self.currentPageIndex = self.currentPageIndex + 1 < self.imageUrls.count ? self.currentPageIndex + 1 : 0;
        
        //count = 4
        //如果cur=0, cur-> 1
        //如果cur=1, cur-> 2  如果cur=3, cur-> 0
        [self refresh];
    }
}

#pragma mark - 响应事件

// imageView的点击事件
- (void)imageViewTapAction:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:DidTapImageView:)]) {
        [self.delegate cycleScrollView:self DidTapImageView:self.currentPageIndex];
    }
}


@end
