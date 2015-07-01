//
//  SGFocusImageFrame.m
//  ScrollViewLoop
//
//  Created by Vincent Tang on 13-7-18.
//  Copyright (c) 2013年 Vincent Tang. All rights reserved.
//

#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"
#import "UIImageView+WebCache.h"
#import "ScheduleModelView.h"
#define ITEM_WIDTH self.frame.size.width
#define ITEM_HEIGHT self.frame.size.height
@interface SGFocusImageFrame () {
    BOOL _isVertical; //是否是垂直滚动

}

@property (nonatomic, strong) NSMutableArray *imageItems;
@property (nonatomic, strong) NSTimer *autoScrollTimer;
@property (nonatomic) int scrollInterval;

- (void)setupViews;

@end

static int SWITCH_FOCUS_PICTURE_INTERVAL = 5; //switch interval time

@implementation SGFocusImageFrame

- (id)initWithFrame:(CGRect)frame delegate:(id<SGFocusImageFrameDelegate>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto isOnlyImage:(SGFocusImageType )focusImageType andWithisVertical:(BOOL )isVertical{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageItems = [NSMutableArray arrayWithArray:items];
        if (items.count > 0) {
            //增加最后一条和第一条循环
            [self.imageItems insertObject:items[items.count - 1] atIndex:0];
            [self.imageItems addObject:items[0]];
        }
        _isVertical = isVertical;
        _isAutoPlay = isAuto;
        [self setupViewsWith:focusImageType];
        
        [self setDelegate:delegate];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<SGFocusImageFrameDelegate>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto
{
    return [self initWithFrame:frame delegate:delegate imageItems:items isAuto:YES displayType:0];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<SGFocusImageFrameDelegate>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto displayType:(int)displayType {
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageItems = [NSMutableArray arrayWithArray:items];
        if (items.count > 1) {
            //增加最后一条和第一条循环
            [self.imageItems insertObject:items[items.count - 1] atIndex:0];
            [self.imageItems addObject:items[0]];
        }
        
        _isAutoPlay = isAuto;
        _displayType = displayType;
        
        [self setupViews];
        
        [self setDelegate:delegate];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<SGFocusImageFrameDelegate>)delegate imageItems:(NSArray *)items isAuto:(BOOL)isAuto isOnlyImage:(int)isOnlyImage{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageItems = [NSMutableArray arrayWithArray:items];
        if (items.count > 1) {
            //增加最后一条和第一条循环
            [self.imageItems insertObject:items[items.count - 1] atIndex:0];
            [self.imageItems addObject:items[0]];
        }
        
        _isAutoPlay = isAuto;
        _isOnlyImage = isOnlyImage;
        [self setupViews];
        
        if (items.count <= 1) {
            self.pageControl.hidden = YES;
        }
        
        [self setDelegate:delegate];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<SGFocusImageFrameDelegate>)delegate imageItems:(NSArray *)items
{
    return [self initWithFrame:frame delegate:delegate imageItems:items isAuto:YES];
}

- (void)dealloc
{
    self.delegate = nil;
    _scrollView.delegate = nil;
}

#pragma mark - private methods
- (void)setupViewsWith:(SGFocusImageType )focusImageType
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.scrollsToTop = NO;
    float space = 0;
    //    CGSize size = CGSizeMake(ITEM_WIDTH, 0);
    [self addSubview:_scrollView];
    
    /*
     _scrollView.layer.cornerRadius = 10;
     _scrollView.layer.borderWidth = 1 ;
     _scrollView.layer.borderColor = [[UIColor lightGrayColor ] CGColor];
     */
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    
    _pageControl.numberOfPages = _imageItems.count>1?_imageItems.count -2:_imageItems.count;
    _pageControl.currentPage = 0;
    
    _scrollView.delegate = self;
    
    
    switch (focusImageType) {
        case SGFocusOneyImageAndPageControl:
        {
            _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height -16-10, CGRectGetWidth(self.bounds), 10)];
            _pageControl.userInteractionEnabled = NO;
            [self addSubview:_pageControl];
            
            for (int i = 0; i < _imageItems.count; i++) {
                SGFocusImageItem *item = [_imageItems objectAtIndex:i];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width+space, space, _scrollView.frame.size.width-space*2, _scrollView.frame.size.height-2*space)];
                //加载图片
                [imageView sd_setImageWithURL:[NSURL URLWithString:item.image] placeholderImage:nil];
                
                [_scrollView addSubview:imageView];
            }
            
            // single tap gesture recognizer
            UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
            tapGestureRecognize.delegate = self;
            tapGestureRecognize.numberOfTapsRequired = 1;
            [_scrollView addGestureRecognizer:tapGestureRecognize];
            _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _imageItems.count, _scrollView.frame.size.height);
            
        }
            break;
        case SGFocusOneyImage:
        {
            for (int i = 0; i < _imageItems.count; i++) {
                SGFocusImageItem *item = [_imageItems objectAtIndex:i];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width+space, space, _scrollView.frame.size.width-space*2, _scrollView.frame.size.height-2*space)];
                //加载图片
                [imageView sd_setImageWithURL:[NSURL URLWithString:item.image] placeholderImage:nil];
                
                [_scrollView addSubview:imageView];
            }
        }
            break;
        case SGFocusOneyText:
        {
            for (int i = 0; i < _imageItems.count; i++) {
                SGFocusImageItem *item = [_imageItems objectAtIndex:i];
                UILabel *labelView = nil;
                if (_isVertical) {
                    labelView = [[UILabel alloc] initWithFrame:CGRectMake(space, i * _scrollView.frame.size.height+space, _scrollView.frame.size.width-space*2, _scrollView.frame.size.height-2*space)];
                }else {
                    labelView = [[UILabel alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width+space, space, _scrollView.frame.size.width-space*2, _scrollView.frame.size.height-2*space)];
                }
                labelView.text = item.title;
                //加载图片
                labelView.textColor = RGB(149, 149, 149);
                labelView.font = [UIFont systemFontOfSize:14.f];
                [_scrollView addSubview:labelView];
                
                UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
                tapGestureRecognize.delegate = self;
                tapGestureRecognize.numberOfTapsRequired = 1;
                [labelView addGestureRecognizer:tapGestureRecognize];
                labelView.userInteractionEnabled = YES;
                
                if (_isVertical) {
                    
                    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height*_imageItems.count);
                }else {
                    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width *_imageItems.count , _scrollView.frame.size.height);
                }
                
            }
        }
            break;
            
        default:
            break;
    }
    
    
    
    
    
    
    
    
    if ([_imageItems count]>1)
    {
        if (_isVertical) {
            [_scrollView setContentOffset:CGPointMake(0, ITEM_HEIGHT) animated:NO] ;
        }else {
            [_scrollView setContentOffset:CGPointMake(ITEM_WIDTH, 0) animated:NO] ;
            
        }
        
        if (_isAutoPlay) {
            
            //            self.scrollInterval = 0;
            self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:SWITCH_FOCUS_PICTURE_INTERVAL target:self selector:@selector(switchFocusImageItems:) userInfo:nil repeats:YES];
        }
    }
}

