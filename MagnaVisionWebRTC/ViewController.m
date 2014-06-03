//
//  ViewController.m
//  MagnaVision
//
//  Created by eSecForte on 22/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "VideoViewController.h"
#include <sys/sysctl.h>
#import "InfoViewController.h"

@interface ViewController ()

@property(nonatomic,assign)NSUInteger serviceHitCount;

@end

@implementation ViewController
@synthesize txtPromoCode;
@synthesize tempAct;

- (void)viewDidLoad
{
    [super viewDidLoad];  
         	// Do any additional setup after loading the view, typically from a nib.
    
    NSString* lastChatKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatKey"];
    txtPromoCode.text = lastChatKey;
    txtPromoCode.autocorrectionType = UITextAutocorrectionTypeNo;
    txtPromoCode.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (void)viewDidUnload
{
    [self setTxtPromoCode:nil];
    [self setTempAct:nil];
    [self setBackground:nil];
    [self setLblEnterAccesCode:nil];
    [self setLblDown:nil];
    [self setBtnGo:nil];
    [super viewDidUnload];
    // Release any retatxined subviews of the main view.
}
-(IBAction)clickToGo:(id)sender
{
    NSString* chatKey = [txtPromoCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (chatKey)
        [[NSUserDefaults standardUserDefaults] setObject:chatKey forKey:@"chatKey"];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES)
    {
        isWatingHit=NO;
        
        [self.tempAct setHidesWhenStopped:NO];
        [self.tempAct startAnimating];
        if(aTimer!=nil)
        {
            [aTimer invalidate];
            aTimer=nil;
        }
        aTimer=  [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(sendDataToServer) userInfo:nil repeats:YES];
     }
else
   {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Camera is not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    }
}
-(void)Show_Loader
{
	progressAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Waiting for your Partner....\n\n\n\n" delegate:self cancelButtonTitle: nil otherButtonTitles: @"Cancel",nil];
	tempActi = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	tempActi.frame = CGRectMake(139.0-18.0, 60, 35, 35);
    [progressAlert addSubview:tempActi];
	[tempActi startAnimating];
	
	[progressAlert show];
}
-(void)Remove_Loader
{
    isWatingHit=NO;
	[progressAlert dismissWithClickedButtonIndex:0 animated:NO];
	
	progressAlert=nil;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex==0)
    {
        [aTimer invalidate];
        aTimer=nil;
        [self.tempAct stopAnimating];
        [self.tempAct setHidesWhenStopped:YES];
        [self Remove_Loader];
        [self performSelector:@selector(performExitAction) withObject:nil afterDelay:0.3];
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=YES;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ((orientation == UIInterfaceOrientationLandscapeLeft) || (orientation == UIInterfaceOrientationLandscapeRight))
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            if(result.height == 480)
            {
                _background.image=[UIImage imageNamed:@"background_Landscape.png"];
                txtPromoCode.frame=CGRectMake(119,57,241,20);
                _lblEnterAccesCode.frame=CGRectMake(116,20,200,35 );
                _lblDown.frame=CGRectMake(116,85,224,21);
                _btnGo.frame=CGRectMake(280,110,77,37);
                tempAct.frame=CGRectMake(325,12,37,37);
            }
            if(result.height == 568)
            {
                _background.image=[UIImage imageNamed:@"iPhone5BG_Port.png"];
                txtPromoCode.frame=CGRectMake(119+60,47,216,20);
                _lblEnterAccesCode.frame=CGRectMake(116+60,20-10,200,35 );
                _lblDown.frame=CGRectMake(116+60,70,224,21);
                _btnGo.frame=CGRectMake(280+60,110,77,37);
                tempAct.frame=CGRectMake(325+60,12,37,37);

            }
        }
        
    }
    else
    {
                      
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            if(result.height == 480)
            {
                _background.image=[UIImage imageNamed:@"background.png"];
                txtPromoCode.frame=CGRectMake(49,128,223,21);
                _lblEnterAccesCode.frame=CGRectMake(45,83,200,35 );
                _lblDown.frame=CGRectMake(45,164,224,21);
                _btnGo.frame=CGRectMake(194,207,77,37);
                tempAct.frame=CGRectMake(252,74,37,37);
            }
            if(result.height == 568)
            {
                _background.image=[UIImage imageNamed:@"iPhone5BG_Land.png"];
                _lblEnterAccesCode.frame=CGRectMake(49+5,80,200,35 );
                txtPromoCode.frame=CGRectMake(49+5,128-13,218,21);
                _lblDown.frame=CGRectMake(49+5,164-25,224,21);
                _btnGo.frame=CGRectMake(194,207-13,77,37);
                tempAct.frame=CGRectMake(252,74-13,37,37);
            }
        }

        
    }

    [self.tempAct setHidesWhenStopped:YES];
    [super viewWillAppear:YES];
}
-(unsigned int)calculateCPUCount
{
    size_t len;
    unsigned int ncpu;
    len = sizeof(ncpu);
    sysctlbyname ("hw.ncpu",&ncpu,&len,NULL,0);
    return ncpu;
}

