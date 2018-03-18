<?php
// src/AppBundle/Entity/eFaInitTask.php

namespace AppBundle\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class eFaInitTask
{

    /**
     * @Assert\Locale(
     *    groups={"Language"}
     * )
     */
    protected $locale;


    public function getLanguage()
    {
        return $this->locale;
    }

    public function setLanguage($locale)
    {
        $this->locale = $locale;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"Hostname"}
     * )
     * @Assert\Length(
     *    min     = 2,
     *    max     = 256,
     *    groups={"Hostname"}
     * )
     * @Assert\Regex(
     *    "/^[-a-zA-Z0-9]+$/",
     *    groups={"Hostname"}
     * )
     */
    protected $hostname;


    public function getHostname()
    {
        return $this->hostname;
    }

    public function setHostname($var)
    {
        $this->hostname = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"Domainname"}
     * )
     * @Assert\Length(
     *    min     = 2,
     *    max     = 256,
     *    groups={"Domainname"}
     * )
     * @Assert\Regex(
     *    "/^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9-]+)*\.[a-z]{2,15}$/",
     *    groups={"Domainname"}
     * )
     */
    protected $domainname;


    public function getDomainname()
    {
        return $this->domainname;
    }

    public function setDomainname($var)
    {
        $this->domainname = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"Email"}
     * )
     * @Assert\Length(
     *    min     = 2,
     *    max     = 256,
     *    groups={"Email"}
     * )
     * @Assert\Email(
     *    groups={"Email"}
     * )
     */
    protected $email;


    public function getEmail()
    {
        return $this->email;
    }

    public function setEmail($var)
    {
        $this->email = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"IPv4address"}
     * )
     * @Assert\Length(
     *    min     = 7,
     *    max     = 15,
     *    groups={"IPv4address"}
     * )
     * @Assert\Ip(
     *    version = 4,
     *    groups={"IPv4address"}
     * )
     */
    protected $ipv4address;


    public function getIPv4address()
    {
        return $this->ipv4address;
    }

    public function setIPv4address($var)
    {
        $this->ipv4address = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"IPv4netmask"}
     * )
     * @Assert\Length(
     *    min     = 7,
     *    max     = 15,
     *    groups={"IPv4netmask"}
     * )
     * @Assert\Regex(
     *    "/^(((255\.){3}(255|254|252|248|240|224|192|128|0+))|((255\.){2}(255|254|252|248|240|224|192|128|0+)\.0)|((255\.)(255|254|252|248|240|224|192|128|0+)(\.0+){2})|((255|254|252|248|240|224|192|128|0+)(\.0+){3}))$/",
     *    groups={"IPv4netmask"}
     * )
     */
    protected $ipv4netmask;


    public function getIPv4netmask()
    {
        return $this->ipv4netmask;
    }

    public function setIPv4netmask($var)
    {
        $this->ipv4netmask = $var;
    }


    /**
     * @Assert\NotBlank(
     *    groups={"IPv4gateway"}
     *)
     * @Assert\Length(
     *    min     = 7,
     *    max     = 15,
     *    groups={"IPv4gateway"}
     * )
     * @Assert\Ip(
     *    version = 4,
     *    groups={"IPv4gateway"}
     * )
     */
    protected $ipv4gateway;


    public function getIPv4gateway()
    {
        return $this->ipv4gateway;
    }

    public function setIPv4gateway($var)
    {
        $this->ipv4gateway = $var;
    }
}
?>
