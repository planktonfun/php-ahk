<?php
require_once dirname(__DIR__) .'\php-ahk\DataPixelSimilarity.php';

class twoFuse
{
    public function __construct()
    {
        $this->perimeter = 100;
        $this->results = [
            'start' => microtime(true)
        ];

        $this->blue = [
            __DIR__ .'\blue\1.png',
            __DIR__ .'\blue\2.png',
            __DIR__ .'\blue\3.png',
        ];

        $this->red = [
            __DIR__ .'\red\1.png',
            __DIR__ .'\red\2.png',
            __DIR__ .'\red\3.png',
        ];

        $this->green = [
            __DIR__ .'\green\1.png',
            __DIR__ .'\green\2.png',
            __DIR__ .'\green\3.png',
        ];
    }

    public function __destruct()
    {
        foreach ($this->blue as $color) {
            // imagedestroy($color);
        }
        foreach ($this->red as $color) {
            // imagedestroy($color);
        }
        foreach ($this->green as $color) {
            // imagedestroy($color);
        }
    }

    public function getColorResults($src)
    {
        $this->results['src'] = $src;

        try {
            $result = [];

            $result[] = ['blue', 1, $this->negativeScan([$src, $this->blue[0]])];
            $result[] = ['blue', 2, $this->negativeScan([$src, $this->blue[1]])];
            $result[] = ['blue', 3, $this->negativeScan([$src, $this->blue[2]])];
            $result[] = ['red', 1, $this->negativeScan([$src, $this->red[0]])];
            $result[] = ['red', 2, $this->negativeScan([$src, $this->red[1]])];
            $result[] = ['red', 3, $this->negativeScan([$src, $this->red[2]])];
            $result[] = ['green', 1, $this->negativeScan([$src, $this->green[0]])];
            $result[] = ['green', 2, $this->negativeScan([$src, $this->green[1]])];
            $result[] = ['green', 3, $this->negativeScan([$src, $this->green[2]])];

            usort($result, "Self::cmp");

            if ($result[0][2] < 0.75) {
                throw new \Exception('No closest match');
            }

            $out = [
                'color' => $result[0][0],
                'value' => $result[0][1]
            ];

            $this->results['out'] = $out;
            $this->results['end'] = microtime(true);

            return $out;
        } catch (\Exception $e) {

            $out = [
                'color' => md5(microtime()),
                'value' => md5(microtime(true))
            ];

            $this->results['out'] = $out;
            $this->results['end'] = microtime(true);

            return $out;
        }
    }

    public function cmp($a, $b)
    {
        if ($a[2] == $b[2]) {
            return 0;
        }
        return ($a[2] > $b[2]) ? -1 : 1;
    }

    public function negativeScan($images)
    {
        $treshold = 0.75;
        $range    = 30;

        $dps = new DataPixelSimilarity($this->perimeter, $range, $treshold*$this->perimeter*$this->perimeter);
        $dps->setTargetImageResized($images[0]);
        $dps->setForeignImageResized($images[1]);
        $result = $dps->basicScan([0,0]);

        return ($result[0]/$result[1]);
    }

    public function autoCalibrate()
    {
        echo "Auto Calibrate: ";

        $passing = true;

        while ($passing) {
            $previousTime = abs($this->results['start'] - $this->results['end']);
            $previousOut  = $this->results['out'];
            $previousSrc  = $this->results['src'];

            $this->results = [
                'start' => microtime(true)
            ];

            $this->perimeter--;

            $scan = $this->getColorResults($previousSrc);
            $this->results['out'] = $scan;
            $this->results['end'] = microtime(true);

            if ($scan == $previousOut) {
                echo 'result success';

                $currentTime = abs($this->results['start'] - $this->results['end']);
                $passing     = ($currentTime <= $previousTime);

                if ($passing) {
                    echo 'time success';
                    var_dump($this->perimeter);
                }
            } else {
                $passing = false;
            }
        }

        return $this->perimeter;
    }
}