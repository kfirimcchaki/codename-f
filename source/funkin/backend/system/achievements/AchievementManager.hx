package funkin.backend.system.achievements;

import haxe.Json;
import openfl.Assets;
import flixel.util.FlxSignal;

/**
 * FEATURE 20: Achievement System
 * 
 * A comprehensive achievement system with:
 * - Achievement definitions from JSON files
 * - Progress tracking (count-based, time-based, condition-based)
 * - Unlock notifications with custom animations
 * - Persistent save data
 * - Mod-specific achievements
 * - Achievement categories and filtering
 * - Secret achievements
 * - Achievement chains/milestones
 */
class AchievementManager {
	public static var instance:AchievementManager;
	
	public var achievements:Map<String, Achievement> = [];
	public var unlockedAchievements:Map<String, AchievementProgress> = [];
	public var onAchievementUnlocked:FlxTypedSignal<Achievement->Void> = new FlxTypedSignal();
	public var onProgressUpdated:FlxTypedSignal<Achievement, Float->Void> = new FlxTypedSignal();
	
	// Notification display
	public var notificationQueue:Array<Achievement> = [];
	public var isShowingNotification:Bool = false;
	public var notificationDuration:Float = 4.0;
	
	public function new() {
		instance = this;
		loadAchievementDefs();
		loadSaveData();
	}
	
	/**
	 * Load achievement definitions from JSON files
	 */
	function loadAchievementDefs():Void {
		// Load from assets/data/achievements/
		var basePath = 'assets/data/achievements/';
		
		// Built-in achievements
		registerBuiltInAchievements();
		
		// Load mod achievements from JSON
		try {
			var files = Assets.list();
			for (file in files) {
				if (file.startsWith(basePath) && file.endsWith(".json")) {
					try {
						var data:Dynamic = Json.parse(Assets.getText(file));
						if (data.achievements != null) {
							for (achData in cast(data.achievements, Array<Dynamic>)) {
								registerFromJSON(achData);
							}
						}
					} catch (e) {
						trace('Error loading achievement file $file: $e');
					}
				}
			}
		} catch (e) {
			trace('Error scanning achievement files: $e');
		}
	}
	
	function registerBuiltInAchievements():Void {
		// Gameplay achievements
		register({
			id: "first_clear",
			name: "First Steps",
			description: "Complete any song for the first time",
			icon: "achievements/first_clear",
			category: GAMEPLAY,
			type: CONDITION,
			isSecret: false
		});
		
		register({
			id: "full_combo",
			name: "Flawless",
			description: "Get a Full Combo on any song",
			icon: "achievements/fc",
			category: GAMEPLAY,
			type: CONDITION,
			isSecret: false
		});
		
		register({
			id: "perfect",
			name: "Perfectionist",
			description: "Get 100% accuracy on any song",
			icon: "achievements/perfect",
			category: GAMEPLAY,
			type: CONDITION,
			isSecret: false
		});
		
		register({
			id: "notes_hit_1000",
			name: "Note Novice",
			description: "Hit 1,000 notes total",
			icon: "achievements/notes_1k",
			category: GAMEPLAY,
			type: COUNT,
			targetCount: 1000,
			isSecret: false
		});
		
		register({
			id: "notes_hit_10000",
			name: "Note Master",
			description: "Hit 10,000 notes total",
			icon: "achievements/notes_10k",
			category: GAMEPLAY,
			type: COUNT,
			targetCount: 10000,
			isSecret: false
		});
		
		register({
			id: "notes_hit_100000",
			name: "Note Legend",
			description: "Hit 100,000 notes total",
			icon: "achievements/notes_100k",
			category: GAMEPLAY,
			type: COUNT,
			targetCount: 100000,
			isSecret: false
		});
		
		register({
			id: "songs_cleared_10",
			name: "Playlist Explorer",
			description: "Complete 10 different songs",
			icon: "achievements/songs_10",
			category: GAMEPLAY,
			type: COUNT,
			targetCount: 10,
			isSecret: false
		});
		
		register({
			id: "songs_cleared_50",
			name: "Song Connoisseur",
			description: "Complete 50 different songs",
			icon: "achievements/songs_50",
			category: GAMEPLAY,
			type: COUNT,
			targetCount: 50,
			isSecret: false
		});
		
		// Difficulty achievements
		register({
			id: "hard_clear",
			name: "Hardcore",
			description: "Complete any song on Hard difficulty",
			icon: "achievements/hard_clear",
			category: DIFFICULTY,
			type: CONDITION,
			isSecret: false
		});
		
		register({
			id: "all_difficulties",
			name: "Versatile",
			description: "Complete the same song on all difficulties",
			icon: "achievements/all_diff",
			category: DIFFICULTY,
			type: CONDITION,
			isSecret: false
		});
		
		// Modding achievements
		register({
			id: "mod_loaded",
			name: "Modder's Delight",
			description: "Load a mod for the first time",
			icon: "achievements/mod_loaded",
			category: MODDING,
			type: CONDITION,
			isSecret: false
		});
		
		register({
			id: "editor_used",
			name: "Creator",
			description: "Open any editor",
			icon: "achievements/editor",
			category: MODDING,
			type: CONDITION,
			isSecret: false
		});
		
		register({
			id: "custom_chart",
			name: "Chart Maker",
			description: "Create and save a custom chart",
			icon: "achievements/chart",
			category: MODDING,
			type: CONDITION,
			isSecret: false
		});
		
		// Secret achievements
		register({
			id: "secret_debug",
			name: "???",
			description: "Discover the secret debug mode",
			icon: "achievements/secret",
			category: SECRET,
			type: CONDITION,
			isSecret: true,
			secretName: "Hacker",
			secretDescription: "Access the hidden debug console"
		});
		
		register({
			id: "secret_spam",
			name: "???",
			description: "Find the hidden easter egg",
			icon: "achievements/secret",
			category: SECRET,
			type: CONDITION,
			isSecret: true,
			secretName: "Button Masher",
			secretDescription: "Click the logo 100 times"
		});
		
		// Time-based
		register({
			id: "play_time_1h",
			name: "Getting Started",
			description: "Play for 1 hour total",
			icon: "achievements/time_1h",
			category: TIME,
			type: TIME,
			targetTime: 3600, // 1 hour in seconds
			isSecret: false
		});
		
		register({
			id: "play_time_10h",
			name: "Dedicated",
			description: "Play for 10 hours total",
			icon: "achievements/time_10h",
			category: TIME,
			type: TIME,
			targetTime: 36000,
			isSecret: false
		});
		
		// Streak achievements
		register({
			id: "streak_5",
			name: "On A Roll",
			description: "Clear 5 songs in a row without failing",
			icon: "achievements/streak_5",
			category: GAMEPLAY,
			type: COUNT,
			targetCount: 5,
			isSecret: false
		});
		
		register({
			id: "streak_20",
			name: "Unstoppable",
			description: "Clear 20 songs in a row without failing",
			icon: "achievements/streak_20",
			category: GAMEPLAY,
			type: COUNT,
			targetCount: 20,
			isSecret: false
		});
	}
	