#pragma mark - private methods
- (void)setupViews
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.scrollsToTop = NO;
    float space = 0;
    float buttomSpace = 0;
    if (_displayType == 1) {
        buttomSpace = 20;
    }
    
    CGSize size = CGSizeMake(320, 0);

    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height -16, CGRectGetWidth(self.bounds), 10)];
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_scrollView];
    [self addSubview:_pageControl];
    
    /*
     _scrollView.layer.cornerRadius = 10;
     _scrollView.layer.borderWidth = 1 ;
     _scrollView.layer.borderColor = [[UIColor lightGrayColor ] CGColor];
     */
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    
    _pageControl.numberOfPages = _imageItems.count>1?_imageItems.count -2:_imageItems.count;
    _pageControl.currentPage = 0;
    
    _scrollView.delegate = self;
    
    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:tapGestureRecognize];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _imageItems.count, _scrollView.frame.size.height);
    
    if (_isOnlyImage == 100) {
        
        //显示档期首页模式的轮播图形式
        for (int i = 0; i < _imageItems.count; i++) {
            ScheduleModelView *item = [_imageItems objectAtIndex:i];
            ScheduleModelView *nowItem = [[ScheduleModelView alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width + 10, 0, item.frame.size.width, item.frame.size.height) title:item.title time:item.time price:item.price buttonTag:item.buttonTag imageUrl:item.image];
            [nowItem.imageButton addTarget:self action:@selector(singleTapGestureRecognizer:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:nowItem];
            
        }
        
        _pageControl.frame = CGRectMake(0, self.frame.size.height - 10, CGRectGetWidth(self.bounds), 10);
    }else if (_isOnlyImage == 200){
        //婚车租赁
        for (int i = 0; i < _imageItems.count; i++) {
            SGFocusImageItem *item = [_imageItems objectAtIndex:i];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width+space, space, _scrollView.frame.size.width-space*2, _scrollView.frame.size.height-2*space-size.height - buttomSpace - 24)];
            //加载图片
            [imageView sd_setImageWithURL:[NSURL URLWithString:item.image] placeholderImage:nil];
            
            [_scrollView addSubview:imageView];
        }
        
    }else{
        for (int i = 0; i < _imageItems.count; i++) {
            SGFocusImageItem *item = [_imageItems objectAtIndex:i];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width+space, space, _scrollView.frame.size.width-space*2, _scrollView.frame.size.height-2*space-size.height - buttomSpace)];
            //加载图片
            [imageView sd_setImageWithURL:[NSURL URLWithString:item.image] placeholderImage:nil];
            
            [_scrollView addSubview:imageView];
        }
    }
    

    if ([_imageItems count]>1)
    {
        [_scrollView setContentOffset:CGPointMake(ITEM_WIDTH, 0) animated:NO] ;
        
        if (_isAutoPlay) {
            
            self.scrollInterval = 0;
            self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(switchFocusImageItems:) userInfo:nil repeats:YES];
        }
    }
}

