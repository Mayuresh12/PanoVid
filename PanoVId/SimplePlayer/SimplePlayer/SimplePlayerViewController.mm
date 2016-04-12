//
//  SimplePlayerViewController.m
//  SimplePlayer
//
//  Created by Ron Bakker on 18-06-13.
//  Copyright (c) 2013 Mindlight. All rights reserved.
//

#import "SimplePlayerViewController.h"
#import <Panframe/Panframe.h>


@interface SimplePlayerViewController () <PFAssetObserver, PFAssetTimeMonitor>
{
    PFView * pfView;
    id<PFAsset> pfAsset;
    enum PFNAVIGATIONMODE currentmode;
    bool touchslider;
    NSTimer *slidertimer;
    int currentview;

    
    }

- (void) onStatusMessage : (PFAsset *) asset message:(enum PFASSETMESSAGE) m;
- (void) onPlayerTime:(id<PFAsset>)asset hasTime:(CMTime)time;

@end

@implementation SimplePlayerViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    
    
    currentmode = PF_NAVIGATION_MOTION;
    currentview = 0;
   
    
    pfView = [PFObjectFactory viewWithFrame:[self.view bounds]];
    pfView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    // set the appropriate navigation mode PFView
    [pfView setNavigationMode:PF_NAVIGATION_MOTION];
    
    // add the view to the current stack of views
    [self.view addSubview:pfView];
    [self.view sendSubviewToBack:pfView];
    [pfView setViewMode:3 andAspect:16.0/9.0];
    
    // Set some parameters
    [self resetViewParameters];
    
    // start rendering the view
    [pfView run];
    
    // create a Panframe asset
    [self createAssetWithUrl:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"panovid" ofType:@"mov"]]];
    
    [pfAsset play];

    
}

-(void)onPlaybackTime:(NSTimer *)timer
{
    // retrieve the playback time from an asset and update the slider
    
    if (pfAsset == nil)
        return;
    if (!touchslider && [pfAsset getStatus] != PF_ASSET_SEEKING)
    {
        CMTime t = [pfAsset getPlaybackTime];
        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [self resetViewParameters];
}

- (void) resetViewParameters
{
    // set default FOV
    [pfView setFieldOfView:75.0f];
    // register the interface orientation with the PFView
    [pfView setInterfaceOrientation:self.interfaceOrientation];
    switch(self.interfaceOrientation)
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            // Wider FOV which for portrait modes (matter of taste)
            [pfView setFieldOfView:90.0f];
            break;
        default:
            break;
    }
}

- (void) createHotspots
{
    /*// create some sample hotspots on the view and register a callback
    
    id<PFHotspot> hp1 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp2 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp3 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp4 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp5 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp6 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    
    [hp1 setCoordinates:0 andX:0 andZ:0];
    [hp2 setCoordinates:40 andX:5 andZ:0];
    [hp3 setCoordinates:80 andX:1 andZ:0];
    [hp4 setCoordinates:120 andX:-5 andZ:0];
    [hp5 setCoordinates:160 andX:-10 andZ:0];
    [hp6 setCoordinates:220 andX:0 andZ:0];
    
    [hp1 setSize:4];
    
    [hp3 setSize:2];
    [hp3 setAlpha:0.5f];
    
    [hp1 setTag:1];
    [hp2 setTag:2];
    [hp3 setTag:3];
    [hp4 setTag:4];
    [hp5 setTag:5];
    [hp6 setTag:6];
    
    [hp1 addTarget:self action:@selector(onHotspot:)];
    [hp2 addTarget:self action:@selector(onHotspot:)];
    [hp3 addTarget:self action:@selector(onHotspot:)];
    [hp4 addTarget:self action:@selector(onHotspot:)];
    [hp5 addTarget:self action:@selector(onHotspot:)];
    [hp6 addTarget:self action:@selector(onHotspot:)];*/
}

- (void) onHotspotFocusIn:(id<PFHotspot>) hotspot
{
    NSLog(@"IN");
    [hotspot setSize:5];
}

