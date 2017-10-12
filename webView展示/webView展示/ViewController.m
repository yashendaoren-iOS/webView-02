//
//  ViewController.m
//  webView展示
//
//  Created by Silver on 2017/4/6.
//  Copyright © 2017年 Silver. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"
#import "RelateModel.h"


static NSString * const picMethodName = @"openBigPicture:";
static NSString * const videoMethodName = @"openVideoPlayer:";

static NSString * const didScrollMethodName = @"didscrollTo:";


//屏幕宽高
#define CZTVSCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define CZTVSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>{

    WKUserContentController * userContentController;

}
@property (nonatomic, copy) NSString *titleStr;    //新闻标题
@property (nonatomic, copy) NSString *timeStr;     //发布时间
@property (nonatomic, copy) NSString *sourceStr;   //来源
@property (nonatomic, copy) NSString *authorStr;   //作者

@property (nonatomic, strong) NSString *contentBodyStr;   //新闻内容

@property (nonatomic, strong) NSMutableArray *widthArr;      //存放图片宽度
@property (nonatomic, strong) NSMutableArray *heightArr;     //存放高度
@property (nonatomic, strong) NSMutableArray *imageUrlArr;   //存放图片url
@property (nonatomic, strong) NSMutableArray *imagePlaceholderArr;  //存放图片占位符 <!--IMG#1-->

@property (nonatomic, assign) NSInteger imageCount;         //图片多少
@property (nonatomic, assign) CGFloat contentFont;          //设置字体大小

@property (nonatomic, strong) NSMutableArray *relateContsArr;   //相关新闻
@property (nonatomic, strong) NSMutableArray *commentArr;       //评论

//点击图片
@property(nonatomic,strong)UIImageView *showImageView;
@property(nonatomic,strong)UIView *bacgroundView;        //点击某个图片后图片出现的底板
@property (nonatomic, strong) UIButton *downLoadButton;
//点击视频
//@property (nonatomic, strong) MyYFPlayerView *yfPlayerView;  //播放模板
@property (nonatomic, assign) CGRect currnetFrame1; //播放器的bottomView的frame
@property (nonatomic, assign) CGRect currentFrame2; // 总时间的frame
@property (nonatomic, assign) CGRect currentFrame3; //全屏按钮的frame

@property (nonatomic, strong) WKWebView *wkWebView;        //ios8之后出现的用来替代webView，需要引入头文件#import<WebKit/WebKit.h>
//@property (nonatomic, strong) XHMainShareView *shareView; //分享
//@property (nonatomic, strong) GifView *gifView;  //加载动画
@property (nonatomic, copy) NSString *newsId;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //创建一个WKWebView的配置对象
    WKWebViewConfiguration *configur = [[WKWebViewConfiguration alloc] init];
    
    //设置configur对象的preferences属性的信息
    WKPreferences *preferences = [[WKPreferences alloc] init];
    configur.preferences = preferences;
    
    //是否允许与js进行交互，默认是YES的，如果设置为NO，js的代码就不起作用了
    preferences.javaScriptEnabled = YES;
    
    //注册供js调用的方法
    userContentController =[[WKUserContentController alloc]init];
    configur.userContentController = userContentController;
    configur.preferences.javaScriptEnabled = YES;
    configur.allowsInlineMediaPlayback = NO;
    
    //    WKUserContentController *userContentControlle = [[WKUserContentController alloc]init];
    [userContentController addScriptMessageHandler:self name:@"openBigPicture"];
    [userContentController addScriptMessageHandler:self name:@"openVideoPlayer"];
    
    [userContentController addScriptMessageHandler:self name:@"didscrollTo"];

    
    configur.userContentController = userContentController;
    if (!self.wkWebView) {
        self.wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, CZTVSCREEN_WIDTH, CZTVSCREEN_HEIGHT) configuration:configur];
    }
    [self.view addSubview:_wkWebView];
    self.wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _wkWebView.backgroundColor = [UIColor clearColor];
    _wkWebView.UIDelegate = self;
    _wkWebView.navigationDelegate = self;
    _wkWebView.allowsBackForwardNavigationGestures =YES;//打开网页间的 滑动返回
    _wkWebView.scrollView.bounces = NO;
    _wkWebView.scrollView.scrollEnabled = YES;
    
    [self loadData:_newsId];

}

