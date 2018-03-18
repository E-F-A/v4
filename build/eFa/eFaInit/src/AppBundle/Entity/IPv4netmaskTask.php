<?php
// src/AppBundle/Entity/IPv4netmaskTask.php

namespace AppBundle\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class IPv4netmaskTask
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
    protected $ipv4netmask;


    public function getTextbox()
    {
        return $this->ipv4netmask;
    }

    public function setTextbox($var)
    {
        $this->ipv4netmask = $var;
    }
}
?>
