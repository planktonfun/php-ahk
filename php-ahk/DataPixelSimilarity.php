<?php

class DataPixelSimilarity
{
    public function __construct($perimeter, $range, $treshold)
    {
        $this->results = [
            'start' => microtime(true)
        ];

        $this->perimeter = $perimeter;
        $this->range = $range;
        $this->treshold = $treshold;
    }

    public function __destruct()
    {
        imagedestroy($this->im);
    }

    public function basicScan($position)
    {
        $this->count = 0;
        $this->scanPerimeter($position, $this->perimeter);

        return [$this->count, $this->treshold];
    }

    // Gets the best method to Scan
    public function autoCalibrate()
    {
        echo "Auto Calibrate: ";

        $passing   = true;
        $suggested = false;

        while ($passing) {

            $previousTime = number_format(abs($this->results['start'] - $this->results['end']), 1);
            $previousOut  = $this->results['out'];

            $this->results = [
                'start' => microtime(true)
            ];

            $this->perimeter--;

            $scan = $this->partialScan([0,0]);

            if ($scan[2] == $previousOut) {
                $this->results['out'] = $scan[2];
                $this->results['end'] = microtime(true);

                $currentTime = number_format(abs($this->results['start'] - $this->results['end']), 1);
                $passing     = ($currentTime < $previousTime);

                if ($passing) {
                    $suggested = $this->perimeter;
                }
            } else {
                $passing = false;
            }
        }

        if ($suggested) {
            echo 'Suggested perimeter:'. $suggested;
        }

        return $this->perimeter;
    }

    public function partialScan($offset)
    {
        $totalPassCount = 0;
        $totalCount     = 0;
        $maxCount       = [0,0,[]];

        for ($ox=$offset[0];$ox<($this->targetsize[0]-$this->perimeter);$ox++) {
            for ($oy=$offset[1];$oy<($this->targetsize[1]-$this->perimeter);$oy++) {

                $this->count = 0;
                $break = false;

                for ($x=0;$x<$this->perimeter;$x++) {
                    for ($y=0;$y<$this->perimeter;$y++) {
                        $rgb1 = $this->intRGB(imagecolorat($this->im, $x, $y));
                        $rgb2 = $this->intRGB(imagecolorat($this->target, $ox+$x, $oy+$y));
                        $this->analyze($rgb1, $rgb2);
                        if ($this->count == 0) {
                            break;
                        }
                    }
                    if ($this->count == 0) {
                        break;
                    }
                }

                if ($this->count>=$maxCount[0]) {
                    $maxCount[0] = $this->count;
                    $maxCount[1] = $this->perimeter*$this->perimeter;

                    if ($this->count >= $this->treshold) {
                        // Remove redundant positions
                        if (count($maxCount[2]) == 0) {
                            $maxCount[2][] = [
                                $ox,
                                $oy,
                                $this->count,
                                $this->treshold
                            ];
                        } elseif (
                            (($ox - $maxCount[2][count($maxCount[2])-1][0]) >= $this->perimeter) &&
                            (($oy - $maxCount[2][count($maxCount[2])-1][1]) >= $this->perimeter)
                        ) {
                            $maxCount[2][] = [
                                $ox + ($this->imsize[0]/2),
                                $oy + ($this->imsize[1]/2),
                                $this->count,
                                $this->treshold
                            ];
                        }
                    }
                }

                $totalCount++;

                if ($this->count >= $this->treshold) {
                    $totalPassCount++;
                }
            }
        }

        $this->results['out'] = $maxCount[2];
        $this->results['end'] = microtime(true);

        return [$totalPassCount, $totalCount, $maxCount[2]];
    }

    public function scan()
    {
        $totalPassCount = 0;
        $totalCount     = 0;

        $position = [0,0];

        for ($width=$position[0]; ($width+$this->perimeter) < $this->imsize[0]; $width += $this->perimeter) {
            for ($height=$position[1]; ($height+$this->perimeter) < $this->imsize[1]; $height += $this->perimeter) {
                $this->count = 0;
                $this->scanPerimeter([$width, $height], $this->perimeter);

                $totalCount++;
                if ($this->count >= $this->treshold) {
                    $totalPassCount++;
                }
            }
        }

        return [$totalPassCount, $totalCount];

    }

