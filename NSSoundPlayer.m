//
//  NSSoundPlayer.m
//  audioplayer
//
//  Created by Colin on 28/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSSoundPlayer.h"
#import <Growl/Growl.h>
#import <QuickTime/QTSMovie.h>
#include <AudioToolbox/AudioToolbox.h>

@implementation NSSoundPlayer

NSMutableArray *_files;
static NSSound *_sound;
BOOL *_paused = TRUE;
BOOL *_shuffle = FALSE;
int *_trackNumber;
NSData *_growlIcon;
NSString *_next;

- (id)initWithFiles:(NSArray *)files {
	if (self = [super init]) {
		_files = [[NSMutableArray alloc] initWithArray:files];
	}
	
	NSBundle *qtKitBundle = [NSBundle bundleWithIdentifier:@"com.apple.QTKit"];
	
	NSBundle *myBundle = [NSBundle bundleForClass:[NSSoundPlayer class]]; 
	NSString *growlPath = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"]; 
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath]; 
	NSString *myImagePath = [[[NSBundle mainBundle] resourcePath]  stringByAppendingPathComponent:@"vol_white.icns"];

	NSImage *img = [[NSImage alloc] initWithContentsOfFile:myImagePath];
	_growlIcon = [img TIFFRepresentation];
	[_growlIcon retain];
	
	if (growlBundle && [growlBundle load]) { 
		// Register ourselves as a Growl delegate 
		[GrowlApplicationBridge setGrowlDelegate:self]; 
	} 
	else { 
		NSLog(@"Could not load Growl.framework"); 
	}
	
	return self;
}

- (void)play {
	
	if([_files count] > 0) {

		[self playOrPause];
		_sound = NULL;
		
		_trackNumber = 0;
		if (_shuffle)
		{
			srandom(time(NULL));
			_trackNumber = random() % [_files count];
		}
		
		AudioFileID audioFile;
		CFURLRef theURL = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, (UInt8*)_next, strlen(_next), FALSE);
		
		
			//OSType udType;
			//udTYpe = GetNextUserDataType(<#UserData theUserData#>, <#OSType udType#>)
		
		_next = [_files objectAtIndex:(NSInteger)_trackNumber];
		NSLog(_next);
		
		[self displayInfo];
		
		[_files removeObjectAtIndex:(NSInteger)_trackNumber];	
		_sound = [[NSSound alloc] initWithContentsOfFile:_next byReference:NO];
		[_sound setDelegate:self];
		[_sound play];
	}
}

- (BOOL)toggleShuffle {
	if(_shuffle) {
		_shuffle = FALSE;
	} else{
		_shuffle = TRUE;
	}	
	return _shuffle;
}

- (void)stop {
	[_sound stop];	
}

- (void)skip {
	[_sound stop];
}

- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying {
	[self play];
}

- (void)playOrPause {
	if(_paused) {
		[_sound resume];
		_paused = FALSE;
	} else{
		[_sound pause];
		_paused = TRUE;
	}
}

- (void)displayInfo {
	[self displayMessage:@"Current Song" :@"audioplayer" :[[NSString alloc]initWithFormat: @"%@", [_next lastPathComponent]]];		
}

- (void)displayMessage:(NSString *)notification :(NSString *)title :(NSString *)description{
	
	[GrowlApplicationBridge notifyWithTitle:title
								description:description
						   notificationName:notification
								   iconData:_growlIcon
								   priority:0
								   isSticky:NO
							   clickContext:[NSDate date]];
}

@end