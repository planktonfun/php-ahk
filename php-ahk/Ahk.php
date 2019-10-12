<?php

chdir(__DIR__);

include "Udp.php";
include "WebObject.php";

class Ahk
{
    public $application = "AutoHotkey.exe";
    protected $udpPhp;
    protected $udpAhk;
    protected $retries = 15;

    public function getUdp()
    {
        if (is_null($this->udpPhp)) {
            $this->udpPhpPort = rand(8000,9000);
            $this->udpPhp = new Udp($this->udpPhpPort);
        }

        return $this->udpPhp;
    }

    public function getAhkUdp($server = '127.0.0.1', $port = 8888)
    {
        if (is_null($this->udpAhk)) {
            $this->getUdp();
            $this->udpAhkPort = rand(8000,9000);
            $this->udpAhk = json_decode(json_encode([
                'server' => $server,
                'port'   => $this->udpAhkPort
            ]));

            $this->new_file = "server". time() . ".ahk";

            copy("server.ahk", $this->new_file);

            echo `start $this->application "$this->new_file" $this->udpAhkPort $this->udpPhpPort`;

            $result = $this->getUdp()->recieve();
        }

        return $this->udpAhk;
    }

    public function sendMessageInit($msg, $server, $port)
    {
        $sock = socket_create(AF_INET, SOCK_DGRAM, 0);
        socket_sendto($sock, $msg, strlen($msg), 0, $this->getAhkUdp()->server, $this->getAhkUdp()->port);
    }

    public function sendMessage($msg)
    {
        $sock = socket_create(AF_INET, SOCK_DGRAM, 0);
        socket_sendto($sock, $msg, strlen($msg), 0, $this->getAhkUdp()->server, $this->getAhkUdp()->port);
    }

    public function monitorMovements()
    {
        echo "\n".'Starting monitoring movements: ';
        echo `start $this->application "monitorMovements.ahk"`;

        $steadypoint = 0;
        $toggle      = false;
        $found       = false;
        $target      = "";

        while (true) {
            $result = $this->getUdp()->recieve();
            $pixels = explode(' ', trim($result));
            if ($pixels[0] > 100) {

                echo "\n".$pixels[1];

                $steadypoint++;

                if ( $steadypoint >= 5 ) {
                    $steadypoint = 0;
                    $target      = $pixels[1];
                    $toggle      = true;
                }

            } else {
                $steadypoint = 0;
                $toggle      = false;
            }

            if ( $pixels[1] <> $target ) {
                $found = true;
                if ( $toggle ) {
                    $this->sendMessage('click');
                    echo "\n". $pixels[0];

                    while (true) {
                        usleep(700000);
                        $this->sendMessage('click');
                    }
                    $toggle = false;
                } else {
                    echo "\nFound";
                }

            } else {
                $found = false;
            }
        }
    }

    public function clipboard($message)
    {
        echo "\n".'Save to clipboard: '. $message;
        $this->sendMessage("clipboard`$message");
    }

    public function msgbox($message)
    {
        echo "\n".'Popup message: '. $message;
        $this->sendMessage("msgBox`$message");
    }

    public function getMousePosition()
    {
        echo "\n".'Getting mouse position';
        $this->sendMessage("getMousePosition");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception($result . " position not found");
        }

        $result = trim($result);

