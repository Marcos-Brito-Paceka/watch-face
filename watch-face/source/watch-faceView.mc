import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

const BG = Graphics.COLOR_BLACK;

const WHITE = Graphics.COLOR_WHITE;
const TEXT_SOFT = 0xF2F2F4;
const MUTED = 0x9A9AA0;
const DARK_LINE = 0x202024;
const RING_BASE = 0x2B2B30;
const CARD_BG = 0x101012;
const CARD_BORDER = 0x313136;

const GREEN = 0x66E89A;
const ICE_BLUE = 0xA9D6E5;
const BLUE = 0x4A90FF;
const YELLOW = 0xFFB347;
const RED = 0xFF5A5F;

const TIME_FONT = Graphics.FONT_NUMBER_HOT;
const TOP_FONT = Graphics.FONT_SMALL;
const STATS_LABEL_FONT = Graphics.FONT_XTINY;
const STATS_VALUE_FONT = Graphics.FONT_XTINY;
const TOP_FONT_SIZE = 28;
const STATS_LABEL_FONT_SIZE = 18;
const STATS_VALUE_FONT_SIZE = 22;

class watch_faceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var steps = stepCount();
        var goal = stepGoal();
        var progress = progressPercent(steps, goal);
        var battery = batteryPercent();

        drawBackground(dc);
        drawOuterProgressRing(dc, battery);
        drawTopInfo(dc, battery);
        drawTime(dc, clockTime.hour, clockTime.min);
        drawStatsCard(dc, steps, progress);
    }

    function drawBackground(dc as Dc) as Void {
        dc.setColor(WHITE, BG);
        dc.clear();
    }

    function drawTopInfo(dc as Dc, battery as Number) as Void {
        var y = dc.getHeight() * 20 / 100;
        var font = modernFont(TOP_FONT_SIZE, TOP_FONT);

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            y,
            font,
            battery.format("%d") + "%",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawOuterProgressRing(dc as Dc, progress as Number) as Void {
        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;

        var minSide = dc.getWidth();
        if (dc.getHeight() < minSide) {
            minSide = dc.getHeight();
        }

        var radius = minSide * 49 / 100;
        var start = -90;
        var sweepLimit = 360;
        var ringColor = batteryColor(progress);

        drawArc(dc, cx, cy, radius, start, start + sweepLimit, RING_BASE, 1);

        if (progress > 0) {
            var sweep = sweepLimit * progress / 100;
            drawArc(dc, cx, cy, radius, start, start + sweep, ringColor, 2);
        }

        drawProgressDot(dc, cx, cy, radius, start, ringColor);
    }

    function drawTime(dc as Dc, hour as Number, minute as Number) as Void {
        var cx = dc.getWidth() / 2;
        var y = dc.getHeight() * 49 / 100;
        var gap = dc.getWidth() * 3 / 100;
        var justify = Graphics.TEXT_JUSTIFY_VCENTER;

        dc.setColor(TEXT_SOFT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx - gap,
            y,
            TIME_FONT,
            hour.format("%02d"),
            justify | Graphics.TEXT_JUSTIFY_RIGHT
        );

        dc.setColor(ICE_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx + gap,
            y,
            TIME_FONT,
            minute.format("%02d"),
            justify | Graphics.TEXT_JUSTIFY_LEFT
        );

        var lineY = dc.getHeight() * 62 / 100;
        var lineLeft = 0;
        var lineRight = dc.getWidth();

        dc.setColor(DARK_LINE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(lineLeft, lineY, lineRight, lineY);
    }

    function drawStatsCard(dc as Dc, steps as Number, progress as Number) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        var cardW = w * 62 / 100;
        var cardH = h * 16 / 100;
        var x = (w - cardW) / 2;
        var y = h * 66 / 100;
        var radius = cardH * 28 / 100;

        var mid = x + cardW / 2;

        dc.setColor(CARD_BG, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y, cardW, cardH, radius);

        dc.setColor(CARD_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRoundedRectangle(x, y, cardW, cardH, radius);

        dc.setColor(DARK_LINE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(mid, y + 9, mid, y + cardH - 9);

        var labelFont = modernFont(STATS_LABEL_FONT_SIZE, STATS_LABEL_FONT);
        var valueFont = modernFont(STATS_VALUE_FONT_SIZE, STATS_VALUE_FONT);
        var labelY = y + cardH * 28 / 100;
        var valueY = y + cardH * 68 / 100;
        var labelJustify = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        var valueJustify = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x + cardW * 25 / 100,
            labelY,
            labelFont,
            "STEPS",
            labelJustify
        );

        dc.drawText(
            x + cardW * 75 / 100,
            labelY,
            labelFont,
            "GOAL",
            labelJustify
        );

        dc.setColor(WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x + cardW * 25 / 100,
            valueY,
            valueFont,
            formatSteps(steps),
            valueJustify
        );

        dc.setColor(BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x + cardW * 75 / 100,
            valueY,
            valueFont,
            progress.format("%d") + "%",
            valueJustify
        );
    }

    function modernFont(size as Number, fallback as Graphics.FontDefinition) as Graphics.FontDefinition or Graphics.VectorFont {
        var faces = [
            "Roboto",
            "Avenir Next",
            "Helvetica Neue",
            "Arial"
        ];

        for (var i = 0; i < faces.size(); i++) {
            try {
                var font = Graphics.getVectorFont({
                    :face => faces[i],
                    :size => size
                });

                if (font != null) {
                    return font;
                }
            } catch (e) {
            }
        }

        return fallback;
    }

    function drawArc(
        dc as Dc,
        cx as Number,
        cy as Number,
        radius as Number,
        startDeg as Number,
        endDeg as Number,
        color as Number,
        penWidth as Number
    ) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(penWidth);

        var prevX = 0;
        var prevY = 0;
        var first = true;

        for (var deg = startDeg; deg <= endDeg; deg += 2) {
            var rad = deg * Math.PI / 180.0;
            var x = cx + radius * Math.cos(rad);
            var y = cy + radius * Math.sin(rad);

            if (!first) {
                dc.drawLine(prevX, prevY, x, y);
            }

            prevX = x;
            prevY = y;
            first = false;
        }
    }

    function drawProgressDot(dc as Dc, cx as Number, cy as Number, radius as Number, deg as Number, color as Number) as Void {
        var rad = deg * Math.PI / 180.0;

        var x = cx + radius * Math.cos(rad);
        var y = cy + radius * Math.sin(rad);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y, 3);
    }

    function batteryColor(percent as Number) as Number {
        if (percent < 30) {
            return RED;
        }

        if (percent <= 60) {
            return YELLOW;
        }

        return GREEN;
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

    function stepCount() as Number {
        var steps = ActivityMonitor.getInfo().steps;

        if (steps == null) {
            return 0;
        }

        return steps;
    }

    function stepGoal() as Number {
        var goal = ActivityMonitor.getInfo().stepGoal;

        if (goal == null) {
            return 0;
        }

        return goal;
    }

    function progressPercent(steps as Number, goal as Number) as Number {
        if (goal <= 0) {
            return 0;
        }

        var percent = steps * 100 / goal;

        if (percent > 100) {
            return 100;
        }

        if (percent < 0) {
            return 0;
        }

        return percent;
    }

    function formatSteps(steps as Number) as String {
        var text = steps.toString();
        var result = "";

        while (text.length() > 3) {
            var splitIndex = text.length() - 3;
            result = "." + text.substring(splitIndex, text.length()) + result;
            text = text.substring(0, splitIndex);
        }

        return text + result;
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }
}
