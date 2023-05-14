<p><img src="https://raw.githubusercontent.com/lightbeamapps/TriggerKit/main/media/logo.svg" width="100" /></p>

# TriggerKit

<p><strong>Bind MIDI events to code blocks in your application</strong></p>

<p>
<a href="https://github.com/lightbeamapps/TriggerKit/blob/main/LICENSE.md"><img alt="BSD 3-clause" src="https://img.shields.io/badge/License-BSD_3--Clause-blue.svg"></a>
</p>

TriggerKit is a Swift framework for binding events to your app's code. You can use TriggerKit with iOS and iPad applications. MacOS is enabled in the Package, but not currently tested.

TriggerKit is currently in Beta, and as such, may have breaking changes in future releases. When the planned event types are added, I will issue a 1.0 release. 

I would like to thank [Steffan Andrews](https://github.com/orchetect) for their [MIDIKit](https://github.com/orchetect/MIDIKit) library, without which TriggerKit would not be able to exist in it's current form.

The key concept for TriggerKit, is that you can create codable actions for you app and events, and easily store and restore mappings for MIDI and other event types.

## Event Types supported
- MIDI CC ✅
- MIDI Notes ✅

## Event Types planned 🗺️
- OSC
- Gamepad

These event types are planned as additions to TriggerKit, in future releases. Please don't hesitate to open an issue or create a PR for features you need 🙏

## Quick start 🏁

- Add TriggerKit to your project via Swift Package Manager: `https://github.com/lightbeamapps/TriggerKit`

- Create an enumeration of the actions your app wants to map, that conforms to TKAppActionConstraints

- Instantiate the TriggerKit Bus

```swift
let config = TKBusConfig(clientName: "TriggerKit", model: "TriggerKit", manufacturer: "Lightbeam Apps")
let bus = TKBus<YourAppAction>(config: config)
```

- Add Mappings

```swift
let mapping = TKMapping(appAction: TestAcYourAppActiontion.action1, event: TKEvent.midiCC(trigger: .init(cc: 1)))

bus.addMapping(mapping) { payload in
    // Do something!
}

```

You now have a TriggerKit Bus, and your first mapping 🎉!

## Usage and key concepts

### Codable
Once you have created actions and mappings, you can encode these to persist them to disk and retrieve at run time.

### Learning events
You can set a single callback for all events with the bus function:

```swift
bus.setEventCallback() { event in 
    // Use/persist the most recent event to update or add a mapping
}
```

The demo application shows an example of this.

## Examples
- [TriggerKitDemo](https://github.com/lightbeamapps/TriggerKit/tree/main/Examples/TriggerKitDemo/) - a SwiftUI app that shows example mappings, and an event learn set up.

### Inbuilt views for Bluetooth midi

TriggerKit has some wrappers for the CoreAudio BlueTooth MIDI detection views: 
- `TKBluetoothMIDIView` SwiftUI
- `TKBTMIDICentralViewController` UIKit

## Contributing

### Code of Conduct and Contributing rules 🧑‍⚖️

- Our guide to contributing is available here: [CONTRIBUTING.md](CONTRIBUTING.md).
- All contributions, pull requests, and issues are expected to adhere to our community code of conduct: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

### Key contributors ⚡️

#### Admin
- [David Gary Wood](https://social.davidgarywood.com/@davidgarywood)

## License 📃

TriggerKit is licensed with the BSD-3-Clause license, more information here: [LICENSE.MD](LICENSE.md)

This is a permissive license which allows for any type of use, provided the copyright notice is included.

## Acknowledgements 🙏

- MIDIKit, without which this library couldn't support MIDI Events: https://github.com/orchetect/MIDIKit