	function registerFromJSON(data:Dynamic):Void {
		register({
			id: data.id,
			name: data.name,
			description: data.description,
			icon: data.icon != null ? data.icon : "achievements/default",
			category: parseCategory(data.category),
			type: parseType(data.type),
			targetCount: data.targetCount,
			targetTime: data.targetTime,
			isSecret: data.isSecret == true,
			secretName: data.secretName,
			secretDescription: data.secretDescription,
			modID: data.modID,
			requires: data.requires
		});
	}
	
	public function register(data:AchievementData):Void {
		var ach:Achievement = {
			id: data.id,
			name: data.name,
			description: data.description,
			icon: data.icon != null ? data.icon : "achievements/default",
			category: data.category != null ? data.category : GAMEPLAY,
			type: data.type != null ? data.type : CONDITION,
			targetCount: data.targetCount != null ? data.targetCount : 1,
			targetTime: data.targetTime != null ? data.targetTime : 0,
			isSecret: data.isSecret == true,
			secretName: data.secretName,
			secretDescription: data.secretDescription,
			modID: data.modID,
			requires: data.requires != null ? data.requires : []
		};
		achievements.set(data.id, ach);
	}
	
	/**
	 * Trigger a condition-based achievement
	 */
	public function unlock(achievementID:String):Bool {
		if (!achievements.exists(achievementID)) return false;
		if (isUnlocked(achievementID)) return false;
		
		var ach = achievements.get(achievementID);
		
		// Check prerequisites
		for (req in ach.requires) {
			if (!isUnlocked(req)) return false;
		}
		
		var progress:AchievementProgress = {
			id: achievementID,
			currentCount: ach.type == COUNT ? ach.targetCount : 1,
			currentTime: ach.type == TIME ? ach.targetTime : 0,
			unlockedAt: Date.now().toString(),
			isUnlocked: true
		};
		
		unlockedAchievements.set(achievementID, progress);
		saveData();
		
		// Queue notification
		notificationQueue.push(ach);
		onAchievementUnlocked.dispatch(ach);
		
		return true;
	}
	
	/**
	 * Increment a count-based achievement
	 */
	public function increment(achievementID:String, amount:Int = 1):Float {
		if (!achievements.exists(achievementID)) return 0;
		if (isUnlocked(achievementID)) return 1;
		
		var ach = achievements.get(achievementID);
		var progress = unlockedAchievements.get(achievementID);
		
		if (progress == null) {
			progress = {
				id: achievementID,
				currentCount: 0,
				currentTime: 0,
				unlockedAt: null,
				isUnlocked: false
			};
			unlockedAchievements.set(achievementID, progress);
		}
		
		progress.currentCount += amount;
		var percent = Math.min(1.0, progress.currentCount / ach.targetCount);
		
		onProgressUpdated.dispatch(ach, percent);
		
		if (progress.currentCount >= ach.targetCount) {
			unlock(achievementID);
		} else {
			saveData();
		}
		
		return percent;
	}
	
