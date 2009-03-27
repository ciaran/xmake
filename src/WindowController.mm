#import "WindowController.h"

@interface WindowController ()
@property (retain) TaskWrapper* task;
@property (assign) BOOL isRunning;
@property (readonly) NSString* buildPath;
@property (readonly) NSString* sourcePath;
@property (retain) OutputParser* parser;
@end

@implementation WindowController
- (void)dealloc
{
	self.parser = nil;
	[task stopProcess];
	[task release];
	[super dealloc];
}

@synthesize task, isRunning, parser;

- (NSString*)buildPath
{
	return [[[[NSUserDefaults standardUserDefaults] stringForKey:@"BuildPath"] stringByStandardizingPath] stringByAppendingString:@"/"];
}

- (NSString*)sourcePath
{
	return [[[[NSUserDefaults standardUserDefaults] stringForKey:@"SourcePath"] stringByStandardizingPath] stringByAppendingString:@"/"];
}

- (TaskWrapper*)taskWithTarget:(NSString*)target
{
	return [[[TaskWrapper alloc] initWithController:self
                                         arguments:[NSArray arrayWithObjects:@"/usr/bin/make", target, nil]
                                  workingDirectory:self.buildPath] autorelease];
}

- (void)setStatusText:(NSString*)text
{
	[statusField setStringValue:text];
}

// ===========
// = Actions =
// ===========

- (void)startTask:(TaskWrapper*)aTask
{
	BOOL changeTask = YES;
	if(!self.buildPath)
	{
		NSRunAlertPanel(@"No build path", @"Set the build directory in preferences.", @"OK", nil, nil);
		changeTask = NO;
	}
	else if(self.isRunning)
	{
		int choice = NSRunAlertPanel(@"Stop task?", @"The currently running task will have to be aborted first.", @"OK", @"Cancel", nil);
		changeTask = (choice == NSAlertDefaultReturn); // "OK"
	}
	if(changeTask)
	{
		[consoleView setString:@""];
		self.task = aTask;
		[self.task startProcess];
	}
}

- (IBAction)build:(id)sender
{
	[self startTask:[self taskWithTarget:nil]];
}

- (IBAction)buildAndRun:(id)sender
{
	[self startTask:[self taskWithTarget:@"run"]];
}

- (IBAction)run:(id)sender
{
	[self startTask:[self taskWithTarget:@"run/fast"]];
}

// =========================
// = TaskWrapperController =
// =========================

- (void)appendOutput:(NSString*)output
{
	NSAttributedString* string = [parser processOutput:output];
	[progressIndicator setDoubleValue:parser.progressValue];
	[consoleView.textStorage appendAttributedString:string];
	[consoleView scrollRangeToVisible:NSMakeRange(consoleView.textStorage.length, 0)]; // TODO Only scroll if scroller is at bottom
}

- (void)processStarted
{
	self.parser = [[[OutputParser alloc] init] autorelease];
	parser.sourcePath = self.sourcePath;
	[[[consoleView textStorage] mutableString] appendString:@"=== STARTED ===\n"];
	[progressIndicator setDoubleValue:0];
	self.isRunning = YES;
	[self setStatusText:@"Started"];
}

- (void)processFinished
{
	if(self.isRunning)
	{
		self.isRunning = NO;
		[[[consoleView textStorage] mutableString] appendString:@"=== ENDED ===\n"];
	}
	[self setStatusText:@"Idle"];
}
@end
