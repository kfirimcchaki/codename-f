package funkin.backend.utils;

import openfl.media.Sound;
import openfl.utils.ByteArray;
import flixel.math.FlxMath;

/**
 * FEATURE 91: Audio Spectrum Analyzer & Visual Audio System for Stages
 * 
 * Provides real-time audio analysis for visual effects synchronized to music.
 * Features:
 * - FFT (Fast Fourier Transform) spectrum analysis
 * - Frequency band extraction (bass, mid, treble)
 * - Beat detection algorithm
 * - Waveform data extraction
 * - RMS (volume) analysis
 * - Peak detection
 * - Smoothed values for visual effects
 * - Multiple preset visualization modes (bars, wave, circular, etc.)
 * - Integration with stage editor for visual audio design
 * - Moddable visualization settings
 */
class AudioAnalyzer {
	public static var instance:AudioAnalyzer;
	
	// FFT settings
	public var fftSize:Int = 512;
	public var sampleRate:Int = 44100;
	public var smoothingFactor:Float = 0.8;
	
	// Analysis data
	public var spectrumData:Array<Float> = [];
	public var smoothedSpectrum:Array<Float> = [];
	public var waveform:Array<Float> = [];
	
	// Frequency bands
	public var bass:Float = 0;
	public var mid:Float = 0;
	public var treble:Float = 0;
	public var subBass:Float = 0;
	public var lowMid:Float = 0;
	public var highMid:Float = 0;
	public var presence:Float = 0;
	public var brilliance:Float = 0;
	
	// Volume
	public var rms:Float = 0;
	public var peak:Float = 0;
	public var smoothedRMS:Float = 0;
	
	// Beat detection
	public var beatThreshold:Float = 1.3;
	public var beatDecay:Float = 0.98;
	public var beatCooldown:Float = 0.1;
	public var isBeat:Bool = false;
	public var beatIntensity:Float = 0;
	public var lastBeatTime:Float = 0;
	public var bpm:Float = 0;
	
	// Internal
	private var prevSpectrum:Array<Float> = [];
	private var beatHistory:Array<Float> = [];
	private var beatHistoryMax:Int = 43; // ~1 second at 44100/1024
	private var energyHistory:Array<Float> = [];
	private var cooldownTimer:Float = 0;
	
	// Custom frequency bands (user-defined)
	public var customBands:Array<FrequencyBand> = [];
	
	public function new() {
		instance = this;
		for (i in 0...fftSize) {
			spectrumData.push(0);
			smoothedSpectrum.push(0);
			prevSpectrum.push(0);
		}
		for (i in 0...256) {
			waveform.push(0);
		}
		
		// Default custom bands
		customBands = [
			{name: "Sub Bass", lowFreq: 20, highFreq: 60, value: 0, smoothed: 0},
			{name: "Bass", lowFreq: 60, highFreq: 250, value: 0, smoothed: 0},
			{name: "Low Mid", lowFreq: 250, highFreq: 500, value: 0, smoothed: 0},
			{name: "Mid", lowFreq: 500, highFreq: 2000, value: 0, smoothed: 0},
			{name: "High Mid", lowFreq: 2000, highFreq: 4000, value: 0, smoothed: 0},
			{name: "Presence", lowFreq: 4000, highFreq: 6000, value: 0, smoothed: 0},
			{name: "Brilliance", lowFreq: 6000, highFreq: 20000, value: 0, smoothed: 0}
		];
	}
	
	/**
	 * Analyze audio data from a ByteArray
	 */
	public function analyzeSound(data:ByteArray, ?smoothing:Float):Void {
		if (smoothing == null) smoothing = smoothingFactor;
		
		// Extract spectrum data using FFT
		performFFT(data);
		
		// Apply smoothing
		for (i in 0...fftSize) {
			smoothedSpectrum[i] = smoothedSpectrum[i] * smoothing + spectrumData[i] * (1 - smoothing);
		}
		
		// Extract frequency bands
		extractBands();
		
		// Calculate volume
		calculateVolume(data);
		
		// Beat detection
		detectBeat();
	}
	
	/**
	 * Simplified FFT implementation
	 */
	function performFFT(data:ByteArray):Void {
		if (data == null || data.length < fftSize * 4) return;
		
		data.position = 0;
		var samples:Array<Float> = [];
		
		for (i in 0...fftSize) {
			try {
				var left = data.readFloat();
				var right = data.readFloat();
				samples.push((left + right) / 2);
			} catch (e) {
				samples.push(0);
			}
		}
		
		// Simple DFT approximation for performance
		var halfSize = Std.int(fftSize / 2);
		for (k in 0...halfSize) {
			var real:Float = 0;
			var imag:Float = 0;
			
			for (n in 0...fftSize) {
				var angle = 2 * Math.PI * k * n / fftSize;
				real += samples[n] * Math.cos(angle);
				imag -= samples[n] * Math.sin(angle);
			}
			
			var magnitude = Math.sqrt(real * real + imag * imag) / fftSize;
			spectrumData[k] = magnitude;
			
			// Store waveform
			if (k < waveform.length) {
				waveform[k] = samples[k % samples.length];
			}
		}
	}
	