        return explode(' ', $result);
    }

    public function click($x, $y)
    {
        echo "\n".'Clicking mouse position: '. $x .', '. $y;
        $this->sendMessage("click`$x`$y");
    }

    public function typeBackground($controlId, $message)
    {
        echo "\n".'Sending message in background: '. $message;
        $this->sendMessage("sendBackground`$controlId`$message");
    }

    public function type($message)
    {
        echo "\n".'Sending message: '. $message;
        $this->sendMessage("send`$message");
        usleep(300000);
    }

    public function resizeActiveWindow($w, $h)
    {
        echo "\n".'Resizing Active window: '. $w .'x'. $h;
        $this->sendMessage("resize`$w`$h");
    }

       public function moveActiveWindow($x, $y)
    {
        echo "\n".'Moving Active window: '. $x .', '. $y;
        $this->sendMessage("moveWindow`$x`$y");
    }

    public function speak($message)
    {
        echo "\n".'Saying: '. $message;
        $this->sendMessage("speak`$message");
    }

    public function move($x, $y)
    {
        echo "\n".'Moving mouse position: '. $x .', '. $y;
        $this->sendMessage("move`$x`$y");
    }

    public function closeApp($pId)
    {
        echo "\n".'Closing Application Pid: '.$pId;
        $this->sendMessage("closeApp`$pId");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception("Error closing App: ". $appName);
        }

        $result = trim($result);

        return $result;
    }

    public function openApp($appName, $params)
    {
        echo "\n".'Opening Application: '.$appName;
        $this->sendMessage("openApp`$appName`$params");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception("Error Opening App: ". $appName);
        }

        $result = trim($result);

        return $result;
    }

    public function searchClickImageOptionaly($x1, $y1, $x2, $y2, $filename, $variation = false)
    {
        try {
            $corners = $this->searchImage($x1, $y1, $x2, $y2, $filename, $variation = false);
            $this->click($corners[0], $corners[1]);
        } catch (\Exception $e) {
            echo "\n". $e->getMessage();
        }
    }

    public function searchImage($x1, $y1, $x2, $y2, $filename, $variation = false)
    {
        echo "\n".'Searching image areas: '. $x1.', '. $y1.', '. $x2.', '. $y2 .', '. $filename;
        if ($variation) {
            $this->sendMessage("searchImageVariation`$x1|$y1|$x2|$y2`$filename`$variation");
        } else {
            $this->sendMessage("searchImage`$x1|$y1|$x2|$y2`$filename");
        }

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception($filename . " image not found");
        }

        $result = trim($result);

        $corners = explode(' ', $result);

        $this->topX = $corners[0];
        $this->topY = $corners[1];

        return $corners;
    }

    public function waitForImage($x1, $y1, $x2, $y2, $filename, $variation=false)
    {
        echo "\n".'Waiting for image: '. $filename .' '. $x1.', '. $y1.', '. $x2.', '. $y2;

        for ($i=0; $i < $this->retries; $i++) {
            try {

                if ($variation) {
                    $this->sendMessage("searchImageVariation`$x1|$y1|$x2|$y2`$filename`$variation");
                } else {
                    $this->sendMessage("searchImage`$x1|$y1|$x2|$y2`$filename");
                }

                $result = $this->getUdp()->recieve();

                if (trim($result)=="0" || trim($result)=="") {
                    throw new \Exception($filename . " image not found");
                }

                $result = trim($result);

                $corners = explode(' ', $result);

                return $corners;
            } catch (\Exception $e) {
                echo '.';
            }
            usleep(500000);
        }

        throw new \Exception($filename . " image not found");
    }

    public function getImage($x1, $y1, $x2, $y2, $image, $output = 123)
    {
        echo "\n".'Searching image areas: '. $x1.', '. $y1.', '. $x2.', '. $y2;
        $this->sendMessage("getImage`$x1|$y1|$x2|$y2`$image`$output");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception(" getting image error");
        }

        $result = trim($result);

        return $result;
    }

    public function resizeImagefromImage($image, $ratio, $output)
    {
        echo "\n".'Resizing image: '. $image .' with ratio: '. $ratio;
        $this->sendMessage("resizeImage`$ratio`$image`$output");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception("resizing image error");
        }

        $result = trim($result);

        return $result;
    }

    public function pixelateImage($image, $output)
    {
        echo `php 8bit.php "$image" "$output"`;

    }

    public function getText()
    {
        echo "\n".'Getting text from active window';
        $this->sendMessage("getText");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception("getting text error");
        }

        $result = trim($result);

        return $result;
    }

    public function hideApp($appId)
    {
        echo "\n".'Hiding App: '. $appId;
        $this->sendMessage("hideApp`$appId");
    }

    public function showApp($appId)
    {
        echo "\n".'Hiding App: '. $appId;
        $this->sendMessage("showApp`$appId");
    }

    public function openInternetExplorer($visible = true)
    {
        echo "\n".'Opening Internet Explorer '. $visible;
        $this->sendMessage("createComObject`$visible");

        $result = $this->getUdp()->recieve();

        return new WebObject($this);
    }

    public function clickFromApplication($appId, $x, $y)
    {
        echo "\n".'Clicking coords from application: '. $appId .', '. $x .', '. $y;
        $this->sendMessage("clickApp`$appId`$x`$y");
    }

    public function getImageFromApplication($appId, $output)
    {
        echo "\n".'Get Image from application: '. $appId;
        $this->sendMessage("getImageApp`$appId`$output");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception(" Get Application Image error");
        }

        $result = trim($result);

        return $result;
    }

    public function getApplicationIdFromWindow($title)
    {
        echo "\n".'Get Application Id from window title: '. $title;
        $this->sendMessage("getApplicationId`$title");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception(" Get Application window ID error");
        }

        $result = trim($result);

        return $result;
    }

    public function getActiveWindowId()
    {
        echo "\n".'Get Active window ID';
        $this->sendMessage("getActiveWindowControlId");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception(" Get Active window ID error");
        }

        $result = trim($result);

        return $result;
    }

    public function searchImageFromImage($haystack, $needle, $variation = false)
    {
        echo "\n".'Searching image areas: '. $haystack.', '. $needle;
        if ($variation) {
            $this->sendMessage("searchImageFromImageVariation`$haystack`$needle`$variation");
        } else {
            $this->sendMessage("searchImageFromImage`$haystack`$needle");
        }

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception(" Searching image from image error");
        }

        $result = trim($result);
        $result = explode(' ', $result);

        return $result;
    }

    public function cropImageFromImage($x1, $y1, $x2, $y2, $image, $output)
    {
        echo "\n".'Cropping image areas: '. $x1.', '. $y1.', '. $x2.', '. $y2.' from'. $image ;
        $this->sendMessage("getImageFromImage`$x1|$y1|$x2|$y2`$image`$output");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception(" getting image crop error");
        }

        $result = trim($result);

        return $result;
    }

    public function getColorFromImage($x, $y, $file, $output)
    {
        echo "\n".'Getting color position: '. $x.', '. $y;
        $this->sendMessage("getColorFromImage`$x`$y`$file`$output");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception($output . " color not found");
        }

        $result = trim($result);

        return $result;
    }

    public function getColor($x, $y, $output="")
    {
        echo "\n".'Getting color position: '. $x.', '. $y;
        $this->sendMessage("getColor`$x`$y`$output");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception($output . " color not found");
        }

        $result = trim($result);

        return $result;
    }

    public function getColorBulk($x, $y, $image, $output)
    {
        echo "\n".'Getting color from image : '. $image;
        $this->sendMessage("getColorBulk`$image`$output");

        $result = $this->getUdp()->recieve();

        if (trim($result)=="0" || trim($result)=="") {
            throw new \Exception($output . " color not found");
        }

        $result = trim($result);

        $points = explode("]", $result);
        $colors = [];

        foreach ($points as $value) {
            if (trim($value) != "") {
                $offsets = explode(" ", trim($value));
                echo "\n". $offsets[2];
                $colors[] = [
                    'x'     => $offsets[0] + $x,
                    'y'     => $offsets[1] + $y,
                    'color' => substr($offsets[2], 2, 3)
                ];
            }
        }

        return $colors;
    }

    public function __destruct()
    {
        $this->sendMessage('exit');
    }
}