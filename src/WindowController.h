#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"

@interface WindowController : NSWindowController <TaskWrapperController>
{
	IBOutlet NSTextView* consoleView;
	TaskWrapper* task;
	IBOutlet NSProgressIndicator* busyIndicator;
	IBOutlet NSProgressIndicator* progressIndicator;
	BOOL isRunning;
}
@property (readonly) BOOL isRunning;
- (IBAction)build:(id)sender;
- (IBAction)buildAndRun:(id)sender;
- (IBAction)run:(id)sender;
@end
