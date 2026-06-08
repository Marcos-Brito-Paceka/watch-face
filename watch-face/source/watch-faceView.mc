import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

const BACKGROUND_COLOR = Graphics.COLOR_BLACK;
const HOUR_COLOR = Graphics.COLOR_WHITE;
const MINUTE_COLOR = 0x66E89A;
const TIME_FONT = Graphics.FONT_NUMBER_MEDIUM;

class watch_faceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();

        drawBackground(dc);
        drawTime(dc, clockTime.hour, clockTime.min);
    }

    function drawBackground(dc as Dc) as Void {
        dc.setColor(HOUR_COLOR, BACKGROUND_COLOR);
        dc.clear();
    }

    function drawTime(dc as Dc, hour as Number, minute as Number) as Void {
        var leftX = dc.getWidth() * 20 / 100;
        var hourY = dc.getHeight() * 24 / 100;
        var minuteY = hourY + dc.getFontHeight(TIME_FONT) * 70 / 100;

        drawText(dc, leftX, hourY, hour.toString(), HOUR_COLOR);
        drawText(dc, leftX, minuteY, minute.format("%02d"), MINUTE_COLOR);
    }

    function drawText(dc as Dc, x as Number, y as Number, text as String, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x,
            y,
            TIME_FONT,
            text,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
