<?php
// src/AppBundle/Entity/eFaInitTask.php

namespace AppBundle\Entity;

use Symfony\Component\Validator\Constraints as Assert;
use AppBundle\Validator\Constraints as eFaInitAssert;

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
     *    groups={"Interface"}
     * )
     */
    protected $interface;

    public function getInterface()
    {
        return $this->interface;
    }

    public function setInterface($var)
    {
        $this->interface = $var;
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

    /**
     * @Assert\NotBlank(
     *    groups={"IPv6address"}
     * )
     * @Assert\Length(
     *    min     = 3,
     *    max     = 40,
     *    groups={"IPv6address"}
     * )
     * @Assert\Ip(
     *    version = 6,
     *    groups={"IPv6address"}
     * )
     */
    protected $ipv6address;


    public function getIPv6address()
    {
        return $this->ipv6address;
    }

    public function setIPv6address($var)
    {
        $this->ipv6address = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"IPv6prefix"}
     * )
     * @Assert\Range(
     *    min = 8,
     *    max = 127,
     *    groups={"IPv6prefix"}
     * )
     */
    protected $ipv6prefix;


    public function getIPv6prefix()
    {
        return $this->ipv6prefix;
    }

    public function setIPv6prefix($var)
    {
        $this->ipv6prefix = $var;
    }


    /**
     * @Assert\NotBlank(
     *    groups={"IPv6gateway"}
     *)
     * @Assert\Length(
     *    min     = 3,
     *    max     = 40,
     *    groups={"IPv6gateway"}
     * )
     * @Assert\Ip(
     *    version = 6,
     *    groups={"IPv6gateway"}
     * )
     */
    protected $ipv6gateway;


    public function getIPv6gateway()
    {
        return $this->ipv6gateway;
    }

    public function setIPv6gateway($var)
    {
        $this->ipv6gateway = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"DNS1"}
     *)
     * @Assert\Ip(
     *    groups={"DNS1"}
     * )
     */
    protected $dns1;


    public function getDNS1()
    {
        return $this->dns1;
    }

    public function setDNS1($var)
    {
        $this->dns1 = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"DNS2"}
     * )
     * @Assert\Ip(
     *    groups={"DNS2"}
     * )
     */
    protected $dns2;


    public function getDNS2()
    {
        return $this->dns2;
    }

    public function setDNS2($var)
    {
        $this->dns2 = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"Webusername"}
     * )
     * @eFaInitAssert\UsernameOrEmail(
     *    groups={"Webusername"}
     * )
     */
    protected $webusername;


    public function getWebusername()
    {
        return $this->webusername;
    }

    public function setWebusername($var)
    {
        $this->webusername = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"CLIusername"}
     * )
     * @eFaInitAssert\CLIUsername(
     *    groups={"CLIusername"}
     * )
     */
    protected $cliusername;


    public function getCLIusername()
    {
        return $this->cliusername;
    }

    public function setCLIusername($var)
    {
        $this->cliusername = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"Webpassword1"}
     * )
     * @Assert\Length(
     *    min=1,
     *    max=256,
     *    groups={"Webpassword1"}
     * )
     */
    protected $webpassword1;
    protected $webpassword2;


    public function getWebpassword2()
    {
        return $this->webpassword2;
    }

    public function setWebpassword2($var)
    {
        $this->webpassword2 = $var;
    }
    
    public function getWebpassword1()
    {
        return $this->webpassword1;
    }

    public function setWebpassword1($var)
    {
        $this->webpassword1 = $var;
    }

    /**
     * @Assert\IsTrue(
     *     message="Passwords do not match",
     *     groups={"Webpassword2"}
     * )
     *        
     */
    public function isWebPasswordSame()
    {
         return $this->webpassword1 === $this->webpassword2;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"CLIpassword1"}
     * )
     * @Assert\Length(
     *    min=1,
     *    max=256,
     *    groups={"CLIpassword1"}
     * )
     */
    protected $clipassword1;
    protected $clipassword2;

    public function getCLIpassword2()
    {
        return $this->clipassword2;
    }

    public function setCLIpassword2($var)
    {
        $this->clipassword2 = $var;
    }
    
    public function getCLIpassword1()
    {
        return $this->clipassword1;
    }

    public function setCLIpassword1($var)
    {
        $this->clipassword1 = $var;
    }

    /**
     * @Assert\IsTrue(
     *     message="Passwords do not match",
     *     groups={"CLIpassword2"}
     * )
     *        
     */
    public function isCLIPasswordSame()
    {
         return $this->clipassword1 === $this->clipassword2;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"Timezone"}
     * )
     */
    protected $timezone;


    public function getTimezone()
    {
        return $this->timezone;
    }

    public function setTimezone($var)
    {
        $this->timezone = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"Mailserver"}
     * )
     * @Assert\Regex(
     *    "/^[-a-zA-Z0-9\.]{2,256}+$/",
     *    groups={"Mailserver"}
     * )
     */
    protected $mailserver;


    public function getMailserver()
    {
        return $this->mailserver;
    }

    public function setMailserver($var)
    {
        $this->mailserver = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"IANAcode"}
     * )
     * @Assert\Regex(
     *    "/^[a-z]{1,2}$/",
     *    groups={"IANAcode"}
     * )
     */
    protected $ianacode;


    public function getIANAcode()
    {
        return $this->ianacode;
    }

    public function setIANAcode($var)
    {
        $this->ianacode = $var;
    }

    /**
     * @Assert\NotBlank(
     *    groups={"Orgname"}
     * )
     * @Assert\Regex(
     *    "/^[a-zA-Z1-9]{2,253}$/",
     *    groups={"Orgname"}
     * )
     */
    protected $orgname;


    public function getOrgname()
    {
        return $this->orgname;
    }

    public function setOrgname($var)
    {
        $this->orgname = $var;
    }



}
?>
