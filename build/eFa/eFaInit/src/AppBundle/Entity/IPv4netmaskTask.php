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
     * @Assert\Regex(
     *    "/^(((255\.){3}(255|254|252|248|240|224|192|128|0+))|((255\.){2}(255|254|252|248|240|224|192|128|0+)\.0)|((255\.)(255|254|252|248|240|224|192|128|0+)(\.0+){2})|((255|254|252|248|240|224|192|128|0+)(\.0+){3}))$/"
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
