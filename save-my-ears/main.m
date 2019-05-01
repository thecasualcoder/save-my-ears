//
//  main.m
//  save-my-ears
//
//  Created by Arunvel Sriram on 30/04/19.
//  Copyright © 2019 Arunvel Sriram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>

UInt32 activeDataSource(AudioDeviceID deviceId, AudioObjectPropertyAddress dataSourceAddr) {
    UInt32 dataSourceId = 0;
    UInt32 dataSourceIdSize = sizeof(UInt32);
    OSStatus status = AudioObjectGetPropertyData(deviceId, &dataSourceAddr, 0, NULL, &dataSourceIdSize, &dataSourceId);
    if (status != kAudioHardwareNoError) {
        printf("Failed to get data source ID. OSStatus: %d", status);
    }
    
    return dataSourceId;
}

void setVolume(AudioDeviceID deviceId, Float32 volume) {
    UInt32 volumeSize = sizeof(Float32);
    OSStatus status;
    
    AudioObjectPropertyAddress leftVolumePropertyAddr = {
        kAudioDevicePropertyVolumeScalar,
        kAudioDevicePropertyScopeOutput,
        1 /*LEFT_CHANNEL*/
    };
    
    AudioObjectPropertyAddress rightVolumePropertyAddr = {
        kAudioDevicePropertyVolumeScalar,
        kAudioDevicePropertyScopeOutput,
        2 /*RIGHT_CHANNEL*/
    };
    
    status = AudioObjectSetPropertyData(deviceId, &leftVolumePropertyAddr, 0, NULL, volumeSize, &volume);
    if (status != kAudioHardwareNoError) {
        printf("Failed to set left channel volume. OSStatus: %d\n", status);
    }
    
    status = AudioObjectSetPropertyData(deviceId, &rightVolumePropertyAddr, 0, NULL, volumeSize, &volume);
    if (status != kAudioHardwareNoError) {
        printf("Failed to set right channel volume. OSStatus: %d\n", status);
    }
    
    printf("Set volume to %.0f%%\n", (volume * 100));
}

int main(int argc, const char * argv[]) {
    const Float32 DEFAULT_VOLUME = 0.25;
    
    // Get default output device address
    AudioDeviceID defaultDevice = 0;
    UInt32 defaultSize = sizeof(AudioDeviceID);
    const AudioObjectPropertyAddress defaultDeviceAddr = {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    OSStatus status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &defaultDeviceAddr, 0, NULL, &defaultSize, &defaultDevice);
    if (status != kAudioHardwareNoError) {
        printf("Failed to get device ID. OSStatus: %d", status);
    }
    
    AudioObjectPropertyAddress dataSourceAddr;
    dataSourceAddr.mSelector = kAudioDevicePropertyDataSource;
    dataSourceAddr.mScope = kAudioDevicePropertyScopeOutput;
    dataSourceAddr.mElement = kAudioObjectPropertyElementMaster;
    
    // Listen to changes in the device
    AudioObjectAddPropertyListenerBlock(defaultDevice, &dataSourceAddr, nil, ^(UInt32 inNumberAddr, const AudioObjectPropertyAddress *inAddr) {
        // Get the active data source
        UInt32 activeDataSourceId = activeDataSource(defaultDevice, dataSourceAddr);
        if (activeDataSourceId == 'ispk') {
            printf("Internal speaker detected. DataSourceID: %d\n", activeDataSourceId);
        } else if (activeDataSourceId == 'hdpn') {
            printf("Headphone/External speaker detected. DataSourceID: %d\n", activeDataSourceId);
            setVolume(defaultDevice, DEFAULT_VOLUME);
        }
    });
    
    CFRunLoopRun();
}
