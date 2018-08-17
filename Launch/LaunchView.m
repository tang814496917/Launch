//
//  LaunchView.m
//  MajiaDemo
//
//  Created by mc on 2018/7/20.
//  Copyright © 2018年 mc. All rights reserved.
//

#import "LaunchView.h"
#import "LaunchBottomView.h"
#import "LaunchModel.h"
#import "HUDTool.h"
#import "LaunchDefine.h"

typedef NS_ENUM(NSUInteger, LaunchContentType){
    LaunchContentTypeUnkown = 0,    // 不展示内容
    LaunchContentTypeLoading,       // 展示web加载的页面
    LaunchContentTypeAlert          // 弹窗信息
};

@interface LaunchView()<UIWebViewDelegate, UIAlertViewDelegate>

// web加载
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) LaunchBottomView *bottomView;

// alert弹窗
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *doneBtn;

@property (nonatomic, assign) LaunchContentType contentType;
// web跳转字符串的存储
@property (nonatomic, strong) NSArray *openArr;
// web加载地址
@property (nonatomic, strong) NSString *contentUrl;

// alert形式下的数据
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@end

@implementation LaunchView
#pragma mark--------外部调用
- (void)showInView:(UIView *)view
{
    [view addSubview:self];
}

#pragma mark--------私有方法
#pragma mark 数据处理
- (void)initData
{
    LaunchModel *model = [LaunchModel launchModelFromLocoalCache];
    // 截取tomato
    NSArray * arrayModelTomato = [model.tomato componentsSeparatedByString:@" "];
    if (arrayModelTomato.count == 2) {
        self.contentType = LaunchContentTypeAlert;
        self.title = [arrayModelTomato firstObject];
        self.subTitle = arrayModelTomato[1];
    } else if (arrayModelTomato.count == 1) {
        self.contentType = LaunchContentTypeLoading;
        self.contentUrl = model.tomato;
        self.openArr = [model.openid componentsSeparatedByString:@" "];
        [HUDTool showStatusWithString:@"加载中"];
    } else {
        self.contentType = LaunchContentTypeUnkown;
    }
}


#pragma mark webView处理
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString* reqUrl = request.URL.absoluteString;
    for (NSString *openid in self.openArr) {
        if ([reqUrl hasPrefix:openid]) {
            [[UIApplication sharedApplication] openURL:request.URL];
            break;
        }
    }
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    CGSize contentSize = self.webView.scrollView.contentSize;
    CGSize viewSize = self.webView.bounds.size;
    
    float rw = viewSize.width / contentSize.width;
    
    self.webView.scrollView.minimumZoomScale = rw;
    self.webView.scrollView.maximumZoomScale = rw;
    self.webView.scrollView.zoomScale = rw;
    [HUDTool dismiss];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [HUDTool dismiss];
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
}

// 加载web
- (void)loadContent
{
    [self initData];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.contentUrl]];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
}

// 底部按钮点击
- (void)contentAction:(UIButton *)btn
{
    NSInteger index = btn.tag;
    switch (index) {
        case 0:
            [self loadContent];
            break;
        case 1:
            [self.webView reload];
            break;
        case 2:
            if (self.webView.canGoBack)
            {
                [self.webView goBack];
            }
            break;
        case 3:
            if (self.webView.canGoForward) {
                [self.webView goForward];
            }
            break;
        case 4:
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定清理缓存吗?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self cleanCacheAndCookie];
    } else {
        
    }
}

/**清除缓存和cookie*/
- (void)cleanCacheAndCookie{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

#pragma mark UI初始化
- (void)didMoveToSuperview
{
    if (self.contentType == LaunchContentTypeUnkown) {
        [self removeFromSuperview];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self layoutUI];
        if (self.contentType == LaunchContentTypeAlert) {
            self.titleLabel.text = self.title;
            self.subTitleLabel.text = self.subTitle;
            // 添加动画
            [self animationAlert:self.contentView];
        } else if (self.contentType == LaunchContentTypeLoading) {
            // web加载内容
            [self loadContent];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addUI];
        [self initData];
    }
    return self;
}

