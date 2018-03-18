<?php
// src/AppBundle/Entity/IPv4addressTask.php

namespace AppBundle\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class IPv4addressTask
{
    /**
     * @Assert\NotBlank()
     * @Assert\Length(
     *    min     = 7,
     *    max     = 15,
     * )
     * @Assert\Ip(
     *    version = 4
     * )
     */
    protected $ipv4address;


    public function getTextbox()
    {
        return $this->ipv4address;
    }

    public function setTextbox($var)
    {
        $this->ipv4address = $var;
    }
}
?>
