#import "WindowController.h"
#import "RegexKitLite.h"

@interface WindowController ()
@property (retain) TaskWrapper* task;
@property (assign) BOOL isRunning;
@end

@implementation WindowController
- (void)dealloc
{
	[task stopProcess];
	[task release];
	[super dealloc];
}

@synthesize task, isRunning;

- (TaskWrapper*)taskWithTarget:(NSString*)target
{
	return [[[TaskWrapper alloc] initWithController:self
                                         arguments:[NSArray arrayWithObjects:@"/usr/bin/make", target, nil]
                                  workingDirectory:@"/Users/ciaran/code/avian-build"] autorelease];
}

// ===========
// = Actions =
// ===========

- (void)startTask:(TaskWrapper*)aTask
{
	BOOL changeTask = YES;
	if(self.isRunning)
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
	static NSDictionary* const attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont fontWithName:@"DejaVuSansMono" size:11], NSFontAttributeName, nil];
	NSMutableAttributedString* string = [[[NSMutableAttributedString alloc] initWithString:output attributes:attributes] autorelease];

	NSRange matchedRange = {0, 0};
	while(matchedRange.location < output.length)
	{
		matchedRange = [output rangeOfRegex:@"^(/[^:]+?):(\\d+)?"
                                  options:RKLMultiline
                                  inRange:NSMakeRange(matchedRange.location, output.length - matchedRange.location)
                                  capture:0
                                    error:NULL];
		if(matchedRange.location != NSNotFound)
		{
			NSArray* components   = [[output substringWithRange:matchedRange] componentsSeparatedByString:@":"];
			NSString* path        = [components objectAtIndex:0];
			NSUInteger lineNumber = [[components objectAtIndex:1] intValue];
			[string addAttribute:NSLinkAttributeName
                        value:[NSString stringWithFormat:@"txmt://open?url=file://%@&line=%d", path, lineNumber]
                        range:matchedRange];
		}
		matchedRange.location += matchedRange.length + 1;
	}

	[consoleView.textStorage appendAttributedString:string];
	[consoleView scrollRangeToVisible:NSMakeRange(consoleView.textStorage.length, 0)]; // TODO Only scroll if scroller is at bottom
}

- (void)processStarted
{
	[[[consoleView textStorage] mutableString] appendString:@"=== STARTED ===\n"];
	self.isRunning = YES;
}

- (void)processFinished
{
	self.isRunning = NO;
	[[[consoleView textStorage] mutableString] appendString:@"=== ENDED ===\n"];
}
@end
