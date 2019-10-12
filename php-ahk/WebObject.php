<?php

class WebObject
{
    // The test will pause for 0.25 seconds between each step so the browser has time to process events.
    protected $stepDelay = 0.25;

    // The test will spend up to 15 seconds attempting to locate an element before failing.
    protected $elementTimeout = 15;

    // The test will spend up to 10 seconds waiting for an AJAX request to complete.
    protected $ajaxTimeout = 10;

    public function __construct($ahk)
    {
        $this->ahk = $ahk;
    }

    public function navigate($url)
    {
        usleep(1000000*$this->stepDelay);
        echo "navigate";
        $this->ahk->sendMessage("ComNavigate`$url");
        return trim($this->ahk->getUdp()->recieve());
    }

    public function executeCommand($command, $id)
    {
        usleep(1000000*$this->stepDelay);
        $startTime = time();

        $this->ahk->sendMessage($command);
        $response = trim($this->ahk->getUdp()->recieve());

        while($response=="0") {

            $this->ahk->sendMessage($command);

            $response   = trim($this->ahk->getUdp()->recieve());
            $timePassed = time() - $startTime;

            if($timePassed > $this->elementTimeout) {
                break;
            }
        }

        if($response=="0") {
            throw new \Exception('Error finding ' . $id);
        }

        return $response;
    }

    public function setValue($id, $value)
    {
        echo "setValue";
        return $this->executeCommand("ComSetValue`$id`$value", $id);
    }

    public function setAttr($id, $key, $value)
    {
        echo "setAttr";
        return $this->executeCommand("ComSetAttr`$id`$key`$value", $id);
    }

    public function click($id)
    {
        echo "click";
        return $this->executeCommand("ComClick`$id", $id);
    }

    public function submit($id)
    {
        echo "submit";
        return $this->executeCommand("ComSubmit`$id", $id);
    }

    public function getUrl()
    {
        usleep(1000000*$this->stepDelay);
        echo "getUrl";
        $this->ahk->sendMessage("ComGetURL");
        return trim($this->ahk->getUdp()->recieve());
    }

}