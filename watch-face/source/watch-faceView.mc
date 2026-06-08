import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

const BACKGROUND_COLOR = Graphics.COLOR_BLACK;
const HOUR_COLOR = Graphics.COLOR_WHITE;
const MINUTE_COLOR = 0x66E89A;
const TIME_FONT = Graphics.FONT_NUMBER_MEDIUM;
const BATTERY_WIDTH = 20;
const BATTERY_HEIGHT = 10;
const BATTERY_TIP_WIDTH = 5;
const BATTERY_PADDING = 3;
const BATTERY_TEXT_GAP = 16;
const BATTERY_PERCENT_FONT = Graphics.FONT_XTINY;

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
        drawBattery(dc);
    }

    function drawBackground(dc as Dc) as Void {
        dc.setColor(HOUR_COLOR, BACKGROUND_COLOR);
        dc.clear();
    }

    function drawTime(dc as Dc, hour as Number, minute as Number) as Void {
        drawText(dc, timeX(dc), hourY(dc), hour.toString(), HOUR_COLOR);
        drawText(dc, timeX(dc), minuteY(dc), minute.format("%02d"), MINUTE_COLOR);
    }

    function drawBattery(dc as Dc) as Void {
        var percent = batteryPercent();
        var x = timeX(dc);
        var y = minuteY(dc) + dc.getFontHeight(TIME_FONT) + 12;

        drawBatteryIcon(dc, x, y, percent);
        drawBatteryPercent(dc, x + BATTERY_WIDTH + BATTERY_TIP_WIDTH + BATTERY_TEXT_GAP, y, percent);
    }

    function drawBatteryIcon(dc as Dc, x as Number, y as Number, percent as Number) as Void {
        var innerWidth = BATTERY_WIDTH - BATTERY_PADDING * 2;
        var fillWidth = innerWidth * percent / 100;
        var tipHeight = BATTERY_HEIGHT * 50 / 100;
        var tipY = y + (BATTERY_HEIGHT - tipHeight) / 2;

        dc.setColor(MINUTE_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(x, y, BATTERY_WIDTH, BATTERY_HEIGHT);
        dc.fillRectangle(x + BATTERY_WIDTH, tipY, BATTERY_TIP_WIDTH, tipHeight);

        if (fillWidth > 0) {
            dc.fillRectangle(
                x + BATTERY_PADDING,
                y + BATTERY_PADDING,
                fillWidth,
                BATTERY_HEIGHT - BATTERY_PADDING * 2
            );
        }
    }

    function drawBatteryPercent(dc as Dc, x as Number, y as Number, percent as Number) as Void {
        var textY = y + (BATTERY_HEIGHT - dc.getFontHeight(BATTERY_PERCENT_FONT)) / 2;

        dc.setColor(HOUR_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x,
            textY,
            BATTERY_PERCENT_FONT,
            percent.format("%d") + "%",
            Graphics.TEXT_JUSTIFY_LEFT
        );
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

    function batteryPercent() as Number {
        var percent = System.getSystemStats().battery.toNumber();

        if (percent < 0) {
            return 0;
        }

        if (percent > 100) {
            return 100;
        }

        return percent;
    }

    function timeX(dc as Dc) as Number {
        return dc.getWidth() * 20 / 100;
    }

    function hourY(dc as Dc) as Number {
        return dc.getHeight() * 24 / 100;
    }

    function minuteY(dc as Dc) as Number {
        return hourY(dc) + dc.getFontHeight(TIME_FONT) * 70 / 100;
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
