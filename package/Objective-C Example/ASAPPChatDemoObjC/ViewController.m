//
//  ViewController.m
//  ASAPPChatDemoObjC
//
//  Created by Mitchell Morgan on 8/4/16.
//  Copyright © 2016 ASAPP, Inc. All rights reserved.
//

@import ASAPPSDK;

#import "ViewController.h"

@interface ViewController () <ASAPPDelegate>
@property (nonatomic, strong) UIButton *pushButton;
@property (nonatomic, strong) UIButton *presentButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupASAPP];
    
    self.title = @"ASAPP Demo Obj-C";
    self.view.backgroundColor = [UIColor whiteColor];

    self.pushButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.pushButton setTitle:@"Push Transition" forState:UIControlStateNormal];
    [self.pushButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.pushButton setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.pushButton addTarget:self action:@selector(pushToASAPPChat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pushButton];
    
    self.presentButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.presentButton setTitle:@"Present Transition" forState:UIControlStateNormal];
    [self.presentButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.presentButton setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.presentButton addTarget:self action:@selector(presentASAPPChat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.presentButton];
}

#pragma mark - ASAPP

- (void)setupASAPP
{
#warning Update your credentials before running.
    
    NSString *appId = nil;
    NSString *apiHostName = nil;
    NSString *regionCode = nil;
    NSString *clientSecret = nil;
    
    NSAssert(appId != nil & apiHostName != nil && regionCode != nil && clientSecret != nil,
             @"You must set your appId, apiHostName, regionCode, and clientSecret in ViewController.m before running.");
    
    /**
     ASAPPConfig
     
     Set up your ASAPP Config here. This only needs to be performed once.
     A typical setup would place this code in the app's delegate file, but
     was placed here for convenience.
     */
    ASAPPConfig *config = [[ASAPPConfig alloc] initWithAppId:appId
                                               apiHostName:apiHostName
                                               clientSecret:clientSecret
                                               regionCode:regionCode];
    [ASAPP initializeWith:config];
    
    /**
     ASAPPDelegate
     
     Set the delegate, which should implement chatViewControllerDidTapUserLoginButton().
     */
    ASAPP.delegate = self;
    
    /**
     ASAPPUser
     
     Set the current user of the app.  The user identifer should be unique to the user.
     this could be an email address or some other internal identifier.
     
     This demo app automatically creates a fake user id and persists it between sessions.
     */
    ASAPPUser *user = [[ASAPPUser alloc] initWithUserIdentifier:self.userIdentifier requestContextProvider:^NSDictionary<NSString *,id> * (BOOL needsRefresh) {
        return @{
                 [ASAPP authTokenKey]: @"ios_objc_access_token",
                 @"fake_context_key_1": @"fake_context_value_1"
        };
    }];
    
    [ASAPP setUser:user];
    
    /**
     ASAPPFontFamily
     
     You can define a font family to be used by the SDK's default styles.
     */
    ASAPPFontFamily *avenirNext = [[ASAPPFontFamily alloc]
                                   initWithLight:[UIFont fontWithName:@"AvenirNext-Regular" size:16]
                                   regular:[UIFont fontWithName:@"AvenirNext-Medium" size:16]
                                   medium:[UIFont fontWithName:@"AvenirNext-DemiBold" size:16]
                                   bold:[UIFont fontWithName:@"AvenirNext-Bold" size:16]];
    
    /**
     ASAPPStyles
     
     The chat sdk can be stylized to fit your brand.
     */
    [ASAPP.styles.textStyles updateStylesFor:avenirNext];
    
    ASAPP.styles.textStyles.navButton = [[ASAPPTextStyle alloc] initWithFont:avenirNext.bold size:12 letterSpacing:0 color:UIColor.whiteColor case:ASAPPCaseStyleOriginal];
    
    /**
     ASAPPStrings
     
     The strings displayed in the SDK can be customized by accessing ASAPP.strings...
     */
    ASAPP.strings.chatTitle = @"Demo Chat";
}

- (void)handleASAPPDeepLink:(NSString *)deepLink withData:(NSDictionary *)data
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DeepLink"
                                                                   message:deepLink
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)pushToASAPPChat
{
    UIViewController *viewController = [ASAPP createChatViewControllerForPushingFromNotificationWith:nil];
    if (viewController != nil) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}

- (void)presentASAPPChat
{
    UIViewController *viewController = [ASAPP createChatViewControllerForPresentingFromNotificationWith:nil];
    if (viewController != nil) {
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

#pragma mark - User Identifier (Handled Automatically)


- (NSString *)userIdentifier
{
    static NSString *savedCustomerIdKey = @"saved_user_id";
    NSString *customerId = [[NSUserDefaults standardUserDefaults] stringForKey:savedCustomerIdKey];
    if (!customerId) {
        customerId = [NSString stringWithFormat:@"sample_user_id-%@",
                      @(floor([NSDate new].timeIntervalSinceReferenceDate))];
        
        [[NSUserDefaults standardUserDefaults] setObject:customerId forKey:savedCustomerIdKey];
    }
    
    NSLog(@"Using user identifier: %@", customerId);
    
    return customerId;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize buttonSize = CGSizeMake(self.view.bounds.size.width, 50.0);
    CGPoint viewCenter = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    CGFloat buttonSpacing = buttonSize.height + 20.0;
    
    self.pushButton.bounds = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    self.pushButton.center = CGPointMake(viewCenter.x, viewCenter.y - buttonSpacing);
    
    self.presentButton.bounds = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    self.presentButton.center = CGPointMake(viewCenter.x, viewCenter.y + buttonSpacing);
}

#pragma mark - ASAPPDelegate

- (void)chatViewControllerDidTapUserLoginButton
{
    /**
     Application should present UI to let user login. Once login is finished, ASAPP.user should be set.
     
     Note: if the user is always logged in, the body of this method may be left blank.
     */
}

- (void)chatViewControllerDidTapDeepLinkWithName:(NSString * _Nonnull)name data:(NSDictionary<NSString *,id> * _Nullable)data {
    [self handleASAPPDeepLink:name withData:data];
}

- (void)chatViewControllerDidDisappear {}

- (BOOL)chatViewControllerShouldHandleWebLinkWithUrl:(NSURL * _Nonnull)url {
    return true;
}

- (void)chatViewControllerDidReceiveChatEventWithName:(NSString * _Nonnull)name data:(NSDictionary<NSString *,id> * _Nullable)data {
    // Application can respond to certain agreed-upon events that can occur during a chat.
}

@end
