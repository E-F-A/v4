<?php
// src/AppBundle/Entity/HostnameTask.php

namespace AppBundle\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class EmailTask
{
    /**
     * @Assert\NotBlank()
     * @Assert\Length(
     *    min     = 2,
     *    max     = 256,
     * )
     * @Assert\Email()
     */
    protected $email;


    public function getEmail()
    {
        return $this->email;
    }

    public function setEmail($email)
    {
        $this->email = $email;
    }
}
?>
