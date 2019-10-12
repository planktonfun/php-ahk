<?php

require_once dirname(__DIR__) .'\php-ahk\vendor\Calibrator.php';
require_once '2fuse.php';

$twoFuse    = new TwoFuse;
$calibrator = new Calibrator;
$twoFuse->perimeter = 10;

function getCoords(\twoFuse $twoFuse) {

    $coords = [];

    // $coords[] = $twoFuse->getColorResults(__DIR__ .'\2fuse.png');

    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\11.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\12.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\13.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\14.png');

    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\21.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\22.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\23.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\24.png');

    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\31.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\32.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\33.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\34.png');

    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\41.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\42.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\43.png');
    $coords[] = $twoFuse->getColorResults(__DIR__ .'\cluter\44.png');

    return $coords;
}

class calibrate
{
    public $twoFuse;

    public function __construct($twoFuse)
    {
        $this->twoFuse = $twoFuse;
    }

    public function process($perimeter)
    {
        $this->twoFuse->perimeter = $perimeter;
        return getCoords($this->twoFuse);
    }
};

$calibrateProcessor = new calibrate($twoFuse);

$calibrator->startRecording();
$coords = getCoords($twoFuse);
$calibrator->recordResult($coords);
$calibrator->endRecording();


var_dump($coords);
$calibrator->getSuggestedPerimeters($calibrateProcessor, $twoFuse->perimeter);

return $coords;
// coord
// w: 94 h: 95
// offset: 18, 15
// d: 27

