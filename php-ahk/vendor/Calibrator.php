<?php

class Calibrator
{
    private $results = [];

    public function startRecording()
    {
        $this->results['start'] = microtime(true);
    }

    public function recordResult($out)
    {
        $this->results['out'] = $out;
    }

    public function endRecording()
    {
        $this->results['end'] = microtime(true);
    }

    private function getPassedTime()
    {
        return number_format(abs($this->results['start'] - $this->results['end']), 1);
    }

    public function getSuggestedPerimeters($processOut, $perimeter)
    {
        echo "Auto Calibrate: ";

        $passing   = true;
        $suggested = false;

        while ($passing) {
            $previousTime = $this->getPassedTime();
            $previousOut  = $this->results['out'];

            $this->startRecording();

            // This is where the call back should change perimeters
            $perimeter--;
            $out = $processOut->process($perimeter);
            $this->recordResult($out);
            $this->endRecording();

            if ($this->results['out'] == $previousOut) {

                $currentTime = $this->getPassedTime();;
                $passing     = ($currentTime <= $previousTime);

                if ($passing) {
                    $suggested = $perimeter;
                }
            } else {
                $passing = false;
            }
        }

        if ($suggested) {
            var_dump('Suggested Perimeter: '. $suggested);
        }
    }
}