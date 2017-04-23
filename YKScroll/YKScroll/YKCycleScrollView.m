//
//  YKCycleScrollView.m
//  YKCycleScrollView
//
//  Created by gaocaixin on 15-4-2.
//  Copyright (c) 2015年 GCX. All rights reserved.
//

#import "YKCycleScrollView.h"
#import "UIImageView+WebCache.h"

#pragma mark - YTPageControl

#define Page_Tag 100

@interface YTPageControl(){
    
    //存放分页对应的子视图的容器
    UIView * _contentView;
}

/**
 当前被选中的分页
 */
@property (nonatomic, weak) UIView * currentSelectedPageView;




/**
 分页的宽度
 */
@property (nonatomic, assign) CGFloat pageWidth;

/**
 分页的高度
 */
@property (nonatomic, assign) CGFloat pageHeight;
/**
 分页与分页之间的间距
 */
@property (nonatomic, assign) CGFloat margin;

/**
 圆角大小
 */
@property (nonatomic, assign) CGFloat corner;


@end

@implementation YTPageControl

#pragma mark - 在构造方法中初始化
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        _normalColor = [UIColor colorWithWhite:1 alpha:0.3];
        _selectedColor = [UIColor whiteColor];
        [self p_initialize];
    }
    
    return self;
}

- (void)p_initialize{

    _pageWidth = 8;
    _pageHeight = 8;
    _margin = 10;
    _corner = _pageHeight/2;
}

#pragma mark -- 创建每个分页对应的子视图
- (void)setNumberOfPages:(NSInteger)numberOfPages{
    _numberOfPages = numberOfPages;
    
    //移除原来创建的所有子视图
    for (UIView * subView in self.subviews) {
        
        [subView removeFromSuperview];
    }
    
    //根据分页数创建对应的视图
    _contentView = [UIView new];
    [self addSubview:_contentView];
    for (int i = 0; i < numberOfPages; i++) {
        
        UIView * pageSubView = [UIView new];
        pageSubView.tag = Page_Tag + i;     //设置tag，方便后边获取
        [_contentView addSubview:pageSubView];
        
        //默认第一个处于选中状态
        if (i == 0) {
            
            self.currentSelectedPageView = pageSubView;
        }
    }
    
}

#pragma mark -- 计算frame
- (void)layoutSubviews{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setSubViewFrames];
    });
}

- (void)setSubViewFrames{
    
    //1.设置分页子视图
    CGFloat x = 0;
    CGFloat y = self.frame.size.height / 2 - _pageHeight/2;
    
    int i = 0;
    for (UIView * subView in _contentView.subviews) {
        //设置frame
        x = _margin + (_margin + _pageWidth) * i;
        subView.frame = CGRectMake(x, y, _pageWidth, _pageHeight);
        //设置颜色
        subView.backgroundColor = _normalColor;
        //切圆角
        subView.layer.cornerRadius = _corner;
        
        i += 1;
    }
    
    //选中的分页设置成选中颜色
    _currentSelectedPageView.backgroundColor = _selectedColor;
    
    //2.设置容器视图
    CGFloat contentX = 0;
    CGFloat contentY = 0;
    CGFloat contentW = _margin + (_margin + _pageWidth) * self.numberOfPages;
    CGFloat contentH = self.frame.size.height;
    _contentView.frame = CGRectMake(contentX, contentY, contentW, contentH);
    _contentView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

#pragma mark -- 切换分页
- (void)setCurrentPage:(NSInteger)currentPage{
    
    _currentPage = currentPage;
    
    UIView * subView = [_contentView viewWithTag:Page_Tag + currentPage];
    if (subView != _currentSelectedPageView) {
        
        _currentSelectedPageView.backgroundColor = _normalColor;
        subView.backgroundColor = _selectedColor;
        _currentSelectedPageView = subView;
    }
    
}

#pragma mark -- 不同的风格
- (void)setPointStyle:(YTPageControlPointStyle)pointStyle{
    
    _pointStyle = pointStyle;
    
    switch (pointStyle) {
        case YTPageControlPointStyleDefault:{
            [self p_initialize];
            break;
        }
        case YTPageControlPointStyleSquare:{
            _pageWidth = 8;
            _pageHeight = 8;
            _margin = 10;
            _corner = 0;
            
            break;
        }
        case YTPageControlPointStyleRectangle:{
            _pageWidth = 16;
            _pageHeight = 2;
            _margin = 5;
            _corner = 0;
            break;
        }
        default:
            break;
    }
    
    
}

#pragma mark -- 点击切换
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [touches.anyObject locationInView:self];
    
    NSInteger tPage = 0;
    if (point.x < self.frame.size.width/2) {
        
        tPage = _currentPage - 1;
        if (tPage < 0) {
            
            tPage = 0;
        }
        
        self.currentPage = tPage;
        
    }else{
        
        tPage = _currentPage + 1;
        if (tPage >= self.numberOfPages) {
            
            tPage = self.numberOfPages - 1;
        }
        
        self.currentPage = tPage;
        
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
        YTPageControl *pageControl = [[YTPageControl alloc] init];

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