    public function setTargetImage($src)
    {
        $this->im = imagecreatefrompng($src);
        $this->imsize = getimagesize($src);
    }

    public function setTargetImageResized($src)
    {
        $this->im = $this->resizeImage($src, $this->perimeter, $this->perimeter);
        $this->imsize = [$this->perimeter, $this->perimeter];
    }

    public function setForeignImageReady($src)
    {
        $this->target = $src;
    }

    public function setForeignImage($src)
    {
        $this->target = imagecreatefrompng($src);
        $this->targetsize = getimagesize($src);
    }

    public function setForeignImageResizedPercent($src, $percent)
    {
        $originalSize = getimagesize($src);
        $this->target = $this->resizeImage($src, $originalSize[0] * $percent[0], $originalSize[1] * $percent[1]);
        $this->targetsize = [$originalSize[0] * $percent[0], $originalSize[1] * $percent[1]];
    }

    public function setForeignImageResized($src)
    {
        $this->target = $this->resizeImage($src, $this->imsize[0], $this->imsize[1]);
    }

    public function getPercent($src)
    {
        $originalSize = getimagesize($src);

        return [
            $this->perimeter/$originalSize[0],
            $this->perimeter/$originalSize[1],
        ];
    }

    public function saveForeignPng($src)
    {
        imagepng($this->im, $src);
    }

    public function saveTargetPng($src)
    {
        imagepng($this->target, $src);
    }

    public function resizeImage($src, $width, $height)
    {
        $size   = getimagesize($src);
        $thumb  = imagecreatetruecolor($width, $height);
        $source = imagecreatefrompng($src);

        imagecopyresized($thumb, $source, 0, 0, 0, 0, $width, $height, $size[0], $size[1]);

        return $thumb;
    }

    public function analyze($im, $target)
    {
        if ($this->testRangeRGB($im, $target)) {
            $this->count++;
        }
    }

    private function intRGB($rgb)
    {
        $response = [];

        $response[] = ($rgb >> 16) & 0xFF;
        $response[] = ($rgb >> 8) & 0xFF;
        $response[] = $rgb & 0xFF;

        return $response;
    }

    private function testRangeRGB($src, $target)
    {
        foreach ($src as $index => $value) {
            $test = $this->testRange($src[$index], $target[$index]);
            if (!$test) {
                return false;
            }
        }

        return true;
    }

    private function testRange($src, $target)
    {
        $min = $src - $this->range;
        $max = $src + $this->range;

        return ($min<$target && $target<$max);
    }

    private function scanPerimeter($position, $perimeter)
    {
        for ($x=$position[0];$x<($position[0]+$perimeter);$x++) {
            for ($y=$position[1];$y<($position[1]+$perimeter);$y++) {
                $rgb1 = $this->intRGB(imagecolorat($this->im, $x, $y));
                $rgb2 = $this->intRGB(imagecolorat($this->target, $x, $y));
                $this->analyze($rgb1, $rgb2);
            }
        }
    }

    public function stamp($coords, $src, $output)
    {
        // Load the stamp and the photo to apply the watermark to
        $stamp     = imagecreatefrompng(__DIR__ .'\stamps.png');
        $stampsize = getimagesize(__DIR__ .'\stamps.png');
        $center    = [$stampsize[0]/2, $stampsize[1]/2];
        $im        = imagecreatefrompng($src);

        // Set the margins for the stamp and get the height/width of the stamp image
        $margeRight  = 10;
        $margeBottom = 10;
        $sx          = imagesx($stamp);
        $sy          = imagesy($stamp);

        // Copy the stamp image onto our photo using the margin offsets and the photo
        // width to calculate positioning of the stamp.
        foreach ($coords as $coord) {
            imagecopy($im, $stamp, $coord[0]-$center[0], $coord[1]-$center[1], 0, 0, imagesx($stamp), imagesy($stamp));
        }

        // Output and free memory
        imagepng($im, $output);
        imagedestroy($im);
    }
}