import SwiftUI

enum DeviceCategory: String, Codable, CaseIterable, Identifiable {
    case adatExpander = "ADAT Expander"
    case audioInterface = "Audio Interface"
    case busCompressor = "Bus Compressor"
    case channelStrip = "Channel Strip"
    case compressor = "Compressor"
    case computer = "Computer"
    case controlSurface = "Control Surface"
    case digitalMixer = "Digital Mixer"
    case effectsUnit = "Effects Unit"
    case equalizer = "Equalizer"
    case headphoneAmp = "Headphone Amp"
    case headphones = "Headphones"
    case keyboard = "Keyboard"
    case microphone = "Microphone"
    case midiDevice = "MIDI Device"
    case midiInterface = "MIDI Interface"
    case mixer = "Mixer"
    case studioMonitor = "Studio Monitor"
    case multi = "Multi"
    case patchbay = "Patchbay"
    case preamp = "Preamp"
    case synth = "Synth"
    case usbHub = "USB Hub"
    case usbExpander = "USB Expander"
    case videoMonitor = "Video Monitor"
    case instrument = "Instrument"
    case mobileDevice = "Mobile Device"
    case auv3Plugin = "AUv3 Plugin"
    case softwareSynth = "Software Synth"
    case other = "Other"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .audioInterface:              return "waveform.circle"
        case .computer:                    return "desktopcomputer"
        case .microphone:                  return "mic"
        case .mixer, .digitalMixer:        return "slider.horizontal.3"
        case .studioMonitor:               return "speaker.wave.3"
        case .headphones:                  return "headphones"
        case .headphoneAmp:                return "amplifier"
        case .keyboard:                    return "pianokeys"
        case .synth:                       return "pianokeys.inverse"
        case .midiDevice, .midiInterface:  return "cable.connector.horizontal"
        case .controlSurface:              return "fader.horizontal"
        case .compressor, .busCompressor:  return "waveform.path"
        case .equalizer:                   return "dial.high"
        case .effectsUnit:                 return "fx"
        case .preamp:                      return "bolt.circle"
        case .adatExpander:                return "arrow.triangle.branch"
        case .channelStrip:                return "list.dash"
        case .patchbay:                    return "network"
        case .usbHub, .usbExpander:        return "cable.connector"
        case .videoMonitor:                return "tv"
        case .multi:                       return "square.grid.2x2"
        case .instrument:                  return "guitars"
        case .mobileDevice:                return "ipad.and.iphone"
        case .auv3Plugin:                  return "puzzlepiece.extension"
        case .softwareSynth:               return "keyboard.macwindow"
        case .other:                       return "questionmark.square"
        }
    }

    var defaultColor: Color {
        switch self {
        case .computer:                         return .blue
        case .audioInterface:                   return .cyan
        case .mixer, .digitalMixer:             return .indigo
        case .studioMonitor:                    return .teal
        case .headphones, .headphoneAmp:        return .mint
        case .microphone:                       return .purple
        case .synth, .keyboard:                 return .orange
        case .midiDevice, .midiInterface,
             .controlSurface:                   return .pink
        case .compressor, .busCompressor,
             .effectsUnit, .equalizer:          return Color(red: 0.9, green: 0.7, blue: 0.1)
        case .preamp, .channelStrip:            return .green
        case .adatExpander, .usbHub,
             .usbExpander:                      return Color(red: 0.5, green: 0.5, blue: 0.9)
        case .patchbay:                         return Color(red: 0.7, green: 0.4, blue: 0.2)
        case .instrument:                       return Color(red: 0.6, green: 0.8, blue: 0.4)
        case .mobileDevice:                     return Color(red: 0.3, green: 0.7, blue: 0.9)
        case .auv3Plugin:                       return Color(red: 0.9, green: 0.5, blue: 0.9)
        case .softwareSynth:                    return Color(red: 0.5, green: 0.9, blue: 0.7)
        default:                                return .gray
        }
    }

    // Signal-flow tier used by AutoArrangeEngine (lower = upstream/source)
    var signalTier: Int {
        switch self {
        case .computer, .keyboard, .synth, .controlSurface:   return 0
        case .microphone, .midiDevice, .midiInterface:         return 1
        case .preamp, .audioInterface, .channelStrip,
             .adatExpander, .usbHub, .usbExpander:             return 2
        case .mixer, .digitalMixer, .patchbay:                 return 3
        case .effectsUnit, .compressor, .busCompressor,
             .equalizer, .multi:                               return 4
        case .headphoneAmp:                                    return 5
        case .studioMonitor, .headphones, .videoMonitor:       return 6
        case .instrument:                                      return 0
        case .mobileDevice:                                    return 0
        case .softwareSynth:                                   return 1
        case .auv3Plugin:                                      return 4
        default:                                               return 4
        }
    }
}
