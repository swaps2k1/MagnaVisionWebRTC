//
//  VideoViewController.m
//  MagnaVision
//
//  Created by eSecForte on 22/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenTok/OTError.h>

@interface VideoViewController ()
{
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    NSTimer *timerForPeriodicHit;
}
@end

const BOOL kUseButtons = YES; // whether or not to use the buttons Exit and pause at the bottom

static NSString*  kToken ;
static NSString*  kSessionId;

static NSString* const kApiKey = @"29127052"; // was @"8893232" previous to May 13 2013;
static bool subscribeToSelf = NO; // Change to NO if you want to subscribe streams other than your own

@implementation VideoViewController

@synthesize strToke;
@synthesize strSession;
@synthesize strFrmuType;
@synthesize strPassKey_Id;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DoBackGround)
                                                 name:@"EnteringBackGround"
                                               object:nil];
    
    
      btnDisconnect.hidden=YES;
    isDisConnected=NO;
   
}

UIBackgroundTaskIdentifier bgTask = 0;
-(void)killApp;
{
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    exit(0);
}

-(void)DoBackGround
{
    //return; // we seem to hang in here, so we just let the app quit, as it does for background operation
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    }];
    
    if (_publisher!=NULL)
    {
        _session.delegate = nil;
        _subscriber.delegate = nil;
        _publisher.delegate = nil;
        [self doUnpublish];
        [_session disconnect];
        [_subscriber close];
        _subscriber = nil;
    }
    
    [self performSelector:@selector(killApp) withObject:nil afterDelay:0.45];
    
}
//-(void)dealloc
//{
//    //IMPORTANT - set any delegates to nil!
//    _session.delegate = nil;
//    _subscriber.delegate = nil;
//    _publisher.delegate = nil;
//    [_subscriber release];
//    [_publisher release];
//    [_session release];
//    
//    [strSession release];
//    [strToke release];
//    [btnConnection release];
//    [btnDisconnect release];
//    [_btnExit release];
//    [_lblConnectivity release];
//    [super dealloc];
//}


-(IBAction)connectButtonClicked:(UIButton*)button
{
    btnConnection.userInteractionEnabled=NO;
    isDisConnected=NO;
    [self doConnect];
}

- (IBAction)disconnectButtonClicked:(UIButton*)button
{
    isDisConnected=YES;
    btnDisconnect.userInteractionEnabled=NO;
    [self doDisconnect];
}

-(void)timerInitialize
{
    if (timerForPeriodicHit!=nil) {
        [timerForPeriodicHit invalidate];
        timerForPeriodicHit = nil;
    }
    timerForPeriodicHit = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateThatIAmConnected:) userInfo:nil repeats:YES];
    NSLog(@"Timer Starts...");
}
-(void)disableTimer
{
    if (timerForPeriodicHit) {
        [timerForPeriodicHit invalidate];
        timerForPeriodicHit = nil;
    }
    NSLog(@"Timer Ends...");
}

-(void)updateThatIAmConnected:(NSTimer *)timer
{
    
    NSLog(@"Update... I am connected...");
    NSString *post =[NSString stringWithFormat:@"passkey_id=%@&frmutype=%@",strPassKey_Id,strFrmuType];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //[request setURL:[NSURL URLWithString:@"http://magnavision.net/exit_webservice.php"]];
    [request setURL:[NSURL URLWithString:@"http://magnavision.webfactional.com/checkActive_webservice.php"]];
    //URL signature changed
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSOperationQueue *queueOperation= [[NSOperationQueue alloc]init];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:queueOperation completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"Response Code is %@",response.description);
    }];
}

-(void)performExitAction
{
    
    NSString *post =[NSString stringWithFormat:@"passkey_id=%@&frmutype=%@",strPassKey_Id,strFrmuType];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //[request setURL:[NSURL URLWithString:@"http://magnavision.net/exit_webservice.php"]];
    [request setURL:[NSURL URLWithString:@"http://magnavision.webfactional.com/exit_webservice.php"]];
    //URL signature changed
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response=nil;
    NSError *err=nil;
    
    NSData *data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    if (err==nil)
    {
        NSMutableDictionary *dictJSON=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
        NSMutableArray *arrEntery=[dictJSON objectForKey:@"data"];
        NSMutableDictionary *dict2=[arrEntery objectAtIndex:0];
        NSString *strRes=[dict2 objectForKey:@"Success"];
//        if ([strRes isEqualToString:@"You have been successfully exited from Video Conference"])
        if(strRes!=nil)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle: @"Error"
                                       message: @"Exit Fail"
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
            [errorAlert show];
            
        }
    }
    else {
        
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle: @"Error"
                                   message: @"Network connection fail"
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];
        
    }
}

