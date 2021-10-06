// Reference:
//   - https://github.com/asmagill/hs._asm.undocumented.touchdevice/blob/856f98dd700e5c0263fbf74ed9ac9b6d13fac84c/MultitouchSupport.h
//   - https://github.com/Kyome22/OpenMultitouchSupport/blob/master/OpenMultitouchSupport/OpenMTInternal.h

#include <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h>

CF_IMPLICIT_BRIDGING_ENABLED

CF_ASSUME_NONNULL_BEGIN

typedef struct {
	float x;
	float y;
} MTPoint;

typedef struct {
	MTPoint position;
	MTPoint velocity;
} MTVector;

typedef CF_ENUM (int, MTPathStage) {
    kMTPathStageNotTracking,
    kMTPathStageStartInRange,
    kMTPathStageHoverInRange,
    kMTPathStageMakeTouch,
    kMTPathStageTouching,
    kMTPathStageBreakTouch,
    kMTPathStageLingerInRange,
    kMTPathStageOutOfRange,
};

typedef struct {
    int frame;
    double timestamp;
    int identifier; // pathIndex
    MTPathStage stage;
    int fingerID;
    int handID;
    MTVector normalizedVector;
    float total;
    float pressure;
    float angle;
    float majorAxis;
    float minorAxis;
    MTVector absoluteVector;
    int unknown14;
    int unknown15;
    float density;
} MTTouch;

typedef struct CF_BRIDGED_TYPE(id) MTDevice *MTDeviceRef;

typedef void (*MTFrameCallbackFunction)(MTDeviceRef device, MTTouch touches[], int numTouches, double timestamp, int frame);

CFMutableArrayRef MTDeviceCreateList();

bool MTDeviceIsAlive(MTDeviceRef d)
    CF_SWIFT_NAME(getter:MTDevice.isAlive(self:));
bool MTDeviceIsMTHIDDevice(MTDeviceRef d)
    CF_SWIFT_NAME(getter:MTDevice.isMTHIDDevice(self:));
bool MTDeviceIsRunning(MTDeviceRef d)
    CF_SWIFT_NAME(getter:MTDevice.isRunning(self:));

void MTRegisterContactFrameCallback(MTDeviceRef d, MTFrameCallbackFunction callback)
    CF_SWIFT_NAME(MTDevice.registerContactFrameCallback(self:callback:));
void MTUnregisterContactFrameCallback(MTDeviceRef d, MTFrameCallbackFunction callback)
    CF_SWIFT_NAME(MTDevice.unregisterContactFrameCallback(self:callback:));

void MTDeviceStart(MTDeviceRef, int)
    CF_SWIFT_NAME(MTDevice.start(self:_:));

void MTDeviceStop(MTDeviceRef)
    CF_SWIFT_NAME(MTDevice.stop(self:));

void MTDeviceRelease(MTDeviceRef)
    CF_SWIFT_NAME(MTDevice.release(self:));

CF_ASSUME_NONNULL_END

CF_IMPLICIT_BRIDGING_DISABLED