- (void) onHotspotFocusOut:(id<PFHotspot>) hotspot
{
    NSLog(@"OUT");
    [hotspot setSize:4];
}


- (void) onHotspot:(id<PFHotspot>) hotspot
{
    NSLog(@"OUT - %d", [hotspot getTag]);
    [hotspot animate];
}

- (void) createView
{
    // initialize an PFView
    pfView = [PFObjectFactory viewWithFrame:[self.view bounds]];
    pfView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    // set the appropriate navigation mode PFView
    [pfView setNavigationMode:currentmode];
    
    // set an optional blackspot image
    [pfView setBlindSpotImage:@"blackspot.png"];
    [pfView setBlindSpotLocation:PF_BLINDSPOT_BOTTOM];
    
    // add the view to the current stack of views
    [self.view addSubview:pfView];
    [self.view sendSubviewToBack:pfView];
    
    [pfView setViewMode:3 andAspect:16.0/9.0];
    //[pfView setHitOnFocus:true];
    
    // Set some parameters
    [self resetViewParameters];
    
    // start rendering the view
    [pfView run];

}


- (void) deleteView
{
    // stop rendering the view
    [pfView halt];
    
    // remove and destroy view
    [pfView removeFromSuperview];
    pfView = nil;
}

- (void) createAssetWithUrl:(NSURL *)url
{
    touchslider = false;
    
    // load an PFAsset from an url
    pfAsset = (id<PFAsset>)[PFObjectFactory assetFromUrl:url observer:(PFAssetObserver*)self];
    [pfAsset setTimeMonitor:self];
    // connect the asset to the view
    [pfView displayAsset:(PFAsset *)pfAsset];
}

- (void) deleteAsset
{
    if (pfAsset == nil)
        return;
    
    // disconnect the asset from the view
    [pfAsset setTimeMonitor:nil];
    [pfView displayAsset:nil];
    // stop and destroy the asset
    [pfAsset stop];
    pfAsset  = nil;
}

- (void) onPlayerTime:(id<PFAsset>)asset hasTime:(CMTime)time
{
}

- (void) onStatusMessage : (id<PFAsset>) asset message:(enum PFASSETMESSAGE) m
{
   /* CMTime t = [asset getDuration];
    
    switch (m) {
        case PF_ASSET_SEEKING:
            NSLog(@"Seeking");
            seekindicator.hidden = FALSE;
            break;
        case PF_ASSET_PLAYING:
            NSLog(@"Playing");
            seekindicator.hidden = TRUE;
            slider.maximumValue = CMTimeGetSeconds(t);
            slider.minimumValue = 0.0;
            [playbutton setTitle:@"pause" forState:UIControlStateNormal];
            slider.enabled = true;
            break;
        case PF_ASSET_PAUSED:
            NSLog(@"Paused");
            [playbutton setTitle:@"play" forState:UIControlStateNormal];
            break;
        case PF_ASSET_COMPLETE:
            NSLog(@"Complete");
            [asset setTimeRange:CMTimeMakeWithSeconds(0, 1000) duration:kCMTimePositiveInfinity onKeyFrame:NO];
            break;
        case PF_ASSET_STOPPED:
            NSLog(@"Stopped");
            [self stop];
            slider.value = 0;
            slider.enabled = false;
            break;
        case PF_ASSET_BUFFER_EMPTY:
            NSLog(@"Buffer empty");
            break;
        case PF_ASSET_BUFFER_FULL:
            NSLog(@"Buffer full");
            break;
        case PF_ASSET_BUFFER_KEEPING_UP:
            NSLog(@"Buffer keeping up");
            break;
        default:
            break;
    }*/
}


- (void) stop
{
    // stop the view
    [pfView halt];
    
    // delete asset and view
    [self deleteAsset];
    [self deleteView];
    
}

- (IBAction) stopButton:(id) sender
{
    /*
    if (pfAsset == nil)
        return;
    */
    [self stop];
}


@end
