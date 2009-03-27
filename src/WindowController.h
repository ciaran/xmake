#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"
#import "OutputParser.h"

@interface WindowController : NSWindowController <TaskWrapperController>
{
	IBOutlet NSTextView* consoleView;
	TaskWrapper* task;
	IBOutlet NSProgressIndicator* busyIndicator;
	IBOutlet NSProgressIndicator* progressIndicator;
	IBOutlet NSTextField* statusField;
	BOOL isRunning;
	OutputParser* parser;
}
@property (readonly) BOOL isRunning;
- (IBAction)build:(id)sender;
- (IBAction)buildAndRun:(id)sender;
- (IBAction)run:(id)sender;
@end