// UI添加
- (void)addUI
{
    self.webView = [[UIWebView alloc] init];
    [self addSubview:self.webView];
    
    self.bottomView = [[LaunchBottomView alloc] init];
    [self addSubview:self.bottomView];
    
    self.contentView = [[UIView alloc] init];
    [self addSubview:self.contentView];
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = YES;
    
    // conetent的子控件
    self.titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.subTitleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.subTitleLabel];
    self.subTitleLabel.font = [UIFont systemFontOfSize:15];
    self.subTitleLabel.numberOfLines = 0;
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.doneBtn = [[UIButton alloc] init];
    [self.contentView addSubview:self.doneBtn];
    [self.doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    self.doneBtn.backgroundColor = kContentDoneBtnBgColor;
    [self.doneBtn setTitleColor:kContentDoneBtnTextColor forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(doneClicked) forControlEvents:UIControlEventTouchUpInside];
    self.doneBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    self.doneBtn.layer.cornerRadius = 2;
    self.doneBtn.layer.masksToBounds = YES;
    
    self.contentView.backgroundColor = kContentBgColor;
    self.titleLabel.textColor = kContentTitleColor;
    self.subTitleLabel.textColor = kContentSubTitleColor;
    self.bottomView.backgroundColor = kBottomBgColor;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    
    __weak typeof(self) weakSelf = self;
    self.bottomView.clickedHandler = ^(UIButton *btn){
        [weakSelf contentAction:btn];
    };
}

// UI布局
- (void)layoutUI
{
    if (self.contentType == LaunchContentTypeAlert) {
        // webView设定
        self.webView.frame = CGRectZero;
        self.webView.hidden = YES;
        self.bottomView.frame = CGRectZero;
        self.bottomView.hidden = YES;
        
        // contentView设定
        CGFloat height = self.frame.size.height;
        CGFloat width = self.frame.size.width;
        CGFloat contentX = 20;
        CGFloat contentW = width - contentX * 2;
        
        // title计算
        CGFloat margin = 10;
        CGFloat titleX = margin;
        CGFloat titleY = margin;
        CGFloat titleW = contentW - titleY*2;
        CGFloat titleH = 30;
        
        // subTitle的高度计算
        CGFloat subX = titleX;
        CGFloat subW = titleW;
        CGFloat subY = titleY+titleH+13;
        CGSize subSize = [self.subTitleLabel sizeThatFits:CGSizeMake(subW, MAXFLOAT)];
        CGFloat subH = subSize.height + margin;
        
        // doneBtn
        CGFloat doneH = 40;
        CGFloat doneY = subY + subH + margin;
        CGFloat doneW = subW;
        CGFloat doneX = titleX;
        
        CGFloat contentH = doneY + doneH + margin;
        CGFloat contentY = (height - contentH) *0.5;
        
        self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
        self.subTitleLabel.frame = CGRectMake(subX, subY, subW, subH);
        self.doneBtn.frame = CGRectMake(doneX, doneY, doneW, doneH);
        self.contentView.frame = CGRectMake(contentX, contentY, contentW, contentH);
        
    } else if (self.contentType == LaunchContentTypeLoading) {
        
        self.contentView.frame = CGRectZero;
        self.contentView.hidden = YES;
        
        CGFloat height = self.frame.size.height;
        CGFloat width = self.frame.size.width;
        
        // 判断是否为iPhoneX
        CGFloat bottomSpace = 0;
        if (@available(iOS 11.0, *)) { // iphonex safearea
            bottomSpace = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        }
        
        CGFloat bottomH = kBottomBtnHeight+bottomSpace;
        self.webView.frame = CGRectMake(0, 0, width, height - bottomH);
        self.bottomView.frame = CGRectMake(0, height - bottomH, width, bottomH);
    } else {
        
        self.webView.frame = CGRectZero;
        self.webView.hidden = YES;
        self.bottomView.frame = CGRectZero;
        self.bottomView.hidden = YES;
        self.contentView.frame = CGRectZero;
        self.contentView.hidden = YES;
        
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled  = NO;
    }
}

// done按钮点击
- (void)doneClicked
{
    [self removeFromSuperview];
}


// 模拟alert的动画
- (void)animationAlert:(UIView *)view
{
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.6;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [view.layer addAnimation:popAnimation forKey:nil];
}
@end


