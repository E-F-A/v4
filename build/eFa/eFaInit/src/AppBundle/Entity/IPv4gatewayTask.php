<?php
// src/AppBundle/Entity/IPv4gatewayTask.php

namespace AppBundle\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class IPv4gatewayTask
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
    protected $var;


    public function getTextbox()
    {
        return $this->var;
    }

    public function setTextbox($var)
    {
        $this->var = $var;
    }
}
?>
