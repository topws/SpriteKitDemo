
//  Constants.swift
//  SnipTheVine

/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

struct ImageName {
	static let Background = "Background"
	static let Ground = "Ground"
	static let Water = "Water"
	static let VineTexture = "VineTexture"
	static let VineHolder = "VineHolder"
	static let CrocMouthClosed = "CrocMouthClosed"
	static let CrocMouthOpen = "CrocMouthOpen"
	static let CrocMask = "CrocMask"
	static let Prize = "Pineapple"
	static let PrizeMask = "PineappleMask"
}

struct SoundFile {
	static let BackgroundMusic = "CheeZeeJungle.caf"
	static let Slice = "Slice.caf"
	static let Splash = "Splash.caf"
	static let NomNom = "NomNom.caf"
}

struct Layer {
	static let Background: CGFloat = 0
	static let Crocodile: CGFloat = 1
	static let Vine: CGFloat = 1
	static let Prize: CGFloat = 2
	static let Foreground: CGFloat = 3
}

struct PhysicsCategory {
	static let Crocodile: UInt32 = 1
	static let VineHolder: UInt32 = 2
	static let Vine: UInt32 = 4
	static let Prize: UInt32 = 8
}
struct GameConfiguration {
	static let VineDataFile = "VineData.plist"
	static let CanCutMultipleVinesAtOnce = false
}
