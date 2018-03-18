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
     * )
     */
    protected $hostname;


    public function getTextbox()
    {
        return $this->hostname;
    }

    public function setTextbox($var)
    {
        $this->hostname = $var;
    }
}
?>
