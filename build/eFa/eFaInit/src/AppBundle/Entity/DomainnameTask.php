<?php
// src/AppBundle/Entity/HostnameTask.php

namespace AppBundle\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class DomainnameTask
{
    /**
     * @Assert\NotBlank()
     * @Assert\Length(
     *    min     = 2,
     *    max     = 256,
     * )
     * @Assert\Regex(
     *    "/^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9-]+)*\.[a-z]{2,15}$/",
     * )
     */
    protected $domainname;


    public function getDomainname()
    {
        return $this->domainname;
    }

    public function setDomainname($domainname)
    {
        $this->domainname = $domainname;
    }
}
?>
