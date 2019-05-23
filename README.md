# save-my-ears

Launch agent that resets volume to a lower value whenever a headphone/earphone is connected to your Mac.

### Why? and How?

Mac by default has two output data sources on its sound device - internal speaker and external output (through 3.5mm audio jack).

The volume for these data sources is maintained separately. However, there is no concept of a default volume. The last used volume on the data source becomes default volume for that data source.

Lets say your are using headphone (external output) in 100% volume (may be for a call) and next time when you plug in the headphone, the volume will be 100% and without realizing that you might end up playing music like I did once.

`save-my-ears` will listen to changes in sound device and whenever an external output device like headphone is plugged in to the audio jack it will reset the volume to 25%.

## Install

```
brew tap thecasualcoder/stable
brew install save-my-ears
brew services start save-my-ears
```

## Logs

Logs are written to `~/.save-my-ears.log`.
