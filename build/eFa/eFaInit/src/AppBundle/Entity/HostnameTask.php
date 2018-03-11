<?php
// src/AppBundle/Entity/HostnameTask.php

namespace AppBundle\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class HostnameTask
{
    /**
     * @Assert\NotBlank()
     * @Assert\Length(
     *    min     = 2,
     *    max     = 256,
     * )
     * @Assert\Regex(
     *    "/^[-a-zA-Z0-9]+$/",
     *    message = "Enter a valid hostname"
     * )
     */
    protected $hostname;


    public function getHostname()
    {
        return $this->hostname;
    }

    public function setHostname($hostname)
    {
        $this->hostname = $hostname;
    }
}
?>
