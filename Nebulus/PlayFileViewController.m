//
//  PlayFileViewController.m
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 12/16/13.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import "PlayFileViewController.h"
#import "RecordingHttpClient.h"

@implementation PlayFileViewController

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

//------------------------------------------------------------------------------
#pragma mark - Status Bar Style
//------------------------------------------------------------------------------

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
    // if you don't do this!
    //
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }
    
    //
    // Customizing the audio plot's look
    //
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.816 green: 0.349 blue: 0.255 alpha: 1];
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    
    NSLog(@"outputs: %@", [EZAudioDevice outputDevices]);
    
    //
    // Create the audio player
    //
    self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
    self.player.shouldLoop = YES;
    
    // Override the output to the speaker
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (error)
    {
        NSLog(@"Error overriding output to the speaker: %@", error.localizedDescription);
    }
    
    //
    // Customize UI components
    //
    self.rollingHistorySlider.value = (float)[self.audioPlot rollingHistoryLength];
    
    //
    // Listen for EZAudioPlayer notifications
    //
    [self setupNotifications];
    
    /*
     Try opening the sample file
     */
    [self openFileWithFilePathURL:[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:self.fileName]]];
    
    UIBarButtonItem *downloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Download"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(download)];
    
    self.navigationItem.rightBarButtonItem = downloadButton;
}

-(void)download{
//    NSData *recording = [RecordingHttpClient getRecording:self.recordingId];
//    
//    [recording writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
//                                                      [self applicationDocumentsDirectory],
//                                                      self.fileName]]  atomically:YES];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download"
//                                                    message:@"Downloading finished."
//                                                   delegate:self
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Download" message:@"Enter file name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setText:self.fileName];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *filename = [alertView textFieldAtIndex:0];
    NSLog(@"%@",filename.text);
    NSData *recording = [RecordingHttpClient getRecording:self.recordingId];
    
    [recording writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                                  [self applicationDocumentsDirectory],
                                                  filename.text]]  atomically:YES];
}

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeAudioFile:)
                                                 name:EZAudioPlayerDidChangeAudioFileNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeOutputDevice:)
                                                 name:EZAudioPlayerDidChangeOutputDeviceNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:self.player];
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeAudioFile:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed audio file: %@", [player audioFile]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeOutputDevice:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed output device: %@", [player device]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangePlayState:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player change play state, isPlaying: %i", [player isPlaying]);
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)changePlotType:(id)sender
{
    NSInteger selectedSegment = [sender selectedSegmentIndex];
    switch(selectedSegment)
    {
        case 0:
            [self drawBufferPlot];
            break;
        case 1:
            [self drawRollingPlot];
            break;
        default:
            break;
    }
}

//------------------------------------------------------------------------------

- (void)changeRollingHistoryLength:(id)sender
{
    float value = [(UISlider *)sender value];
    [self.audioPlot setRollingHistoryLength:(int)value];
}

//------------------------------------------------------------------------------

- (void)changeVolume:(id)sender
{
    float value = [(UISlider *)sender value];
    [self.player setVolume:value];
}

//------------------------------------------------------------------------------

- (void)openFileWithFilePathURL:(NSURL *)filePathURL
{
    //
    // Create the EZAudioPlayer
    //
    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL];
    
    //
    // Update the UI
    //
    self.filePathLabel.text = filePathURL.lastPathComponent;
    self.positionSlider.maximumValue = (float)self.audioFile.totalFrames;
    self.volumeSlider.value = [self.player volume];
    
    //
    // Plot the whole waveform
    //
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
                                                         int length)
    {
        [weakSelf.audioPlot updateBuffer:waveformData[0]
                          withBufferSize:length];
    }];
    
    //
    // Play the audio file
    //
    [self.player setAudioFile:self.audioFile];
}

//------------------------------------------------------------------------------

- (void)play:(id)sender
{
    if ([self.player isPlaying])
    {
        [self.player pause];
        [((UIButton *)sender) setTitle:@"Play" forState:UIControlStateNormal];
    }
    else
    {
        if (self.audioPlot.shouldMirror && (self.audioPlot.plotType == EZPlotTypeBuffer))
        {
            self.audioPlot.shouldMirror = NO;
            self.audioPlot.shouldFill = NO;
        }
        [self.player play];
        [((UIButton *)sender) setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

//------------------------------------------------------------------------------

- (void)seekToFrame:(id)sender
{
    [self.player seekToFrame:(SInt64)[(UISlider *)sender value]];
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlayerDelegate
//------------------------------------------------------------------------------

- (void)  audioPlayer:(EZAudioPlayer *)audioPlayer
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
          inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.audioPlot updateBuffer:buffer[0]
                          withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf.positionSlider.touchInside)
        {
            weakSelf.positionSlider.value = (float)framePosition;
        }
    });
}

//------------------------------------------------------------------------------
#pragma mark - Utility
//------------------------------------------------------------------------------

/*
 Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input eample)
 */
- (void)drawBufferPlot
{
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldMirror = NO;
    self.audioPlot.shouldFill = NO;
}

//------------------------------------------------------------------------------

/*
 Give the classic mirrored, rolling waveform look
 */
- (void)drawRollingPlot
{
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
}

//------------------------------------------------------------------------------
- (NSArray *)applicationDocuments
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

//------------------------------------------------------------------------------
- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
//------------------------------------------------------------------------------

@end
