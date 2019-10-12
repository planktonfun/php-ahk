<?php

require_once '2fuse.php';
include "../php-ahk/Ahk.php";

$twoFuse = new TwoFuse;

try {

    $colors = [];
    $ahk    = new Ahk;

    $offx     = 18;
    $offy     = 15;
    $width    = 94;
    $height   = 95;
    $distance = 27;

    $ahk->searchImage(0, 0, 2000, 2000, __DIR__ .'\topleftcorner.png');
    $once = false;

    while (true) {
        usleep(1000000);

        var_dump($ahk->topX, $ahk->topY);

        $result = $ahk->getImage($ahk->topX, $ahk->topY, $ahk->topX+500, $ahk->topY+500, __DIR__ .'\bulkbuster.bmp', 1232245);
        var_dump($result);

        $positions   = [];
        $positions[] = [$offx, $offy, 11];
        $positions[] = [$offx+$distance+$width, $offy, 12];
        $positions[] = [$offx+((($distance+$width)*2)+3), $offy, 13];
        $positions[] = [$offx+((($distance+$width)*3)+3+3), $offy, 14];

        $positions[] = [$offx, $offy+$height+$distance, 21];
        $positions[] = [$offx+$distance+$width, $offy+$height+$distance, 22];
        $positions[] = [$offx+((($distance+$width)*2)+3), $offy+$height+$distance, 23];
        $positions[] = [$offx+((($distance+$width)*3)+3+3), $offy+$height+$distance, 24];

        $positions[] = [$offx, $offy+(($height+$distance)*2+1), 31];
        $positions[] = [$offx+$distance+$width, $offy+(($height+$distance)*2+1), 32];
        $positions[] = [$offx+((($distance+$width)*2)+3), $offy+(($height+$distance)*2+1), 33];
        $positions[] = [$offx+((($distance+$width)*3)+3+3), $offy+(($height+$distance)*2+1), 34];

        $positions[] = [$offx, $offy+(($height+$distance)*3+1), 41];
        $positions[] = [$offx+$distance+$width, $offy+(($height+$distance)*3+1), 42];
        $positions[] = [$offx+((($distance+$width)*2)+3), $offy+(($height+$distance)*3+1), 43];
        $positions[] = [$offx+((($distance+$width)*3)+3+3), $offy+(($height+$distance)*3+1), 44];

        foreach ($positions as $position) {
            unlink(__DIR__ .'\cluter\\'. $position[2] .'.png');
            $ahk->cropImageFromImage($position[0], $position[1], $width, $height, __DIR__ .'\bulkbuster.bmp', __DIR__ .'\cluter\\'. $position[2] .'.png');
        }

        $blocks = include 'replace_color.php';

        $dump    = [];
        $dumps   = [];

        if (!$once) {
            $once = true;
            $ahk->click($ahk->topX, $ahk->topY);
        }

        foreach ($blocks as $index => $block) {
            if (!isset($dump[$block['color'] . $block['value']])) {
                $dump[$block['color'] . $block['value']] = $positions[$index];
            } else {
                $click = $dump[$block['color'] . $block['value']];
                $ahk->click($ahk->topX+$click[0]+($width/2), $ahk->topY+$click[1]+($height/2));
                // usleep(100000);
                $click = $positions[$index];
                $ahk->click($ahk->topX+$click[0]+($width/2), $ahk->topY+$click[1]+($height/2));
                // usleep(100000);
                unset($dump[$block['color'] . $block['value']]);

                if($block['value'] < 3) {
                    $dumps[] = [$block['color'] . ($block['value']+1), $positions[$index], $block['color'], ($block['value']+1)];
                }
            }
            echo "\n". $block['color'] . $block['value'] . $positions[$index][0] . $positions[$index][1];
        }

        foreach ($blocks as $index => $block) {
            if (isset($dump[$block['color'] . $block['value']])) {
                $dumps[] = [$block['color'] . $block['value'], $positions[$index], $block['color'], $block['value']];
            }
        }

        usleep(500000);

        $reserved = [];

        foreach ($dumps as $index => $value) {
            if (!isset($reserved[$value[0]])) {
                $reserved[$value[0]] = $value[1];
            } else {
                $click = $reserved[$value[0]];
                $ahk->click($ahk->topX+$click[0]+($width/2), $ahk->topY+$click[1]+($height/2));
                // usleep(100000);
                $click = $value[1];
                $ahk->click($ahk->topX+$click[0]+($width/2), $ahk->topY+$click[1]+($height/2));
                // usleep(100000);
                unset($reserved[$value[0]]);
            }
            echo "\n reserved: ". $index . " " . $value[1][0] . " " . $value[1][1];
        }

        $blocks = [];

    }

} catch (\Exception $e) {
    echo "\n".$e->getMessage();
}