-(NSString*)getChatKey;
{
    NSString* outKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatKey"];
    if (outKey == nil)
        outKey = @"";
    return outKey;
}


-(void)sendDataToServer
{
    NSLog(@"Hitting service....");
    
   if ([[self getChatKey] length]==0)
   {
       [aTimer invalidate];
       aTimer=nil;
       [self.tempAct stopAnimating];
       [self.tempAct setHidesWhenStopped:YES];

       UIAlertView *Alert = [[UIAlertView alloc]
                                  initWithTitle: @"Error"
                                  message: @"Please enter passkey"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
       [Alert show];
      
       return;
   }
   
   
    
    NSString *cpuCountStr=@"dual";
//    if ([self calculateCPUCount]==1)
//       cpuCountStr=@"single";

   NSString *post =[NSString stringWithFormat:@"passkey=%@&devicetype=%@&count=%d",[self getChatKey],cpuCountStr,self.serviceHitCount];
   NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
   NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
   NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //[request setURL:[NSURL URLWithString:@"http://magnavision.webfactional.com/waiting_webservice.php"]]; //Staging WebService
    
    [request setURL:[NSURL URLWithString:@"http://magnavision360.com/waiting_webservice.php"]]; //Prod Web Service
    
   [request setHTTPMethod:@"POST"];
   [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
   [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
   [request setHTTPBody:postData];
   
   NSHTTPURLResponse *response=nil;
   NSError *err=nil;
   
    NSData *data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    self.serviceHitCount++;
    
    //if (err != nil)
       // NSLog(@"remote url returned %d %@",(NSInteger)[response statusCode],[NSHTTPURLResponse localizedStringForStatusCode:response sta]);

    
    if (err==nil)
    {
        NSMutableDictionary *dictJSON=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&err];
        if (err)
            NSLog(@"Error on json %@",[err description]);
        NSMutableArray *arrEntery=[dictJSON objectForKey:@"data"];
        if ([arrEntery count]!=0)
        {
            NSMutableDictionary *dict2=[arrEntery objectAtIndex:0];
            NSMutableArray *arr=[dict2 objectForKey:@"data"];
            NSMutableDictionary *dict3=[arr objectAtIndex:0];
            
            if ([dict3 objectForKey:@"passkey_id"]!=nil)
            {
                [aTimer invalidate];
                aTimer=nil;
                [self Remove_Loader];
                [self.tempAct stopAnimating];
                [self.tempAct setHidesWhenStopped:YES];
                NSString *pdstrSession=[dict3 objectForKey:@"pd_session_id"];
                NSString *pdstrToken=[dict3 objectForKey:@"pd_host_token"];
                
                NSString *pestrSession=[dict3 objectForKey:@"pe_session_id"];
                NSString *pestrToken=[dict3 objectForKey:@"pe_host_token"];
                
                
                NSString *strWebRtc=[dict3 objectForKey:@"webrtc"];;
                NSString *passkey_id=[dict3 objectForKey:@"passkey_id"];

    #if NON_WEB_RTC
                BOOL rightApp = ![strWebRtc isEqualToString:@"Y"];
                NSString* session = pdstrSession;
                NSString* token = pdstrToken;
                NSString* otherSession = pestrSession;
                NSString* otherToken = pestrToken;
    #else
                BOOL rightApp = [strWebRtc isEqualToString:@"Y"];
                NSString* session = pestrSession;
                NSString* token = pestrToken;
                NSString* otherSession = pdstrSession;
                NSString* otherToken = pdstrToken;
    #endif
               
               NSString* connType = @"Client";
               if ([[self getChatKey] length]>8)
                    connType = @"Host";
               
                if (rightApp)
                {
                    if (session != nil)
                    {
                        VideoViewController *obj = nil;
                        UIStoryboard *mainStoryboard;
                        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
                            mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
                            obj = [mainStoryboard instantiateViewControllerWithIdentifier:@"videoViewIpad"];
                        }
                        else
                        {
                            mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                            obj = [mainStoryboard instantiateViewControllerWithIdentifier:@"videoViewIphone"];
                        }
                        
                        //VideoViewController *obj=[[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:[NSBundle mainBundle]];
                        obj.strToke=token;
                        obj.strSession=session;
                        obj.strPassKey_Id= passkey_id;
                        obj.strFrmuType = connType;
                        txtPromoCode.text= [self getChatKey]; //Tom or empty string?
                        [self.navigationController pushViewController:obj animated:YES];
                     
                        [self.tempAct stopAnimating];
                    }
                }
                else
                {
                    if (otherSession != nil)
                    {
                        [self openReceiverApp:otherSession with:otherToken with:passkey_id with:connType];
                    }
                }                
            }
            else 
            {
                if ([dict2 objectForKey:@"Waiting"]!=nil)
                {
                    if (isWatingHit==NO)
                    {
                        isWatingHit=YES;
                        [self.tempAct stopAnimating];
                        [self.tempAct setHidesWhenStopped:YES];
                        [txtPromoCode resignFirstResponder];
                        [self Show_Loader];
                    }
                }
                else
                {
                
                    [aTimer invalidate];
                    aTimer=nil;
                    [self.tempAct stopAnimating];
                    [self.tempAct setHidesWhenStopped:YES];
                    [self Remove_Loader];

                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:[dict2 objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
              
                    self.serviceHitCount = 0; //Reset counter in case of error
                
                }
            }
        } 
        else // if response recieved, but nothing found // this else reached if there was no 'data' returned from magnavision's server
        {
            [aTimer invalidate];
            aTimer=nil;
            [self.tempAct stopAnimating];
            [self.tempAct setHidesWhenStopped:YES];
            [self Remove_Loader];
            UIAlertView *errorAlert = [[UIAlertView alloc]
                           initWithTitle: @"Error"
                           message: @"You have entered wrong passkey"
                           delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil];
            [errorAlert show];
           

        }
    }
    else // if no response at all from server 
    {
        [self Remove_Loader];
        [aTimer invalidate];
        aTimer=nil;
        [self.tempAct stopAnimating];
        [self.tempAct setHidesWhenStopped:YES];
        UIAlertView *errorAlert = [[UIAlertView alloc]
                   initWithTitle: @"Error"
                   message: @"Network connection fail"
                   delegate:nil
                   cancelButtonTitle:@"OK"
                   otherButtonTitles:nil];
        [errorAlert show];
      
    }   
   
}


-(void)performExitAction
{
 
     NSString* chatKey = [txtPromoCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *post =[NSString stringWithFormat:@"passkey=%@",chatKey];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //[request setURL:[NSURL URLWithString:@"http://magnavision.webfactional.com/exit_webservice.php"]]; // Staging WebService
    [request setURL:[NSURL URLWithString:@"http://magnavision360.com/exit_webservice.php"]];    //Prod Webservice
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
            //[self.navigationController popViewControllerAnimated:YES];
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


//-(IBAction)info:(id)sender
//{
//    InfoViewController *objTempHelp =[[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:[NSBundle mainBundle]];
//    [self.navigationController pushViewController:objTempHelp animated:YES];
//   
//}


-(void) openReceiverApp:(NSString *)session with :(NSString *)Token with :(NSString *)passkey_id with :(NSString *)strFrmuType
{
    //txtPromoCode.text=@"";
    [self.tempAct stopAnimating];
    [self.tempAct setHidesWhenStopped:YES];

    // Opens the Receiver app if installed, otherwise displays an error
    UIApplication *ourApplication = [UIApplication sharedApplication];
    NSString *URLEncodedText = [[NSString stringWithFormat:@"%@,%@,%@,%@,",session,Token,passkey_id,strFrmuType] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* errorTitle = nil;
    NSString* errorMSG = nil;
#if NON_WEB_RTC
    NSString *ourPath = [@"readtextWebRtc://" stringByAppendingString:URLEncodedText];
    errorTitle = @"Magnavision.net WebRTC v2.1 app Not Found";
    errorMSG = @"For this communication Magnavision.net WebRTC v2.1 app must be installed,Please download from appstore.";
#else
    NSString *ourPath = [@"TextNonWebRtc://" stringByAppendingString:URLEncodedText];
    errorTitle = @"Magnavision.net NonWebRTC v2.1 app Not Found";
    errorMSG = @"For this communication Magnavision.net NonWebRTC v2.1 app must be installed,Please download from appstore.";
#endif
    NSURL *ourURL = [NSURL URLWithString:ourPath];
    if ([ourApplication canOpenURL:ourURL])
    {
        [ourApplication openURL:ourURL];
    }
    else
    {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorTitle message:errorMSG delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)||(interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

//-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
//{
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.29f];
//	[UIView setAnimationDelegate:self];
//           if ((orientation == UIInterfaceOrientationLandscapeLeft) || (orientation == UIInterfaceOrientationLandscapeRight))
//        {
//            
//            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//            {
//
//              CGSize result = [[UIScreen mainScreen] bounds].size;
//                if(result.height == 480)
//                {
//                    _background.image=[UIImage imageNamed:@"background_Landscape.png"];
//                    txtPromoCode.frame=CGRectMake(119,57,241,20);
//                    _lblEnterAccesCode.frame=CGRectMake(116,20,200,35 );
//                    _lblDown.frame=CGRectMake(116,85,224,21);
//                    _btnGo.frame=CGRectMake(280,110,77,37);
//                    tempAct.frame=CGRectMake(325,12,37,37);
//                }
//                if(result.height == 568)
//                {
//                    _background.image=[UIImage imageNamed:@"iPhone5BG_Port.png"];
//                    txtPromoCode.frame=CGRectMake(119+60,47,216,20);
//                    _lblEnterAccesCode.frame=CGRectMake(116+60,20-10,200,35 );
//                    _lblDown.frame=CGRectMake(116+60,70,224,21);
//                    _btnGo.frame=CGRectMake(280+60,110,77,37);
//                    tempAct.frame=CGRectMake(325+60,12,37,37);
//                }
//            }
//
//        }
//        else
//        {
//            
//            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//            {
//                _background.image=[UIImage imageNamed:@"background.png"];
//
//                CGSize result = [[UIScreen mainScreen] bounds].size;
//                if(result.height == 480)
//                {
//                    txtPromoCode.frame=CGRectMake(49,128,223,21);
//                    _lblEnterAccesCode.frame=CGRectMake(45,83,200,35 );
//                    _lblDown.frame=CGRectMake(45,164,224,21);
//                    _btnGo.frame=CGRectMake(194,207,77,37);
//                    tempAct.frame=CGRectMake(252,74,37,37);
//                }
//                if(result.height == 568)
//                {
//                    _background.image=[UIImage imageNamed:@"iPhone5BG_Land.png"];
//                    _lblEnterAccesCode.frame=CGRectMake(49+5,80,200,35 );
//                    txtPromoCode.frame=CGRectMake(49+5,128-13,218,21);
//                    _lblDown.frame=CGRectMake(49+5,164-25,224,21);
//                    _btnGo.frame=CGRectMake(194,207-13,77,37);
//                    tempAct.frame=CGRectMake(252,74-13,37,37);
//                }
//            }
//        }
//    [UIView commitAnimations];
//
//   }

-(void)viewWillDisappear:(BOOL)animated
{
    //txtPromoCode.text=@"";
    [super viewDidDisappear:YES];
}
//- (void)dealloc
//{
//    [txtPromoCode release];
//    [tempAct release];
//    [_background release];
//    [_lblEnterAccesCode release];
//    [_lblDown release];
//    [_btnGo release];
//    [super dealloc];
//}
@end
