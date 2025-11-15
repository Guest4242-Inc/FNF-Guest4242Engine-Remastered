package funkin.ui.freeplay;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxState;
import lime.utils.Assets;
import sys.io.File;

class OldFreeplayState extends MusicBeatState
{
    var songs:Array<String> = [];

    var selector:FlxText;
    var curSelected:Int = 0;
    var curDifficulty:Int = 1;

    var scoreText:FlxText;
    var diffText:FlxText;
    var lerpScore:Int = 0;
    var intendedScore:Int = 0;

    private var grpSongs:FlxTypedGroup<MenuText>;
    private var curPlaying:Bool = false;

    override function create()
    {
        super.create();

        // Load songs from file
        songs = File.getContent("assets/data/freeplaySonglist.txt").split("\n");

        // Debug flag
        var isDebug:Bool = false;
        #if debug
        isDebug = true;
        #end

        // Unlock songs depending on weeks
        if (StoryMenuState.weekUnlocked[2] || isDebug)
            songs = songs.concat(['Spookeez','South']);
        if (StoryMenuState.weekUnlocked[3] || isDebug)
            songs = songs.concat(['Pico','Philly','Blammed']);
        if (StoryMenuState.weekUnlocked[4] || isDebug)
            songs = songs.concat(['Satin-Panties','High','Milf']);
        if (StoryMenuState.weekUnlocked[5] || isDebug)
            songs = songs.concat(['Cocoa','Eggnog','Winter-Horrorland']);
        if (StoryMenuState.weekUnlocked[6] || isDebug)
            songs = songs.concat(['Senpai','Roses','Thorns']);

        // Background
        var bg:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuBGBlue.png');
        add(bg);

        // Group of song texts
        grpSongs = new FlxTypedGroup<MenuText>();
        add(grpSongs);

        for (i in 0...songs.length)
        {
            var songText:MenuText = new MenuText(40, (70*i)+30, 400, songs[i]);
            songText.isMenuItem = true;
            songText.targetY = i;
            grpSongs.add(songText);
        }

        // Score & difficulty texts
        scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
        scoreText.setFormat("assets/fonts/vcr.ttf",32,FlxColor.WHITE,RIGHT);

        var scoreBG:FlxSprite = new FlxSprite(scoreText.x-6,0).makeGraphic(Std.int(FlxG.width*0.35),66,0xFF000000);
        scoreBG.alpha = 0.6;
        add(scoreBG);

        diffText = new FlxText(scoreText.x, scoreText.y+36, 0, "", 24);
        diffText.font = scoreText.font;
        add(diffText);

        add(scoreText);

        changeSelection();
        changeDiff();

        selector = new FlxText(0,0,40,">");
        selector.size = 40;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
            FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

        lerpScore = Math.floor(FlxMath.lerp(lerpScore,intendedScore,0.4));
        if (Math.abs(lerpScore-intendedScore)<=10)
            lerpScore = intendedScore;

        scoreText.text = "PERSONAL BEST:"+lerpScore;

        // Controls replacement
        var upP = FlxG.keys.pressed.UP;
        var downP = FlxG.keys.pressed.DOWN;
        var leftP = FlxG.keys.pressed.LEFT;
        var rightP = FlxG.keys.pressed.RIGHT;
        var accepted = FlxG.keys.justPressed.ENTER;
        var back = FlxG.keys.justPressed.ESCAPE;

        if (upP) changeSelection(-1);
        if (downP) changeSelection(1);
        if (leftP) changeDiff(-1);
        if (rightP) changeDiff(1);

        if (back)
            FlxG.switchState(new MainMenuState());

        if (accepted)
        {
            var poop:String = Highscore.formatSong(songs[curSelected].toLowerCase(), curDifficulty);

            PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].toLowerCase());
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = curDifficulty;

            FlxG.switchState(new PlayState());
            if (FlxG.sound.music != null) FlxG.sound.music.stop();
        }
    }

    function changeDiff(change:Int=0)
    {
        curDifficulty += change;
        if (curDifficulty<0) curDifficulty = 2;
        if (curDifficulty>2) curDifficulty = 0;

        intendedScore = Highscore.getScore(songs[curSelected],curDifficulty);

        switch (curDifficulty)
        {
            case 0: diffText.text = "EASY";
            case 1: diffText.text = "NORMAL";
            case 2: diffText.text = "HARD";
        }
    }

    function changeSelection(change:Int=0)
    {
        curSelected += change;
        if (curSelected<0) curSelected = songs.length-1;
        if (curSelected>=songs.length) curSelected = 0;

        intendedScore = Highscore.getScore(songs[curSelected],curDifficulty);

        FlxG.sound.playMusic('assets/music/'+songs[curSelected]+"_Inst.ogg",0);

        var bullShit:Int = 0;
        for (item in grpSongs.members)
        {
            var menuItem = cast(item, MenuText);
            menuItem.targetY = bullShit - curSelected;
            menuItem.alpha = if(menuItem.targetY==0) 1 else 0.6;
            bullShit++;
        }
    }
}

// ==================== MENU TEXT CLASS ====================
class MenuText extends FlxText
{
    public var targetY:Int;
    public var isMenuItem:Bool;

    public function new(X:Float,Y:Float,Width:Int,Text:String)
    {
        super(X,Y,Width,Text);
    }
}

// ==================== STUB CLASSES ====================
class StoryMenuState { public static var weekUnlocked:Array<Bool> = [true,true,true,true,true,true,true]; }
class Highscore
{
    public static function getScore(song:String,diff:Int):Int { return 0; }
    public static function formatSong(song:String,diff:Int):String { return song; }
}
class PlayState extends FlxState
{
    public static var SONG:Dynamic;
    public static var isStoryMode:Bool;
    public static var storyDifficulty:Int;
}
class Song
{
    public static function loadFromJson(file:String,name:String):Dynamic { return {}; }
}
class MainMenuState extends FlxState {}