- (IBAction)exitButtonClicked:(UIButton*)button
{
    [self performExitAction];
}
- (void)publishButtonClicked:(UIButton*)button
{
    [self doPublish];
}

- (void)unpublishButtonClicked:(UIButton*)button
{
    [self doUnpublish];
}


- (void)unsubscribeButtonClicked:(UIButton*)button
{
    _subscriber.delegate = nil;
    [_subscriber close];
    _subscriber = nil;
}

- (void)viewDidUnload
{
    [self setBtnExit:nil];
    [self setLblConnectivity:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    if (_publisher==NULL)
    {
        kToken=strToke ;
        kSessionId=strSession;
        [self doConnect];
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    btnConnection.hidden = YES;
    btnDisconnect.hidden = YES;
    [self setupFrames:orientation];

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;

   if (_publisher!=NULL)
   {
       if (isDisConnected==NO) {
           [self doUnpublish];
       }
       
        _subscriber.delegate = nil;
        [_session disconnect];
        [_subscriber close];
        _subscriber = nil;
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


- (void)updateSubscriber
{
    for (NSString* streamId in _session.streams) 
    {
        OTStream* stream = [_session.streams valueForKey:streamId];
        if (![stream.connection.connectionId isEqualToString:_session.connection.connectionId]) {
            _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            break;
        }
    }
}

#pragma mark - OpenTok methods

- (void)doConnect 
{
    NSLog(@"OTSession alloc");
    _session = [[OTSession alloc] initWithSessionId:kSessionId
                                           delegate:self];
// we don't need to know the connection count, it seems. This was also crashing on a tear down of the client.
//    [_session addObserver:self
//               forKeyPath:@"connectionCount"
//                  options:NSKeyValueObservingOptionNew
//                  context:nil];
    [_session connectWithApiKey:kApiKey token:kToken];

}

- (void)doDisconnect 
{  
    [_session disconnect];
}

-(void)setupFrames:(UIInterfaceOrientation)orientation;
{
   //const CGFloat kButtonHeight = 37;
   CGFloat kButtonHeight = 37; // do not show buttons. They don't do anything.
   if (!kUseButtons)
        kButtonHeight = 0.0;
    
   const CGFloat kLLBLHeight = 21;
   // arrange all views.
   // When vertically orientated, we split vertically, else horixontally.
   // buttons go at the bottom
    CGRect mainViewRect = self.streamView.bounds;
    
    CGRect rectForVideos = mainViewRect;
    //rectForVideos.size.height -= (kButtonHeight + kLLBLHeight);
    
    CGRect publishRect = CGRectZero;
    CGRect subscribeRect = CGRectZero;
    if (mainViewRect.size.height > mainViewRect.size.width)
    {
        publishRect = rectForVideos;
        publishRect.size.height = rectForVideos.size.height/2.0;

        subscribeRect = rectForVideos;
        subscribeRect.size.height = rectForVideos.size.height/2.0;
        subscribeRect.origin.y += rectForVideos.size.height/2.0;
    }
    else
    {
        publishRect = rectForVideos;
        publishRect.size.width = rectForVideos.size.width/2.0;

        subscribeRect = rectForVideos;
        subscribeRect.size.width = rectForVideos.size.width/2.0;
        subscribeRect.origin.x += rectForVideos.size.width/2.0;
    }
    
    CGRect bottomArea = mainViewRect;
    bottomArea.size.height = kButtonHeight;
    bottomArea.origin.y = mainViewRect.size.height - kButtonHeight;
    
    CGRect buttonExitRect = bottomArea;
    buttonExitRect.size.width = bottomArea.size.width;//bottomArea.size.width/2.0 for half size
    
    CGRect rightButtonRect = bottomArea;
    rightButtonRect.size.width = bottomArea.size.width/2.0;
    rightButtonRect.origin.x = bottomArea.size.width/2.0;
    
    CGRect lblFrame = mainViewRect;
    lblFrame.size.height = kLLBLHeight;
    lblFrame.origin.y = mainViewRect.size.height - kButtonHeight - kLLBLHeight;
    
    
    //[_btnExit setFrame:buttonExitRect];
    //[btnConnection setFrame:rightButtonRect];
    //[btnDisconnect setFrame:rightButtonRect];
    //[_lblConnectivity setFrame:lblFrame];
    [_publisher.view setFrame:publishRect];
    [_subscriber.view setFrame:subscribeRect];
    [self.streamView addSubview:_publisher.view];
    [self.streamView addSubview:_subscriber.view];
    
    UIView *coverUpView1 = [[UIView alloc]initWithFrame:CGRectZero];
    CGRect coverUpFrame = publishRect;
    coverUpFrame.size.height = 35;
    coverUpView1.frame = coverUpFrame;
    coverUpView1.backgroundColor = [UIColor blackColor];
    coverUpView1.alpha = 0.9;

    [_publisher.view addSubview:coverUpView1];
    [_subscriber.view addSubview:coverUpView1];
    
    if (kButtonHeight == 0)
    {
        btnDisconnect.hidden = YES;
        btnConnection.hidden = YES;
        _btnExit.hidden = YES;
    }
}

-(NSString *)returnCorrectString:(NSString *)passingString
{
    
    NSString *returnString = nil;
    if ([passingString length]>8)
    {
        NSArray *stringArray = [passingString componentsSeparatedByString:@"-"];
        returnString = [stringArray objectAtIndex:1];
    }
    else
        returnString = passingString;
    return returnString;
}

- (void)doPublish
{
    [self timerInitialize];
    _lblConnectivity.text = [self returnCorrectString:[[NSUserDefaults standardUserDefaults] objectForKey:@"chatKey"]];
    NSLog(@"doPublish called");
    if (_publisher != nil)  //only do once. http://www.tokbox.com/forums/ios/there-is-already-a-publisher-on-this-session-crash-t12893 
        return;
    
    _publisher = [[OTPublisher alloc] initWithDelegate:self name:UIDevice.currentDevice.name];
    _publisher.publishAudio = YES;
    _publisher.publishVideo = YES;
    [_session publish:_publisher];
    
    [self.view addSubview:_publisher.view];
    [self setupFrames:[UIApplication sharedApplication].statusBarOrientation];
    [[_publisher.view layer] setCornerRadius:5.0];
    [[_publisher.view layer] setBorderWidth:4.0];
    [[_publisher.view layer] setBorderColor:[[UIColor whiteColor] CGColor]];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"connectionCount"]) {
        NSLog(@"connectionCount did change");
    }
}

- (void)doUnpublish
{
    [_session unpublish:_publisher];
    if (_publisher)
        _publisher.delegate = nil;
    _publisher = nil;
}


#pragma mark - OTSessionDelegate methods

- (void)sessionDidConnect:(OTSession*)session
{
    if (kUseButtons)
        //btnDisconnect.hidden = NO;
    
    btnConnection.hidden = YES;
    btnConnection.userInteractionEnabled=YES;
    btnDisconnect.userInteractionEnabled=YES;
    NSLog(@"sessionDidConnect called");
    [self performSelector:@selector(doPublish) withObject:nil afterDelay:0.4];
}

- (void)sessionDidDisconnect:(OTSession*)session 
{
    btnDisconnect.hidden = YES;
    [self disableTimer];
    if (kUseButtons)
        //btnConnection.hidden = NO;
    
    btnConnection.userInteractionEnabled=YES;
    btnDisconnect.userInteractionEnabled=YES;
    _lblConnectivity.text = @"not currently connected";
    [self performExitAction];
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
    btnDisconnect.hidden = YES;
    if (kUseButtons)
        btnConnection.hidden = NO;
    btnConnection.userInteractionEnabled=YES;
    btnDisconnect.userInteractionEnabled=YES;
    switch ([error code])
    {
        case OTAuthorizationFailure:
        {
        }
            break;
        case OTInvalidSessionId:
        {
        }
            break;
            
        case OTConnectionFailed:
        {
            //[self disconnectButtonClicked:nil];
        }
            break;
        case OTNoMessagingServer:
        {
        }
            break;
        case OTSDKUpdateRequired:
        {
        }
            break;
        case OTP2PSessionUnsupported:
        {
        }
            break;
        case OTUnknownServerError:
        {
            UIAlertView *alrt=[[UIAlertView alloc] initWithTitle:@"Error" message:@"The client was unable to communicate with the server, possibly due to a version incompatibility" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alrt show];
            
        }
            break;
    }
}

- (void)session:(OTSession*)mySession didDropConnection:(OTConnection *)connection;
{
    NSLog(@"Session did drop connection .....");
    
    [self doUnpublish];
    [self performExitAction];
    //[self doPublish];
    //[self doConnect];
}



- (void)session:(OTSession*)mySession didReceiveStream:(OTStream*)stream
{
    BOOL goAhead = NO;

#if NON_WEB_RTC
    NSString* streamConnectionId = stream.connection.connectionId;
    NSString* ourSessionConnectionId = _session.connection.connectionId;
    
    if ((subscribeToSelf && [streamConnectionId isEqualToString:ourSessionConnectionId]) ||
        (!subscribeToSelf && ![streamConnectionId isEqualToString:ourSessionConnectionId]) )
            goAhead = YES;
#else
    if (![UIDevice.currentDevice.name isEqualToString:stream.name])
        goAhead = YES;
#endif

    if (goAhead)
    {
        NSLog(@"didReceiveStream %@ type: %@, name %@, audio %d, video %d", stream.connection.connectionId, stream.type, stream.name, (int) stream.hasAudio, (int) stream.hasVideo);
        
        //if (!_subscriber && stream.hasVideo)
        if (stream.hasVideo)
        {
            if (_subscriber)
            {
                _subscriber.delegate = nil;
                [_subscriber.view removeFromSuperview];
                //[_subscriber close];
                _subscriber = nil;
            }
            _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            _subscriber.subscribeToAudio = YES;
            _subscriber.subscribeToVideo = YES;
        }
    }
}

- (void)session:(OTSession*)session didDropStream:(OTStream*)stream
{
    if (!subscribeToSelf
        && _subscriber
        && [_subscriber.stream.streamId isEqualToString: stream.streamId]) {
        _subscriber.delegate = nil;
        _subscriber = nil;
        [self updateSubscriber];
    }
}

#pragma mark - OTPublisherDelegate methods

- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error
{
    switch ([error code])
    {
        case OTNoMediaPublished:
        {
        }
            break;
        case OTUserDeniedCameraAccess:
        {
        }
            break;
            
        case OTSessionDisconnected:
        {
            //[self disconnectButtonClicked:nil];
        }
            
    }

}

- (void)publisherDidStartStreaming:(OTPublisher *)publisher
{    
    _lblConnectivity.text = [self returnCorrectString:[[NSUserDefaults standardUserDefaults] objectForKey:@"chatKey"]];
    
    if (_publisher==NULL)
    {
        [btnConnection setTitle:@"Pause" forState:UIControlStateNormal];
        
    }
    else
    {
        [btnConnection setTitle:@"Resume" forState:UIControlStateNormal];
    
    }

}

-(void)publisherDidStopStreaming:(OTPublisher*)publisher
{
    NSLog(@"Publisher did stop streaming.......");
}

#pragma mark - OTSubscriberDelegate methods
- (void)subscriberDidConnectToStream:(OTSubscriber*)subscriber
{
    [self.view addSubview:subscriber.view];
    [self setupFrames:[UIApplication sharedApplication].statusBarOrientation];
    [[subscriber.view layer] setBorderWidth:10.0];
    [[subscriber.view layer] setBorderColor:[[UIColor blackColor] CGColor]];
    _lblConnectivity.text = [self returnCorrectString:[[NSUserDefaults standardUserDefaults] objectForKey:@"chatKey"]];
}

- (void)subscriberVideoDataReceived:(OTSubscriber*)subscriber 
{
       
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error
{
    switch ([error code])
    {
        case OTFailedToConnect:
        {
            
            //[self disconnectButtonClicked:nil];
        }
            break;
        case OTConnectionTimedOut:
        {
            //[self disconnectButtonClicked:nil];
            
        }
            break;
            
        case OTNoStreamMedia:
        {
        }break;
        case OTInitializationFailure:
        {
        }
        break;
            
    }

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
 //return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)||(interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
 return YES;
}

-(void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.29f];
	[UIView setAnimationDelegate:self];
    
    [self setupFrames:orientation];
    [UIView commitAnimations];
}


@end