	/**
	 * Extract frequency bands from spectrum
	 */
	function extractBands():Void {
		var binFreq = sampleRate / fftSize;
		
		subBass = getBandEnergy(20, 60, binFreq);
		bass = getBandEnergy(60, 250, binFreq);
		lowMid = getBandEnergy(250, 500, binFreq);
		mid = getBandEnergy(500, 2000, binFreq);
		highMid = getBandEnergy(2000, 4000, binFreq);
		presence = getBandEnergy(4000, 6000, binFreq);
		treble = getBandEnergy(4000, 20000, binFreq);
		brilliance = getBandEnergy(6000, 20000, binFreq);
		
		// Update custom bands
		for (band in customBands) {
			band.value = getBandEnergy(band.lowFreq, band.highFreq, binFreq);
			band.smoothed = band.smoothed * smoothingFactor + band.value * (1 - smoothingFactor);
		}
	}
	
	/**
	 * Get energy for a frequency range
	 */
	function getBandEnergy(lowFreq:Float, highFreq:Float, binFreq:Float):Float {
		var lowBin = Std.int(lowFreq / binFreq);
		var highBin = Std.int(highFreq / binFreq);
		lowBin = Std.int(Math.max(0, Math.min(fftSize / 2 - 1, lowBin)));
		highBin = Std.int(Math.max(0, Math.min(fftSize / 2 - 1, highBin)));
		
		var energy:Float = 0;
		var count:Int = 0;
		
		for (i in lowBin...highBin + 1) {
			if (i < smoothedSpectrum.length) {
				energy += smoothedSpectrum[i];
				count++;
			}
		}
		
		return count > 0 ? energy / count : 0;
	}
	
	/**
	 * Calculate RMS and peak volume
	 */
	function calculateVolume(data:ByteArray):Void {
		if (data == null) return;
		
		var sum:Float = 0;
		var samples:Int = 0;
		peak = 0;
		
		data.position = 0;
		try {
			while (data.bytesAvailable >= 4) {
				var sample = data.readFloat();
				sum += sample * sample;
				peak = Math.max(peak, Math.abs(sample));
				samples++;
				if (samples >= 1024) break;
			}
		} catch (e) {}
		
		rms = samples > 0 ? Math.sqrt(sum / samples) : 0;
		smoothedRMS = smoothedRMS * smoothingFactor + rms * (1 - smoothingFactor);
	}
	
	/**
	 * Beat detection using energy comparison
	 */
	function detectBeat():Void {
		var currentEnergy = bass + subBass;
		energyHistory.push(currentEnergy);
		
		if (energyHistory.length > beatHistoryMax) {
			energyHistory.shift();
		}
		
		// Calculate average energy
		var avgEnergy:Float = 0;
		for (e in energyHistory) avgEnergy += e;
		avgEnergy /= energyHistory.length;
		
		// Cooldown
		cooldownTimer -= 1 / 60;
		
		// Beat detection
		isBeat = false;
		if (cooldownTimer <= 0 && currentEnergy > avgEnergy * beatThreshold && currentEnergy > 0.01) {
			isBeat = true;
			beatIntensity = Math.min(1.0, currentEnergy / (avgEnergy * 2));
			cooldownTimer = beatCooldown;
			
			// Estimate BPM from beat intervals
			var now = Sys.time();
			if (lastBeatTime > 0) {
				var interval = now - lastBeatTime;
				if (interval > 0.2 && interval < 2.0) {
					var instantBPM = 60.0 / interval;
					bpm = bpm > 0 ? bpm * 0.9 + instantBPM * 0.1 : instantBPM;
				}
			}
			lastBeatTime = now;
		}
		
		// Decay beat intensity
		beatIntensity *= beatDecay;
	}
	
	/**
	 * Get spectrum data for a specific number of bars (for visualization)
	 */
	public function getSpectrumBars(numBars:Int, ?minFreq:Float = 20, ?maxFreq:Float = 16000):Array<Float> {
		var bars:Array<Float> = [];
		var binFreq = sampleRate / fftSize;
		var minBin = Std.int(minFreq / binFreq);
		var maxBin = Std.int(maxFreq / binFreq);
		
		// Use logarithmic frequency distribution for more natural visualization
		var logMin = Math.log(minFreq);
		var logMax = Math.log(maxFreq);
		
		for (i in 0...numBars) {
			var logLow = logMin + (logMax - logMin) * i / numBars;
			var logHigh = logMin + (logMax - logMin) * (i + 1) / numBars;
			var lowFreq = Math.exp(logLow);
			var highFreq = Math.exp(logHigh);
			
			bars.push(getBandEnergy(lowFreq, highFreq, binFreq));
		}
		
		return bars;
	}
	
