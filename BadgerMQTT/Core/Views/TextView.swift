//
//  TextView.swift
//  SwiftUI_MQTT
//
//  Created by Anoop M on 2021-07-10.
//

import SwiftUI

struct MessageHistoryTextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isUserInteractionEnabled = false
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        let myRange = NSMakeRange(uiView.text.count - 1, 0)
        uiView.scrollRangeToVisible(myRange)
    }
}
