// Shamelessly 'acquired' from MIDIKit, with grateful thanks to Steffan Andrews' work.
//  BluetoothMIDIView.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2023 Steffan Andrews • Licensed under MIT License
//

#if os(iOS)

import UIKit
import SwiftUI
import CoreAudioKit

public struct TKBluetoothMIDIView: UIViewControllerRepresentable {
    public init() {        
    }
    
    public func makeUIViewController(context: Context) -> TKBTMIDICentralViewController {
        TKBTMIDICentralViewController()
    }
    
    public func updateUIViewController(
        _ uiViewController: TKBTMIDICentralViewController,
        context: Context
    ) { }
    
    public typealias UIViewControllerType = TKBTMIDICentralViewController
}

public class TKBTMIDICentralViewController: CABTMIDICentralViewController {
    public var uiViewController: UIViewController?
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneAction)
        )
    }
    
    @objc
    public func doneAction() {
        uiViewController?.dismiss(animated: true, completion: nil)
    }
}

#endif