	/**
	 * Get normalized spectrum data (0-1 range)
	 */
	public function getNormalizedSpectrum(numBins:Int):Array<Float> {
		var result:Array<Float> = [];
		var binSize = Std.int(fftSize / 2 / numBins);
		
		for (i in 0...numBins) {
			var sum:Float = 0;
			for (j in 0...binSize) {
				var idx = i * binSize + j;
				if (idx < smoothedSpectrum.length) sum += smoothedSpectrum[idx];
			}
			result.push(Math.min(1.0, sum / binSize * 10));
		}
		
		return result;
	}
	
	/**
	 * Create a custom frequency band
	 */
	public function addCustomBand(name:String, lowFreq:Float, highFreq:Float):FrequencyBand {
		var band:FrequencyBand = {
			name: name,
			lowFreq: lowFreq,
			highFreq: highFreq,
			value: 0,
			smoothed: 0
		};
		customBands.push(band);
		return band;
	}
	
	/**
	 * Get a custom band by name
	 */
	public function getBand(name:String):FrequencyBand {
		for (b in customBands) if (b.name == name) return b;
		return null;
	}
}

typedef FrequencyBand = {
	var name:String;
	var lowFreq:Float;
	var highFreq:Float;
	var value:Float;
	var smoothed:Float;
}

/**
 * FEATURE 91 (continued): Audio Visualization Presets
 * 
 * Pre-built visualization configurations for stages
 */
class AudioVizPreset {
	public var name:String;
	public var description:String;
	public var settings:VizSettings;
	
	public function new(name:String, settings:VizSettings) {
		this.name = name;
		this.settings = settings;
	}
	
	public static function getPresets():Array<AudioVizPreset> {
		return [
			// Bar visualizer
			new AudioVizPreset("Classic Bars", {
				type: BARS,
				barCount: 32,
				barWidth: 10,
				barSpacing: 2,
				maxHeight: 200,
				colors: [0xFF00FF00, 0xFFFFFF00, 0xFFFF0000],
				smoothing: 0.7,
				mirror: false,
				orientation: VERTICAL
			}),
			
			// Circular visualizer
			new AudioVizPreset("Circular", {
				type: CIRCULAR,
				barCount: 64,
				radius: 100,
				maxHeight: 80,
				colors: [0xFF4488FF, 0xFF8844FF],
				smoothing: 0.8,
				rotation: 0,
				innerRadius: 80
			}),
			
			// Wave visualizer
			new AudioVizPreset("Waveform", {
				type: WAVE,
				color: 0xFF00FFAA,
				thickness: 2,
				smoothing: 0.5,
				amplitude: 100
			}),
			
			// Pulse visualizer
			new AudioVizPreset("Pulse", {
				type: PULSE,
				color: 0xFFFF4488,
				minScale: 1.0,
				maxScale: 1.5,
				smoothing: 0.9,
				reactToBeat: true
			}),
			
			// Particle reactive
			new AudioVizPreset("Particle Reactive", {
				type: PARTICLES,
				particleCount: 50,
				reactToBeat: true,
				baseSpeed: 50,
				beatSpeed: 300,
				colors: [0xFFFF8800, 0xFFFF0088, 0xFF8800FF]
			}),
			
			// Background color
			new AudioVizPreset("Ambient Color", {
				type: BG_COLOR,
				smoothing: 0.95,
				colors: [0xFF000022, 0xFF220044, 0xFF440066],
				reactBand: "bass"
			}),
			
			// Spectrum mirror
			new AudioVizPreset("Mirror Bars", {
				type: BARS,
				barCount: 32,
				barWidth: 8,
				barSpacing: 2,
				maxHeight: 150,
				colors: [0xFF0088FF, 0xFF8800FF],
				smoothing: 0.7,
				mirror: true,
				orientation: VERTICAL
			}),
			
			// Radial wave
			new AudioVizPreset("Radial Wave", {
				type: RADIAL_WAVE,
				points: 128,
				radius: 150,
				amplitude: 50,
				color: 0xFFFFFFFF,
				thickness: 2,
				smoothing: 0.6
			})
		];
	}
}

typedef VizSettings = {
	var type:VizType;
	var ?barCount:Int;
	var ?barWidth:Float;
	var ?barSpacing:Float;
	var ?maxHeight:Float;
	var ?colors:Array<Int>;
	var ?color:Int;
	var ?smoothing:Float;
	var ?mirror:Bool;
	var ?orientation:VizOrientation;
	var ?radius:Float;
	var ?innerRadius:Float;
	var ?rotation:Float;
	var ?thickness:Float;
	var ?amplitude:Float;
	var ?minScale:Float;
	var ?maxScale:Float;
	var ?reactToBeat:Bool;
	var ?particleCount:Int;
	var ?baseSpeed:Float;
	var ?beatSpeed:Float;
	var ?reactBand:String;
	var ?points:Int;
}

enum abstract VizType(Int) {
	var BARS = 0;
	var CIRCULAR = 1;
	var WAVE = 2;
	var PULSE = 3;
	var PARTICLES = 4;
	var BG_COLOR = 5;
	var RADIAL_WAVE = 6;
	var SPECTROGRAM = 7;
}

enum abstract VizOrientation(Int) {
	var VERTICAL = 0;
	var HORIZONTAL = 1;
}