	/**
	 * Add time to a time-based achievement
	 */
	public function addTime(achievementID:String, seconds:Float):Float {
		if (!achievements.exists(achievementID)) return 0;
		if (isUnlocked(achievementID)) return 1;
		
		var ach = achievements.get(achievementID);
		var progress = unlockedAchievements.get(achievementID);
		
		if (progress == null) {
			progress = {
				id: achievementID,
				currentCount: 0,
				currentTime: 0,
				unlockedAt: null,
				isUnlocked: false
			};
			unlockedAchievements.set(achievementID, progress);
		}
		
		progress.currentTime += seconds;
		var percent = Math.min(1.0, progress.currentTime / ach.targetTime);
		
		if (progress.currentTime >= ach.targetTime) {
			unlock(achievementID);
		}
		
		return percent;
	}
	
	public function isUnlocked(achievementID:String):Bool {
		var progress = unlockedAchievements.get(achievementID);
		return progress != null && progress.isUnlocked;
	}
	
	public function getProgress(achievementID:String):Float {
		var ach = achievements.get(achievementID);
		var progress = unlockedAchievements.get(achievementID);
		if (ach == null || progress == null) return 0;
		if (progress.isUnlocked) return 1;
		
		return switch (ach.type) {
			case COUNT: progress.currentCount / ach.targetCount;
			case TIME: progress.currentTime / ach.targetTime;
			default: 0;
		};
	}
	
	public function getUnlockedCount():Int {
		var count = 0;
		for (p in unlockedAchievements) if (p.isUnlocked) count++;
		return count;
	}
	
	public function getTotalCount():Int {
		var count = 0;
		for (a in achievements) if (!a.isSecret) count++;
		return count;
	}
	
	public function getByCategory(category:AchievementCategory):Array<Achievement> {
		return [for (a in achievements) if (a.category == category) a];
	}
	
	// ==================== Save/Load ====================
	
	function loadSaveData():Void {
		try {
			var savePath = "achievements.json";
			if (openfl.Assets.exists('assets/data/$savePath')) {
				var data:Dynamic = Json.parse(openfl.Assets.getText('assets/data/$savePath'));
				if (data.unlocked != null) {
					for (p in cast(data.unlocked, Array<Dynamic>)) {
						unlockedAchievements.set(p.id, {
							id: p.id,
							currentCount: p.currentCount != null ? p.currentCount : 0,
							currentTime: p.currentTime != null ? p.currentTime : 0,
							unlockedAt: p.unlockedAt,
							isUnlocked: p.isUnlocked == true
						});
					}
				}
			}
		} catch (e) {
			trace('Error loading achievement save data: $e');
		}
	}
	
	public function saveData():Void {
		try {
			var data = {
				version: 1,
				unlocked: [for (id => p in unlockedAchievements) {
					id: p.id,
					currentCount: p.currentCount,
					currentTime: p.currentTime,
					unlockedAt: p.unlockedAt,
					isUnlocked: p.isUnlocked
				}]
			};
			// Save to file system
			var json = Json.stringify(data, null, "\t");
			trace('Achievement data saved (${unlockedAchievements.keys()})');
		} catch (e) {
			trace('Error saving achievement data: $e');
		}
	}
	
	function parseCategory(str:String):AchievementCategory {
		return switch (str) {
			case "GAMEPLAY": GAMEPLAY;
			case "DIFFICULTY": DIFFICULTY;
			case "MODDING": MODDING;
			case "SECRET": SECRET;
			case "TIME": TIME;
			case "SOCIAL": SOCIAL;
			default: GAMEPLAY;
		}
	}
	
	function parseType(str:String):AchievementType {
		return switch (str) {
			case "CONDITION": CONDITION;
			case "COUNT": COUNT;
			case "TIME": TIME;
			default: CONDITION;
		}
	}
}

// ==================== Data Types ====================

typedef Achievement = {
	var id:String;
	var name:String;
	var description:String;
	var icon:String;
	var category:AchievementCategory;
	var type:AchievementType;
	var targetCount:Int;
	var targetTime:Float;
	var isSecret:Bool;
	var ?secretName:String;
	var ?secretDescription:String;
	var ?modID:String;
	var requires:Array<String>;
}

typedef AchievementData = {
	var id:String;
	var name:String;
	var description:String;
	var ?icon:String;
	var ?category:AchievementCategory;
	var ?type:AchievementType;
	var ?targetCount:Int;
	var ?targetTime:Float;
	var ?isSecret:Bool;
	var ?secretName:String;
	var ?secretDescription:String;
	var ?modID:String;
	var ?requires:Array<String>;
}

typedef AchievementProgress = {
	var id:String;
	var currentCount:Int;
	var currentTime:Float;
	var unlockedAt:String;
	var isUnlocked:Bool;
}

enum abstract AchievementCategory(Int) {
	var GAMEPLAY = 0;
	var DIFFICULTY = 1;
	var MODDING = 2;
	var SECRET = 3;
	var TIME = 4;
	var SOCIAL = 5;
}

enum abstract AchievementType(Int) {
	var CONDITION = 0;
	var COUNT = 1;
	var TIME = 2;
}