- (void)loadData:(NSString *)newsId{
    NSURL *url = [NSURL URLWithString:@"http://newsapp.cztv.com/clt/publish/clt/resource/portal/v1/commonNews.jsp?c=4435656&WD_CP_ID=000000&WD_VERSION=5.0.2&WD_CHANNEL=M801004A&WD_UA=&WD_UUID=7FC71BAE-B03C-4CD7-BEFF-79A27E83437E&loginName=&salt=9f3d2d3593a53838&encrypt=ac21eb0a6635566e6906054ba09d5dbd"];
    
//    NSURL *url = [NSURL URLWithString:@"http://newsapp.cztv.com/clt/publish/clt/resource/portal/v1/commonNews.jsp?c=4435719&WD_CP_ID=000000&WD_VERSION=5.0.2&WD_CHANNEL=M801004A&WD_UA=&WD_UUID=7FC71BAE-B03C-4CD7-BEFF-79A27E83437E&loginName=&salt=9f3d2d3593a53838&encrypt=ac21eb0a6635566e6906054ba09d5dbd "];
//    NSURL *url = [NSURL URLWithString:@"http://newsapp.cztv.com/clt/publish/clt/resource/portal/v1/commonNews.jsp?c=4435705&WD_CP_ID=000000&WD_VERSION=5.0.2&WD_CHANNEL=M801004A&WD_UA=&WD_UUID=7FC71BAE-B03C-4CD7-BEFF-79A27E83437E&loginName=&salt=9f3d2d3593a53838&encrypt=ac21eb0a6635566e6906054ba09d5dbd"];
//    NSURL *url = [NSURL URLWithString:@"http://newsapp.cztv.com/clt/publish/clt/resource/portal/v1/commonNews.jsp?c=4433921&WD_CP_ID=000000&WD_VERSION=5.0.2&WD_CHANNEL=M801004A&WD_UA=&WD_UUID=7FC71BAE-B03C-4CD7-BEFF-79A27E83437E&loginName=&salt=9f3d2d3593a53838&encrypt=ac21eb0a6635566e6906054ba09d5dbd"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    __weak typeof(self) weakSelf = self;

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            //6.解析服务器返回的数据
            //说明：（此处返回的数据是JSON格式的，因此使用NSJSONSerialization进行反序列化处理）
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            NSLog(@"%@",dict);
            NSDictionary *object = dict;
            NSDictionary *contentDic = [object objectForKey:@"content"];
            weakSelf.authorStr = [NSString stringWithFormat:@"编辑：%@", [contentDic objectForKey:@"author"]];
            weakSelf.titleStr = [contentDic objectForKey:@"name"];
            weakSelf.timeStr = [contentDic objectForKey:@"pubTime"];
            weakSelf.sourceStr = [NSString stringWithFormat:@" 来源：%@", [contentDic objectForKey:@"source"]];
            
            NSArray *contentArray = [contentDic objectForKey:@"content"];
            NSMutableString *contentStr = [NSMutableString string];
            for (NSInteger i = 0; i < contentArray.count; i++) {
                NSDictionary *dic = contentArray[i];
                NSString *bodyStr = dic[@"content"];
                NSString *bodyString = [bodyStr stringByReplacingOccurrencesOfString:@"\n" withString:@"<p style=\"margin:5px 0\"></p>"];
                [contentStr appendString:bodyString];
                
                if (i == (contentArray.count- 1)) {
                    NSString *logoStr = [NSString stringWithFormat:@"<img style=\"vertical-align:middle;\" width=\"20\" height=\"20\" src=\"%@\"> </p>", [[NSBundle mainBundle] URLForResource:@"news_detail_logo.png" withExtension:nil]];
                    contentStr = [contentStr stringByAppendingString:logoStr].mutableCopy;
                }
                
                NSArray *imageArr = dic[@"imageInfoList"];
                if (imageArr.count != 0) {
                    for (NSDictionary *imageDic in imageArr) {
                        weakSelf.imageCount ++;
                        NSArray *imageVideoArr = imageDic[@"videoUrls"];
                        if (imageVideoArr.count != 0) {
                            //获取视频的高度
                            NSString *heightStr = imageDic[@"height"];
                            CGFloat heightNumber;
                            if (heightStr.length != 0) {
                                heightNumber = [heightStr floatValue];
                            } else{
                                heightNumber = 300;
                            }
                            //获取视频的宽度
                            NSString *widthStr = imageDic[@"width"];
                            CGFloat widthNumber;
                            if (widthStr.length != 0) {
                                widthNumber = [widthStr floatValue];
                            } else{
                                widthNumber = 400;
                            }
                            NSLog(@"实际高度是:%f", (CZTVSCREEN_WIDTH -45)*heightNumber/widthNumber);
                            
                            NSString* playeUrl = [imageVideoArr objectAtIndex:0][@"playUrl"];
                            //视频设置
                            [contentStr appendString:[NSString stringWithFormat:@"<div><p align=\"center\"><video id=\"video0\" width=\"100%%\"  poster = \"%@\" src=\"%@\" preload=\"none\"></video></p><div class=\"button01\" style=\"height:%fpx; margin-top:-%fpx\"></div></div>", imageDic[@"url"], playeUrl, (CZTVSCREEN_WIDTH -45)*heightNumber/widthNumber, (CZTVSCREEN_WIDTH -45)*heightNumber/widthNumber+27]];
                        } else{
                            [contentStr appendString:[NSString stringWithFormat:@"<!--IMG#%ld-->", (long)_imageCount - 1]];
                            [weakSelf.imagePlaceholderArr addObject:[NSString stringWithFormat:@"<!--IMG#%ld-->", (long)_imageCount - 1]];
                            [weakSelf.heightArr addObject:imageDic[@"height"]];
                            [weakSelf.widthArr addObject:imageDic[@"width"]];
                            [weakSelf.imageUrlArr addObject:imageDic[@"url"]];
                        }
                    }
                }
                NSLog(@"=============数据是：%@", contentStr);
            }
            
            NSMutableArray *tempRelateArr = [NSMutableArray arrayWithCapacity:0];
            NSArray *relateArr = [object objectForKey:@"relateConts"];
            if (relateArr.count != 0) {
                for (NSDictionary *dic in relateArr) {
                    RelateModel *model = [RelateModel relateModelWithDic:dic];
                    [tempRelateArr addObject:model];
                }
            }
            
            weakSelf.contentBodyStr = contentStr.copy;
            self.relateContsArr = tempRelateArr;
            //加载webView
            [self showInWkWebView];
        }else{
            NSLog(@"数据请求失败");

        
        }
    }];
    
    //5.执行任务
    [dataTask resume];

}


