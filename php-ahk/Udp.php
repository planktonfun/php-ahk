<?php

class Udp
{
    public function __construct($port)
    {
        if (!($this->sock = socket_create(AF_INET, SOCK_DGRAM, 0)))
        {
            $errorcode = socket_last_error();
            $errormsg  = socket_strerror($errorcode);

            throw new \Exception("Couldn't create socket: [$errorcode] $errormsg \n");
        }

        if (!socket_bind($this->sock, "0.0.0.0", $port))
        {
            $errorcode = socket_last_error();
            $errormsg  = socket_strerror($errorcode);

            throw new \Exception("Could not bind socket : [$errorcode] $errormsg \n");
        }
    }

    public function recieve()
    {
        socket_recvfrom($this->sock, $buffer, 900, 0, $remoteIp, $remotePort);

        return $buffer;
    }

    public function __destruct()
    {
        socket_close($this->sock);
    }
}