- (void)switchFocusImageItems:(NSTimer *)timer
{
    self.scrollInterval++;
    if (self.scrollInterval < SWITCH_FOCUS_PICTURE_INTERVAL) {
        return;
    }
    
    if (_isVertical) {
        CGFloat targetY = _scrollView.contentOffset.y + _scrollView.frame.size.height;
        
        targetY = (int)(targetY/ITEM_HEIGHT) * ITEM_HEIGHT;
        [self moveToTargetPositionY:targetY];
    }else {
        CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
        
        targetX = (int)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
        [self moveToTargetPositionX:targetX];
    }


    
    self.scrollInterval = 0;
}


- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    
    int page;
    if (_isVertical) {
        page = (int)(_scrollView.contentOffset.y / _scrollView.frame.size.height);
    }else {
        page = (int)(_scrollView.contentOffset.x / _scrollView.frame.size.width);
    }
    if (page > -1 && page < _imageItems.count) {
        if (_isOnlyImage == 100) {
            //档期首页轮播图
            ScheduleModelView *item = [_imageItems objectAtIndex:page];
            if (self.delegate && [self.delegate respondsToSelector:@selector(foucusImageFrame2:didSelectItem:)]) {
                [self.delegate foucusImageFrame2:self didSelectItem:item];
            }
        }else{
            SGFocusImageItem *item = [_imageItems objectAtIndex:page];
            if (self.delegate && [self.delegate respondsToSelector:@selector(foucusImageFrame:didSelectItem:)]) {
                [self.delegate foucusImageFrame:self didSelectItem:item];
            }
        }
        
    }
}

#pragma mark ----- 纵向移动 -----------

- (void)moveToTargetPositionY:(CGFloat)targetY
{
    BOOL animated = YES;
    [_scrollView setContentOffset:CGPointMake(0, targetY) animated:animated];
}

#pragma mark ----- 横向移动 -----------
- (void)moveToTargetPositionX:(CGFloat)targetX
{
    BOOL animated = YES;
    [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:animated];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float targetX = scrollView.contentOffset.x;
    
    if ([_imageItems count]>=3)
    {
        
        if (_isVertical) {
            float targetY = scrollView.contentOffset.y;
            
            if (targetY >= ITEM_HEIGHT * ([_imageItems count] -1)) {
                targetY = ITEM_HEIGHT;
                [_scrollView setContentOffset:CGPointMake(0, targetY) animated:NO];
            }
            else if(targetY <= 0)
            {
                targetY = ITEM_HEIGHT *([_imageItems count]-2);
                [_scrollView setContentOffset:CGPointMake(0, targetY) animated:NO];
            }
        }else {
            if (targetX >= ITEM_WIDTH * ([_imageItems count] -1)) {
                targetX = ITEM_WIDTH;
                [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
            }
            else if(targetX <= 0)
            {
                targetX = ITEM_WIDTH *([_imageItems count]-2);
                [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
            }
        }
     
    }
    NSInteger page = (_scrollView.contentOffset.x+ITEM_WIDTH/2.0) / ITEM_WIDTH;
    //    NSLog(@"%f %d",_scrollView.contentOffset.x,page);
    if ([_imageItems count] > 1)
    {
        page --;
        if (page >= _pageControl.numberOfPages)
        {
            page = 0;
        }else if(page <0)
        {
            page = _pageControl.numberOfPages -1;
        }
    }
    if (page!= _pageControl.currentPage)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(foucusImageFrame:currentItem:)])
        {
            [self.delegate foucusImageFrame:self currentItem:(int)page];
        }
    }
    _pageControl.currentPage = page;
    
    self.scrollInterval = 0;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        if (_isVertical) {
            CGFloat targetY = _scrollView.contentOffset.y + _scrollView.frame.size.height;
            
            targetY = (int)(targetY/ITEM_HEIGHT) * ITEM_HEIGHT;
            [self moveToTargetPositionY:targetY];
        }else {
            CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
            targetX = (int)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
            [self moveToTargetPositionX:targetX];
        }
    }
}

- (void)scrollToIndex:(int)aIndex
{
    if ([_imageItems count]>1)
    {
        if (aIndex >= ([_imageItems count]-2))
        {
            aIndex = (int)[_imageItems count]-3;
        }
        if (_isVertical) {
            [self moveToTargetPositionY:ITEM_HEIGHT*(aIndex+1)];
            
        }else {
            [self moveToTargetPositionX:ITEM_WIDTH*(aIndex+1)];
            
        }
    }else  {
        if (_isVertical) {
            [self moveToTargetPositionY:0];
            
        }else {
            [self moveToTargetPositionX:0];
            
        }
    }
    [self scrollViewDidScroll:_scrollView];
}

@end