#pragma mark - ******************** wkWebView + html
- (void)showInWkWebView
{
    // NSLog(@"html源码是：%@", [self getHtmlString]);
    // 初始化engine引擎.
    MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
    //[engine setDelegate:self];
    [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    
    // 这里就是设置，或者里边塞变量的地方
    [engine setObject:_titleStr forKey:@"title"];
    [engine setObject:_timeStr forKey:@"date"];
    if (_sourceStr.length != 0) {
        [engine setObject:_sourceStr forKey:@"source"];
    }
    
    NSString *detailStr = [self getBodyString];  //获取主内容
    [engine setObject:detailStr forKey:@"details"];
    [engine setObject:_authorStr forKey:@"author_name"];
    
    // MGTemplateEngine/Detail/detail.html
    // MGTemplateEngine/Detail/style.css
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"detail" ofType:@"html"];
    // 处理引擎样板并加载结果
    NSString *html = [engine processTemplateInFileAtPath:templatePath withVariables:nil];
//    NSLog(@"新闻内容是:%@", html);
    // 你就能加载到HTML里面的.css文件
    NSString *baseURL = [[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"];

//    NSString *baseURL = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"style"];
    
    [self.wkWebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:baseURL]];
    
}

- (NSString *)getBodyString
{
    NSMutableString *body = [NSMutableString string];
    [body appendFormat:@"<font size=\"%f\">", self.contentFont];
    if (self.contentBodyStr != nil) {
        [body appendString:self.contentBodyStr];
    }
    
    for (NSInteger i = 0; i < _widthArr.count; i ++ ) {
        
        NSMutableString *imgHtml = [NSMutableString string];
        // 设置img的div
        [imgHtml appendString:@"<div class=\"img-parent\">"];
        CGFloat width = [[_widthArr objectAtIndex:i] floatValue];
        CGFloat height = [[_heightArr objectAtIndex:i] floatValue];
        // 判断是否超过最大宽度
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width * 0.96;
        if (width > maxWidth) {
            height = maxWidth / width * height;
            width = maxWidth;
        }
        
        NSString *iamgeUrl = [_imageUrlArr objectAtIndex:i];
        [imgHtml appendFormat:@"<img  width=\"100%%\" src=\"%@\">", iamgeUrl];
        
        [body replaceOccurrencesOfString:_imagePlaceholderArr[i] withString:imgHtml options:NSCaseInsensitiveSearch range:NSMakeRange(0, body.length)];
    }
    [body appendString:@"</font>"];
    return body;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    [webView evaluateJavaScript:@"document.getElementById(\"container\").offsetHeight;" completionHandler:^(id _Nullable result, NSError *_Nullable error) {
        
        //获取页面高度，并重置webview的frame
        CGFloat documentHeight = [result floatValue]+10;
        //        NSLog(@"网页的高度:%lf", documentHeight);
        // 重设webview内容大小
        CGRect frame = _wkWebView.frame;
        frame.size.height = documentHeight;
        _wkWebView.frame = frame;
        
    }];
//    [self.gifView removeFromSuperview];
//    self.gifView = nil;
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
//    [self.gifView removeFromSuperview];
//    self.gifView = nil;
//    [self showTextToast:@"新闻加载失败，请重试"];
}
#pragma mark - WKScriptMessageHandler

/*
 1、js调用原生的方法就会走这个方法
 2、message参数里面有2个参数我们比较有用，name和body，
 2.1 :其中name就是之前已经通过addScriptMessageHandler:name:方法注入的js名称
 2.2 :其中body就是我们传递的参数了，我在js端传入的是一个字典，所以取出来也是字典，字典里面包含原生方法名以及被点击图片的url
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //NSLog(@"%@,%@",message.name,message.body);
    
    NSDictionary *imageDict = message.body;
    NSString *src = [NSString string];
    if (imageDict[@"imageSrc"]) {
        src = imageDict[@"imageSrc"];
    }else if(imageDict[@"videoSrc"]){
        src = imageDict[@"videoSrc"];
    }else{
        src = imageDict[@"str"];
    }
    NSString *name = imageDict[@"methodName"];
    
    //如果方法名是我们需要的，那么说明是时候调用原生对应的方法了
    if ([picMethodName isEqualToString:name]) {
        SEL sel = NSSelectorFromString(picMethodName);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
        //写在这个中间的代码,都不会被编译器提示PerformSelector may cause a leak because its selector is unknown类型的警告
        [self performSelector:sel withObject:src];
#pragma clang diagnostic pop
    }else if ([videoMethodName isEqualToString:name]){
        
        SEL sel = NSSelectorFromString(name);
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
        
        [self performSelector:sel withObject:src];
#pragma clang diagnostic pop
        
    }else if([didScrollMethodName isEqualToString:name]){
        SEL sel = NSSelectorFromString(name);
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
        
        [self performSelector:sel withObject:src];
    
    }
}
#pragma mark - JS调用 OC的方法进行图片浏览
- (void)openBigPicture:(NSString *)imageSrc
{
        NSLog(@">>>>>>>>>_%@",imageSrc);

}
#pragma mark - JS调用 OC的方法进行视频播放
- (void)openVideoPlayer:(NSString *)videoSrc
{
        NSLog(@">>>>>>>>>_%@",videoSrc);

}

#pragma mark - JS调用 OC的方法进行视频播放
- (void)didscrollTo:(NSString *)str
{
    NSLog(@"========>>>>>>>>>_%@",str);


}





@end
